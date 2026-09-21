"""
app/schemas/field_verification.py

Pydantic schemas for officer verification actions.
"""

from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field

from app.models.field_verification import VerificationDecision


class VerificationRequest(BaseModel):
    decision: VerificationDecision
    remarks: str = Field(..., min_length=2, max_length=1000)


class VerificationResponse(BaseModel):
    id: UUID
    report_id: UUID
    officer_id: UUID
    decision: VerificationDecision
    remarks: str
    verified_at: datetime

    class Config:
        from_attributes = True
