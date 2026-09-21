"""
app/models/observation.py

SQLAlchemy models for environmental data feeds (M5 adapters):
- Rainfall observations
- Soil moisture observations
- SAR (Synthetic Aperture Radar) satellite observations
"""

import uuid
from datetime import datetime

from geoalchemy2 import Geometry
from sqlalchemy import String, Float, DateTime, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class RainfallObservation(Base):
    __tablename__ = "rainfall_observations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    station_id: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    location: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=False
    )
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)

    rainfall_1h: Mapped[float] = mapped_column(Float, nullable=False)   # mm
    rainfall_24h: Mapped[float] = mapped_column(Float, nullable=False)  # mm
    rainfall_3d: Mapped[float] = mapped_column(Float, nullable=False)   # mm
    rainfall_7d: Mapped[float] = mapped_column(Float, nullable=False)   # mm

    observed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class SoilMoistureObservation(Base):
    __tablename__ = "soil_moisture_observations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    sensor_id: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    location: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=False
    )
    volumetric_water_content: Mapped[float] = mapped_column(Float, nullable=False)  # % or m3/m3
    soil_depth_cm: Mapped[float] = mapped_column(Float, default=10.0, nullable=False)

    observed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class SARObservation(Base):
    __tablename__ = "sar_observations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    satellite: Mapped[str] = mapped_column(String(50), default="Sentinel-1", nullable=False)
    bounding_box: Mapped[str] = mapped_column(
        Geometry(geometry_type="POLYGON", srid=4326), nullable=False
    )
    coherence_loss: Mapped[float] = mapped_column(Float, nullable=False)  # deformation / change metric
    displacement_mm: Mapped[float] = mapped_column(Float, nullable=False)

    acquired_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)


Index("idx_rainfall_obs_location", RainfallObservation.location, postgresql_using="gist")
Index("idx_soil_obs_location", SoilMoistureObservation.location, postgresql_using="gist")
Index("idx_sar_obs_bbox", SARObservation.bounding_box, postgresql_using="gist")
