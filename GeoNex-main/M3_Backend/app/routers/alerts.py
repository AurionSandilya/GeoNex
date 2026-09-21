"""
app/routers/alerts.py

Alerts API Endpoints (M5 Integration):
- GET /api/v1/alerts
- GET /api/v1/alerts/{id}
- POST /api/v1/alerts/{id}/acknowledge
"""

import logging
from typing import List, Optional
from uuid import UUID
from datetime import datetime, timezone

import httpx
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.models.alert import Alert, AlertStatus
from app.models.risk_prediction import RiskPrediction
from app.schemas.alert import AlertResponse, AlertAcknowledgeRequest
from app.routers.websocket import manager

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/alerts", tags=["Early Warning Alerts"])


async def _attach_coordinates(db: AsyncSession, alerts: List[Alert]) -> List[AlertResponse]:
    """
    Populates AlertResponse.latitude/longitude from the most recent
    risk_predictions row for each alert's area_id (audit §5.9) - Alert
    itself carries no coordinate, only the geohash area_id that produced
    it, and risk_predictions.area_id is the same geohash M1/M3 already
    write on every prediction (app/services/ml_service.py).

    Done as one grouped query for every area_id in the batch rather than
    a per-alert lookup, so listing N alerts costs one extra query, not N.
    """
    area_ids = {a.area_id for a in alerts if a.area_id}
    coords_by_area: dict[str, tuple[float, float]] = {}
    if area_ids:
        latest_ts_subq = (
            select(
                RiskPrediction.area_id,
                func.max(RiskPrediction.prediction_timestamp).label("max_ts"),
            )
            .where(RiskPrediction.area_id.in_(area_ids))
            .group_by(RiskPrediction.area_id)
            .subquery()
        )
        rows = await db.execute(
            select(RiskPrediction.area_id, RiskPrediction.latitude, RiskPrediction.longitude)
            .join(
                latest_ts_subq,
                (RiskPrediction.area_id == latest_ts_subq.c.area_id)
                & (RiskPrediction.prediction_timestamp == latest_ts_subq.c.max_ts),
            )
        )
        for area_id, lat, lon in rows.all():
            coords_by_area[area_id] = (lat, lon)

    responses = []
    for alert in alerts:
        resp = AlertResponse.model_validate(alert)
        coords = coords_by_area.get(alert.area_id)
        if coords:
            resp.latitude, resp.longitude = coords
        responses.append(resp)
    return responses


@router.get("", response_model=List[AlertResponse])
async def list_alerts(
    status_filter: Optional[AlertStatus] = Query(None, alias="status"),
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
):
    """
    Get active and historical early warning alerts (reads directly from M5-owned alerts table).
    """
    query = select(Alert)
    if status_filter:
        query = query.where(Alert.lifecycle_status == status_filter.value)
    query = query.order_by(Alert.created_at.desc()).limit(limit)

    result = await db.execute(query)
    alerts = result.scalars().all()
    return await _attach_coordinates(db, alerts)


@router.get("/{alert_id}", response_model=AlertResponse)
async def get_alert_by_id(
    alert_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """
    Get single alert details by UUID.
    """
    result = await db.execute(select(Alert).where(Alert.alert_id == alert_id))
    alert = result.scalar_one_or_none()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    responses = await _attach_coordinates(db, [alert])
    return responses[0]


@router.post("/{alert_id}/acknowledge", response_model=AlertResponse)
async def acknowledge_alert(
    alert_id: UUID,
    ack_in: AlertAcknowledgeRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Acknowledge an emergency alert.
    Delegates the authoritative state transition to M5's lifecycle API -
    M5 owns alert lifecycle transitions, so an unreachable or rejecting M5
    is surfaced as an error here rather than papered over with a local
    write to a table M3 doesn't own (audit §5.13) - and broadcasts the
    event in real-time to M4 GIS Dashboard.
    """
    result = await db.execute(select(Alert).where(Alert.alert_id == alert_id))
    alert = result.scalar_one_or_none()
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")

    settings = get_settings()

    # Authoritative state transition belongs to M5 (it owns alert lifecycle
    # transitions - see the non-negotiable constraints). The previous local
    # `alert.lifecycle_status = ACKNOWLEDGED` write-through here mutated a
    # table M3 doesn't own whenever M5 was unreachable, silently faking a
    # transition M5 never actually made (audit §5.13). Now an unreachable
    # M5 is a real error, not a fallback.
    try:
        async with httpx.AsyncClient(timeout=settings.M5_WEBHOOK_TIMEOUT_SECONDS) as client:
            resp = await client.post(
                f"{settings.M5_BASE_URL}/internal/lifecycle/acknowledge",
                headers={
                    "X-Internal-Service-Key": settings.M5_SERVICE_KEY,
                    "Content-Type": "application/json",
                },
                json={"alert_id": str(alert_id)},
            )
    except Exception as e:
        logger.error("M5 lifecycle service unreachable while acknowledging alert %s: %s", alert_id, e)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Alert lifecycle service (M5) is unreachable - could not acknowledge alert.",
        )

    if resp.status_code != 200:
        logger.error(
            "M5 lifecycle service rejected acknowledge for alert %s: HTTP %s %s",
            alert_id, resp.status_code, resp.text,
        )
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Alert lifecycle service (M5) rejected the acknowledge request.",
        )

    # M5 committed the transition - refresh our read-only copy of the row.
    await db.refresh(alert)

    # Real-time WebSocket push broadcast to all connected GIS Dashboards & mobile users
    await manager.broadcast({
        "event": "ALERT_ACKNOWLEDGED",
        "data": {
            "alert_id": str(alert.alert_id),
            "area_id": alert.area_id,
            "severity": alert.severity,
            "status": alert.status,
            "acknowledged_by": str(current_user.id),
            "acknowledged_at": datetime.now(timezone.utc).isoformat(),
            "remarks": ack_in.remarks,
        },
    })

    return (await _attach_coordinates(db, [alert]))[0]
