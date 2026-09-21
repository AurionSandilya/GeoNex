"""
app/routers/risk.py

Risk Prediction API Endpoints (M1 ML & M5 Alert Engine Interface):
- GET /api/v1/risk/location?lat=27.55&lon=93.65
- POST /api/v1/risk/predict
- GET /api/v1/risk/area?min_lat=...&max_lat=...&min_lon=...&max_lon=...
"""

import logging
from datetime import datetime, timezone
from typing import List, Optional, Dict, Any

import httpx
from fastapi import APIRouter, Depends, Query, HTTPException, Body
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.database import get_db
from app.models.risk_prediction import RiskPrediction
from app.services.ml_service import ml_service
from app.schemas.risk import RiskResponse
from app.schemas.field_report import GeoJSONFeatureCollection, GeoJSONFeature, GeoJSONGeometry
from app.routers.websocket import manager

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/risk", tags=["Landslide Risk"])


@router.get("/location", response_model=RiskResponse)
async def get_risk_by_location(
    lat: float = Query(..., ge=-90.0, le=90.0, description="Latitude (e.g. 27.55)"),
    lon: float = Query(..., ge=-180.0, le=180.0, description="Longitude (e.g. 93.65)"),
    rainfall_24h: float = Query(45.0, description="Recent 24h rainfall in mm"),
    slope: float = Query(25.0, description="Terrain slope in degrees"),
    soil_moisture: float = Query(0.42, description="Soil volumetric moisture ratio 0.0-1.0"),
    db: AsyncSession = Depends(get_db),
):
    """
    Get AI risk prediction for a coordinate, persist committed row to DB,
    and dispatch internal risk event to M5 Alert Engine.
    """
    features = {
        "latitude": lat,
        "longitude": lon,
        "rainfall_24h": rainfall_24h,
        "slope": slope,
        "soil_moisture": soil_moisture,
    }

    prediction = await ml_service.predict_risk(features)

    # Persist prediction to shared PostgreSQL database for M5 authoritative re-read
    db_prediction = RiskPrediction(
        area_id=prediction["area_id"],
        latitude=lat,
        longitude=lon,
        # Populates the PostGIS point column from the same lat/lon already
        # stored as plain floats above, using the pattern already used
        # correctly in app/routers/reports.py - previously left NULL, which
        # made the idx_risk_predictions_location GIST index useless (audit
        # §5.16).
        location=f"SRID=4326;POINT({lon} {lat})",
        risk_score=prediction["risk_score"],
        risk_band=prediction["risk_band"],
        confidence=prediction.get("confidence"),
        model_version=prediction.get("model_version"),
        feature_snapshot=prediction.get("feature_snapshot"),
        prediction_timestamp=datetime.now(timezone.utc),
    )

    # A failed insert here used to be swallowed (log + rollback) and the
    # endpoint still returned 200 with a RiskResponse built from an object
    # that was never actually persisted - so M5's reconciler had nothing to
    # find, and the response silently misrepresented what happened (audit
    # §5.14). It now surfaces as a real 503.
    try:
        db.add(db_prediction)
        await db.commit()
        await db.refresh(db_prediction)
    except Exception as exc:
        logger.error("Database insert failed for RiskPrediction (area=%s): %s", prediction["area_id"], exc)
        await db.rollback()
        raise HTTPException(
            status_code=503,
            detail="Failed to persist risk prediction - not forwarded to alert engine.",
        )

    # Step 5: Notify M5 Alert Engine via service-to-service internal webhook
    if getattr(db_prediction, "prediction_id", None):
        settings = get_settings()
        try:
            async with httpx.AsyncClient(timeout=settings.M5_WEBHOOK_TIMEOUT_SECONDS) as client:
                await client.post(
                    f"{settings.M5_BASE_URL}/internal/risk-event",
                    headers={
                        "X-Internal-Service-Key": settings.M5_SERVICE_KEY,
                        "Content-Type": "application/json",
                    },
                    json={
                        "prediction_id": str(db_prediction.prediction_id),
                        "area_id": db_prediction.area_id,
                    },
                )
        except Exception as e:
            logger.info("M5 webhook skipped or unreachable (%s). M5 reconciler will catch up.", e)

    # Broadcast real-time risk update via WebSocket to connected GIS Dashboards
    await manager.broadcast({
        "event": "RISK_PREDICTION_UPDATED",
        "data": {
            "prediction_id": str(getattr(db_prediction, "prediction_id", "")),
            "area_id": prediction["area_id"],
            "latitude": lat,
            "longitude": lon,
            "risk_score": prediction["risk_score"],
            "risk_band": prediction["risk_band"],
            "risk_level": prediction["risk_level"],
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    })

    return RiskResponse(
        id=getattr(db_prediction, "prediction_id", None),
        prediction_id=getattr(db_prediction, "prediction_id", None),
        area_id=prediction["area_id"],
        latitude=lat,
        longitude=lon,
        risk_score=prediction["risk_score"],
        risk_level=prediction["risk_level"],
        risk_band=prediction["risk_band"],
        confidence=prediction["confidence"],
        model_version=prediction["model_version"],
        feature_snapshot=prediction["feature_snapshot"],
        timestamp=datetime.now(timezone.utc),
    )


@router.post("/predict", response_model=RiskResponse)
async def predict_custom_risk(
    features: Dict[str, Any] = Body(..., example={"latitude": 27.55, "longitude": 93.65, "rainfall_24h": 50.0, "slope": 30.0}),
    db: AsyncSession = Depends(get_db),
):
    """
    Direct model evaluation with arbitrary feature dictionaries (supports full M1 schema).
    """
    prediction = await ml_service.predict_risk(features)
    lat = float(features.get("latitude", 27.55))
    lon = float(features.get("longitude", 93.65))

    db_prediction = RiskPrediction(
        area_id=prediction["area_id"],
        latitude=lat,
        longitude=lon,
        location=f"SRID=4326;POINT({lon} {lat})",
        risk_score=prediction["risk_score"],
        risk_band=prediction["risk_band"],
        confidence=prediction.get("confidence"),
        model_version=prediction.get("model_version"),
        feature_snapshot=prediction.get("feature_snapshot"),
        prediction_timestamp=datetime.now(timezone.utc),
    )

    try:
        db.add(db_prediction)
        await db.commit()
        await db.refresh(db_prediction)
    except Exception as exc:
        logger.error("Database insert failed for RiskPrediction (area=%s): %s", prediction["area_id"], exc)
        await db.rollback()
        raise HTTPException(
            status_code=503,
            detail="Failed to persist risk prediction - not forwarded to alert engine.",
        )

    if getattr(db_prediction, "prediction_id", None):
        settings = get_settings()
        try:
            async with httpx.AsyncClient(timeout=settings.M5_WEBHOOK_TIMEOUT_SECONDS) as client:
                await client.post(
                    f"{settings.M5_BASE_URL}/internal/risk-event",
                    headers={
                        "X-Internal-Service-Key": settings.M5_SERVICE_KEY,
                        "Content-Type": "application/json",
                    },
                    json={
                        "prediction_id": str(db_prediction.prediction_id),
                        "area_id": db_prediction.area_id,
                    },
                )
        except Exception:
            pass

    return RiskResponse(
        id=getattr(db_prediction, "prediction_id", None),
        prediction_id=getattr(db_prediction, "prediction_id", None),
        area_id=prediction["area_id"],
        latitude=lat,
        longitude=lon,
        risk_score=prediction["risk_score"],
        risk_level=prediction["risk_level"],
        risk_band=prediction["risk_band"],
        confidence=prediction["confidence"],
        model_version=prediction["model_version"],
        feature_snapshot=prediction["feature_snapshot"],
        timestamp=datetime.now(timezone.utc),
    )


@router.get("/area", response_model=GeoJSONFeatureCollection)
async def get_risk_area(
    min_lat: float = Query(26.0, ge=-90.0, le=90.0),
    max_lat: float = Query(28.0, ge=-90.0, le=90.0),
    min_lon: float = Query(91.0, ge=-180.0, le=180.0),
    max_lon: float = Query(94.0, ge=-180.0, le=180.0),
):
    """
    Get spatial grid of risk levels as GeoJSON FeatureCollection for bounding box (M4 GIS Dashboard layer).
    """
    features = []
    lat_steps = 3
    lon_steps = 3
    lat_delta = (max_lat - min_lat) / lat_steps
    lon_delta = (max_lon - min_lon) / lon_steps

    for i in range(lat_steps):
        for j in range(lon_steps):
            c_lat = min_lat + (i + 0.5) * lat_delta
            c_lon = min_lon + (j + 0.5) * lon_delta

            pred = await ml_service.predict_risk({
                "latitude": round(c_lat, 4),
                "longitude": round(c_lon, 4),
                "rainfall_24h": 55.0,
                "slope": 30.0,
            })

            feature = GeoJSONFeature(
                type="Feature",
                geometry=GeoJSONGeometry(
                    type="Point",
                    coordinates=[round(c_lon, 4), round(c_lat, 4)],
                ),
                properties={
                    "area_id": pred["area_id"],
                    "risk_score": pred["risk_score"],
                    "risk_level": pred["risk_level"],
                    "risk_band": pred["risk_band"],
                    "confidence": pred["confidence"],
                    "model_version": pred["model_version"],
                },
            )
            features.append(feature)

    return GeoJSONFeatureCollection(type="FeatureCollection", features=features)
