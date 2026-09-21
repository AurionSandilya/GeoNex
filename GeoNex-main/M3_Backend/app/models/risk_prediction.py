"""
app/models/risk_prediction.py

SQLAlchemy model for ML risk predictions (M1 contract & M5 Alert Engine integration).
M3 is the schema authority for risk_predictions; M5 reads from this table.
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum

from geoalchemy2 import Geometry
from sqlalchemy import String, Float, DateTime, JSON, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, synonym

from app.core.database import Base


class RiskLevel(str, PyEnum):
    NORMAL = "NORMAL"
    WATCH = "WATCH"
    WARNING = "WARNING"
    CRITICAL = "CRITICAL"
    # Legacy alias
    LOW = "NORMAL"


class RiskPrediction(Base):
    __tablename__ = "risk_predictions"

    # M5 authoritative primary key name: prediction_id
    prediction_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )

    # M5 monitoring area identifier (e.g. geohash or zone id)
    area_id: Mapped[str] = mapped_column(String(64), nullable=False, index=True)

    # Core scores aligned with M5
    risk_score: Mapped[float] = mapped_column(Float, nullable=False)  # 0.0 to 1.0
    risk_band: Mapped[str] = mapped_column(String(30), nullable=False, index=True)  # NORMAL, WATCH, WARNING, CRITICAL
    confidence: Mapped[float | None] = mapped_column(Float, nullable=True)  # 0.0 to 1.0
    prediction_timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    model_version: Mapped[str | None] = mapped_column(String(50), nullable=True)

    # Spatial coordinates & PostGIS geometry for GIS visualization
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    location: Mapped[str | None] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=True
    )

    # Feature values used to generate this prediction (contract from M1)
    feature_snapshot: Mapped[dict | None] = mapped_column(JSON, nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False, index=True
    )

    # Synonym for backward compatibility with existing M3 code using prediction.id
    id = synonym("prediction_id")

    @property
    def risk_level(self) -> str:
        return self.risk_band


Index("idx_risk_predictions_location", RiskPrediction.location, postgresql_using="gist")
Index("ix_risk_predictions_area_id", RiskPrediction.area_id)
Index("ix_risk_predictions_created_at", RiskPrediction.created_at)
