"""
app/schemas/alert.py

Pydantic schemas for early warning alerts (M5).
"""

from datetime import datetime
from uuid import UUID
from typing import Optional
from pydantic import BaseModel

from app.models.risk_prediction import RiskLevel
from app.models.alert import AlertStatus


class AlertResponse(BaseModel):
    id: UUID
    area_id: Optional[str] = None
    severity: Optional[str] = None
    status: Optional[str] = None
    current_severity: Optional[str] = None
    lifecycle_status: Optional[str] = None
    title: Optional[str] = None
    message: Optional[str] = None
    last_risk_score: Optional[float] = None
    # Populated by joining area_id against the most recent risk_predictions
    # row for that area (see app/routers/alerts.py) - previously absent, so
    # M4's dashboard rendered every alert at one fixed placeholder point
    # (audit §5.9).
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    created_at: datetime
    acknowledged_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class AlertAcknowledgeRequest(BaseModel):
    remarks: Optional[str] = None
