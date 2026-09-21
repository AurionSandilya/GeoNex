"""
app/models/alert.py

Read-only SQLAlchemy model for M5-owned Early Warning Alerts.
M5 is the authoritative owner of the `alerts` table and delivery records.
M3 reads from this table directly using this schema-aligned model,
and delegates state transitions (e.g. acknowledge) to M5's lifecycle API.

This model is defined on a detached MetaData instance (M5Base) so that
M3 Alembic autogenerate migrations do not manage or drop M5's tables.
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum
from typing import Optional

from sqlalchemy import Column, String, Float, Integer, DateTime, Enum, MetaData
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base

m5_metadata = MetaData()
M5Base = declarative_base(metadata=m5_metadata)


class AlertSeverity(str, PyEnum):
    NORMAL = "NORMAL"
    WATCH = "WATCH"
    WARNING = "WARNING"
    CRITICAL = "CRITICAL"


class LifecycleStatus(str, PyEnum):
    ACTIVE = "ACTIVE"
    ACKNOWLEDGED = "ACKNOWLEDGED"
    RESOLVED = "RESOLVED"
    CANCELLED = "CANCELLED"
    EXPIRED = "EXPIRED"


# Backward compatibility aliases for existing M3 callers
AlertStatus = LifecycleStatus
RiskLevel = AlertSeverity


class Alert(M5Base):
    """
    Read-only view of M5's authoritative alerts table.
    """
    __tablename__ = "alerts"

    alert_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    area_id = Column(String, nullable=False, index=True)

    current_severity = Column(Enum(AlertSeverity, name="severity", native_enum=False), nullable=False)
    candidate_severity = Column(Enum(AlertSeverity, name="severity", native_enum=False), nullable=True)
    candidate_since = Column(DateTime(timezone=True), nullable=True)
    candidate_confirmations = Column(Integer, default=0, nullable=False)

    lifecycle_status = Column(
        Enum(LifecycleStatus, name="lifecycle_status", native_enum=False),
        nullable=False,
        default=LifecycleStatus.ACTIVE,
        index=True,
    )

    band_entered_at = Column(DateTime(timezone=True), nullable=True)
    last_prediction_timestamp = Column(DateTime(timezone=True), nullable=True)
    last_evaluated_prediction_timestamp = Column(DateTime(timezone=True), nullable=True)
    last_evaluated_created_at = Column(DateTime(timezone=True), nullable=True)
    last_evaluated_prediction_id = Column(UUID(as_uuid=True), nullable=True)

    last_risk_score = Column(Float, nullable=True)
    last_confidence = Column(Float, nullable=True)

    created_at = Column(DateTime(timezone=True), nullable=False, index=True)
    updated_at = Column(DateTime(timezone=True), nullable=False)
    resolved_at = Column(DateTime(timezone=True), nullable=True)
    cancelled_at = Column(DateTime(timezone=True), nullable=True)
    expired_at = Column(DateTime(timezone=True), nullable=True)

    # -------------------------------------------------------------------------
    # Compatibility properties for M2 Flutter & M4 GIS Dashboard
    # -------------------------------------------------------------------------
    @property
    def id(self) -> uuid.UUID:
        return self.alert_id

    @property
    def severity(self) -> str:
        return self.current_severity.value if hasattr(self.current_severity, "value") else str(self.current_severity)

    @property
    def status(self) -> str:
        return self.lifecycle_status.value if hasattr(self.lifecycle_status, "value") else str(self.lifecycle_status)

    @property
    def acknowledged_at(self) -> Optional[datetime]:
        if self.lifecycle_status == LifecycleStatus.ACKNOWLEDGED:
            return self.updated_at
        return None

    @property
    def title(self) -> str:
        sev = self.severity
        return f"Landslide {sev} Alert — Area {self.area_id}"

    @property
    def message(self) -> str:
        sev = self.severity
        score_info = f" (Score: {self.last_risk_score:.2f})" if self.last_risk_score is not None else ""
        return f"Landslide risk evaluated at {sev}{score_info} for monitoring zone {self.area_id}."
