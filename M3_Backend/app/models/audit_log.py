"""
app/models/audit_log.py

Append-only audit log table for system security, verification, and compliance.
"""

import uuid
from datetime import datetime

from sqlalchemy import String, DateTime, JSON, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True
    )
    
    action: Mapped[str] = mapped_column(String(100), nullable=False, index=True)  # REPORT_SUBMITTED, REPORT_VERIFIED, ALERT_TRIGGERED, etc.
    entity_type: Mapped[str] = mapped_column(String(100), nullable=False)          # FieldReport, Alert, User
    entity_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    
    details: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    ip_address: Mapped[str | None] = mapped_column(String(45), nullable=True)

    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )
