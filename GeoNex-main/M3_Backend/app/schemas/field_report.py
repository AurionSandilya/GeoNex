"""
app/schemas/field_report.py

Pydantic schemas for field reports, media, verification, and GeoJSON formats.
"""

from datetime import datetime
from uuid import UUID
from typing import Any, List, Optional
from pydantic import BaseModel, Field, field_validator

from app.models.field_report import ReportType, ReportStatus
from app.schemas.media import MediaResponse


class FieldReportCreate(BaseModel):
    report_type: ReportType
    description: str = Field(..., min_length=5, max_length=2000)
    latitude: float = Field(..., ge=-90.0, le=90.0, description="Latitude between -90 and 90")
    longitude: float = Field(..., ge=-180.0, le=180.0, description="Longitude between -180 and 180")
    capture_timestamp: datetime
    
    # Offline sync idempotency key from mobile app
    client_report_id: Optional[UUID] = None


class FieldReportResponse(BaseModel):
    id: UUID
    user_id: UUID
    client_report_id: Optional[UUID] = None
    report_type: ReportType
    status: ReportStatus
    description: str
    latitude: float
    longitude: float
    capture_timestamp: datetime
    created_at: datetime
    updated_at: datetime
    media: List[MediaResponse] = []

    class Config:
        from_attributes = True


# GeoJSON standard schemas for M4 GIS Dashboard
class GeoJSONGeometry(BaseModel):
    type: str = "Point"
    # GeoJSON coordinates are a flat [lon, lat] pair for Point but a nested
    # list of pairs for LineString/Polygon - `List[float]` only fit Point
    # geometries and would reject real road LineString data (audit §5.11:
    # /roads/geojson previously never queried the Road table at all, which
    # is partly why this was never exercised with a non-Point geometry).
    coordinates: Any


class GeoJSONFeature(BaseModel):
    type: str = "Feature"
    geometry: GeoJSONGeometry
    properties: dict[str, Any]


class GeoJSONFeatureCollection(BaseModel):
    type: str = "FeatureCollection"
    features: List[GeoJSONFeature]
