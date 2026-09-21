"""
app/models/field_verification.py

SQLAlchemy model for field officer verifications (M6 workflow).
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum

from sqlalchemy import Text, DateTime, Enum, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class VerificationDecision(str, PyEnum):
    VERIFY = "VERIFY"
    REJECT = "REJECT"
    NEEDS_INFORMATION = "NEEDS_INFORMATION"


class FieldVerification(Base):
    __tablename__ = "field_verifications"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    report_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("field_reports.id", ondelete="CASCADE"), unique=True, nullable=False
    )
    officer_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="RESTRICT"), nullable=False
    )
    
    decision: Mapped[VerificationDecision] = mapped_column(
        Enum(VerificationDecision, name="verification_decision", native_enum=False, length=50), nullable=False
    )
    remarks: Mapped[str] = mapped_column(Text, nullable=False)
    
    verified_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationships
    report = relationship("FieldReport", back_populates="verification")
    officer = relationship("User", back_populates="verifications")
