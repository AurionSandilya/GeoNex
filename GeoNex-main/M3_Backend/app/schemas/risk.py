"""
app/schemas/risk.py

Pydantic schemas for M1 ML Risk API responses & contracts.
"""

from datetime import datetime
from uuid import UUID
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field

from app.models.risk_prediction import RiskLevel


class RiskLocationQuery(BaseModel):
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)


class RiskResponse(BaseModel):
    id: Optional[UUID] = None
    prediction_id: Optional[UUID] = None
    area_id: Optional[str] = None
    latitude: float
    longitude: float
    risk_score: float = Field(..., ge=0.0, le=1.0)
    risk_level: str
    risk_band: Optional[str] = None
    confidence: Optional[float] = Field(None, ge=0.0, le=1.0)
    model_version: Optional[str] = "v1.0"
    feature_snapshot: Optional[Dict[str, Any]] = None
    timestamp: datetime

    class Config:
        from_attributes = True


class RiskAreaQuery(BaseModel):
    min_lat: float = Field(..., ge=-90.0, le=90.0)
    max_lat: float = Field(..., ge=-90.0, le=90.0)
    min_lon: float = Field(..., ge=-180.0, le=180.0)
    max_lon: float = Field(..., ge=-180.0, le=180.0)
