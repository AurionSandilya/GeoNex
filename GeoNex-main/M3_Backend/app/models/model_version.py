"""
app/models/model_version.py

ML Model Registry table to track versioning of M1 ML engine models.
"""

import uuid
from datetime import datetime

from sqlalchemy import String, Boolean, DateTime, JSON, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class ModelVersion(Base):
    __tablename__ = "model_versions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    version: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    model_name: Mapped[str] = mapped_column(String(100), default="LandslideSusceptibilityXGBoost", nullable=False)
    
    artifact_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    features_list: Mapped[list | None] = mapped_column(JSON, nullable=True)
    metrics: Mapped[dict | None] = mapped_column(JSON, nullable=True)  # { "auc": 0.91, "f1": 0.88 }
    
    is_active: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    trained_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
