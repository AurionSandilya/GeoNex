"""
app/models/field_report.py

SQLAlchemy 2.x model for citizen and field officer landslide reports.
Includes PostGIS POINT geometry (SRID 4326) and idempotency support.
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum

from geoalchemy2 import Geometry
from sqlalchemy import String, Text, Float, DateTime, Enum, ForeignKey, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class ReportType(str, PyEnum):
    CRACK = "CRACK"
    ROCKFALL = "ROCKFALL"
    LANDSLIDE = "LANDSLIDE"
    DEBRIS = "DEBRIS"
    ROAD_DAMAGE = "ROAD_DAMAGE"
    WATER_SEEPAGE = "WATER_SEEPAGE"
    OTHER = "OTHER"


class ReportStatus(str, PyEnum):
    PENDING = "PENDING"
    VERIFIED = "VERIFIED"
    REJECTED = "REJECTED"
    NEEDS_INFORMATION = "NEEDS_INFORMATION"


class FieldReport(Base):
    __tablename__ = "field_reports"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    
    # Offline Sync & Idempotency Key from client. Migrated as a plain
    # VARCHAR(100) (see migrations/versions/0001_initial_m3_schema.py) -
    # comparing/inserting a Python UUID object against that column made
    # asyncpg raise `operator does not exist: character varying = uuid`.
    # Stored as a string here to match the real migrated schema; the API
    # schema (FieldReportCreate/-Response) still validates it as a UUID.
    client_report_id: Mapped[str | None] = mapped_column(
        String(100), unique=True, index=True, nullable=True
    )

    report_type: Mapped[ReportType] = mapped_column(
        Enum(ReportType, name="report_type", native_enum=False, length=50), nullable=False
    )
    status: Mapped[ReportStatus] = mapped_column(
        Enum(ReportStatus, name="report_status", native_enum=False, length=50),
        default=ReportStatus.PENDING, nullable=False, index=True,
    )
    description: Mapped[str] = mapped_column(Text, nullable=False)

    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    
    # PostGIS Spatial Point (SRID 4326)
    location: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=False
    )

    capture_timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    # Relationships
    user = relationship("User", back_populates="reports")
    media = relationship("Media", back_populates="report", cascade="all, delete-orphan")
    verification = relationship("FieldVerification", back_populates="report", uselist=False)


# GIST Spatial Index on location
Index("idx_field_reports_location", FieldReport.location, postgresql_using="gist")
