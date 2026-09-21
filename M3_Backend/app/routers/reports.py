"""
app/routers/reports.py

Field Reports API Endpoints:
- POST /api/v1/reports (Citizen/Field report creation with PostGIS POINT & Idempotency)
- GET /api/v1/reports (Paginated list with spatial & status filtering)
- GET /api/v1/reports/geojson (M4 Dashboard FeatureCollection)
- GET /api/v1/reports/{id} (Single report lookup)
- POST /api/v1/reports/{id}/verify (M6 Officer verification)
"""

from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, require_roles
from app.models.user import User, UserRole
from app.models.field_report import FieldReport, ReportStatus, ReportType
from app.models.field_verification import FieldVerification
from app.schemas.field_report import (
    FieldReportCreate,
    FieldReportResponse,
    GeoJSONFeatureCollection,
    GeoJSONFeature,
    GeoJSONGeometry,
)
from app.schemas.field_verification import VerificationRequest, VerificationResponse
from app.routers.websocket import manager

router = APIRouter(prefix="/reports", tags=["Field Reports"])


@router.post("", response_model=FieldReportResponse, status_code=status.HTTP_201_CREATED)
async def create_field_report(
    report_in: FieldReportCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Submit a geo-tagged landslide/field report (M2 mobile app endpoint).
    Supports PostGIS POINT creation (SRID 4326) and Idempotent Offline Sync.
    """
    # client_report_id is a VARCHAR column in the migrated schema (see
    # models/field_report.py) - the Pydantic schema validates it as a UUID
    # for the caller's benefit, but it must be cast to str before use in a
    # query/insert or asyncpg infers a `::uuid` bind type and Postgres
    # rejects the `varchar = uuid` comparison.
    client_report_id_str = str(report_in.client_report_id) if report_in.client_report_id else None

    if client_report_id_str:
        existing = await db.execute(
            select(FieldReport)
            .options(selectinload(FieldReport.media))
            .where(FieldReport.client_report_id == client_report_id_str)
        )
        existing_report = existing.scalar_one_or_none()
        if existing_report:
            return existing_report

    point_geom = f"SRID=4326;POINT({report_in.longitude} {report_in.latitude})"

    report = FieldReport(
        user_id=current_user.id,
        client_report_id=client_report_id_str,
        report_type=report_in.report_type,
        description=report_in.description,
        latitude=report_in.latitude,
        longitude=report_in.longitude,
        location=point_geom,
        capture_timestamp=report_in.capture_timestamp,
        status=ReportStatus.PENDING,
    )
    db.add(report)
    await db.commit()
    # Re-fetch with `media` eagerly loaded (selectinload) rather than
    # `db.refresh` + bare attribute access: `db.refresh` only reloads scalar
    # columns, and assigning to (or lazily reading) the unloaded `media`
    # relationship outside an explicit await raises `MissingGreenlet` -
    # cascade="all, delete-orphan" on that relationship means even setting
    # it to `[]` first loads the existing (empty) collection to diff against.
    result = await db.execute(
        select(FieldReport).options(selectinload(FieldReport.media)).where(FieldReport.id == report.id)
    )
    report = result.scalar_one()

    # Real-time WebSocket notification to M4 GIS Dashboard
    await manager.broadcast({
        "event": "NEW_FIELD_REPORT",
        "data": {
            "report_id": str(report.id),
            "report_type": report.report_type.value if hasattr(report.report_type, "value") else str(report.report_type),
            "latitude": report.latitude,
            "longitude": report.longitude,
            "status": report.status.value if hasattr(report.status, "value") else str(report.status),
            "created_at": report.created_at.isoformat() if report.created_at else None,
        }
    })

    return report


@router.get("", response_model=List[FieldReportResponse])
async def list_reports(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=500),
    status_filter: Optional[ReportStatus] = Query(None, alias="status"),
    report_type: Optional[ReportType] = Query(None),
    db: AsyncSession = Depends(get_db),
):
    """
    List field reports with pagination and status filtering.
    """
    try:
        query = select(FieldReport)
        if status_filter:
            query = query.where(FieldReport.status == status_filter)
        if report_type:
            query = query.where(FieldReport.report_type == report_type)

        query = query.order_by(FieldReport.created_at.desc()).offset(skip).limit(limit)
        result = await db.execute(query)
        return result.scalars().all()
    except Exception:
        return []


@router.get("/geojson", response_model=GeoJSONFeatureCollection)
async def get_reports_geojson(
    status_filter: Optional[ReportStatus] = Query(None, alias="status"),
    db: AsyncSession = Depends(get_db),
):
    """
    Returns field reports as standard GeoJSON FeatureCollection for M4 Dashboard.
    """
    # Previously wrapped in try/except Exception: reports = [] and, on an
    # empty result, substituted a fabricated demonstration feature - a real
    # DB error was silently swallowed and rendered indistinguishable from a
    # genuine "zero reports" state (audit §5.12). A DB error now propagates
    # as a 5xx, and an empty table returns a real, empty FeatureCollection.
    query = select(FieldReport)
    if status_filter:
        query = query.where(FieldReport.status == status_filter)

    result = await db.execute(query)
    reports = result.scalars().all()

    features = [
        GeoJSONFeature(
            type="Feature",
            geometry=GeoJSONGeometry(
                type="Point",
                coordinates=[r.longitude, r.latitude],
            ),
            properties={
                "id": str(r.id),
                "report_type": r.report_type.value,
                "status": r.status.value,
                "description": r.description,
                "capture_timestamp": r.capture_timestamp.isoformat(),
            },
        )
        for r in reports
    ]

    return GeoJSONFeatureCollection(type="FeatureCollection", features=features)


@router.get("/{report_id}", response_model=FieldReportResponse)
async def get_report_by_id(
    report_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """
    Get report details by UUID.
    """
    result = await db.execute(select(FieldReport).where(FieldReport.id == report_id))
    report = result.scalar_one_or_none()
    if not report:
        raise HTTPException(status_code=404, detail="Field report not found")
    return report


@router.post("/{report_id}/verify", response_model=VerificationResponse)
async def verify_report(
    report_id: UUID,
    verify_in: VerificationRequest,
    current_user: User = Depends(require_roles([UserRole.FIELD_OFFICER, UserRole.ADMIN, UserRole.DISTRICT_ADMIN])),
    db: AsyncSession = Depends(get_db),
):
    """
    Field Officer verification workflow (M6 role-restricted endpoint).
    """
    result = await db.execute(select(FieldReport).where(FieldReport.id == report_id))
    report = result.scalar_one_or_none()
    if not report:
        raise HTTPException(status_code=404, detail="Field report not found")

    if verify_in.decision == "VERIFY":
        report.status = ReportStatus.VERIFIED
    elif verify_in.decision == "REJECT":
        report.status = ReportStatus.REJECTED
    else:
        report.status = ReportStatus.NEEDS_INFORMATION

    verification = FieldVerification(
        report_id=report.id,
        officer_id=current_user.id,
        decision=verify_in.decision,
        remarks=verify_in.remarks,
    )
    db.add(verification)
    await db.commit()
    await db.refresh(verification)

    # Real-time WebSocket notification of report verification
    await manager.broadcast({
        "event": "REPORT_VERIFIED",
        "data": {
            "report_id": str(report.id),
            "status": report.status.value if hasattr(report.status, "value") else str(report.status),
            "decision": verify_in.decision,
            "officer_id": str(current_user.id),
            "remarks": verify_in.remarks,
        }
    })

    return verification
