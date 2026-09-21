"""
app/models/earthquake.py

SQLAlchemy model for earthquake observations (M5 adapter).
"""

import uuid
from datetime import datetime

from geoalchemy2 import Geometry
from sqlalchemy import String, Float, DateTime, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class EarthquakeEvent(Base):
    __tablename__ = "earthquake_events"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    event_id: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    magnitude: Mapped[float] = mapped_column(Float, nullable=False)
    depth_km: Mapped[float] = mapped_column(Float, nullable=False)

    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    epicenter: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=False
    )
    location_name: Mapped[str] = mapped_column(String(255), nullable=False)

    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)


Index("idx_earthquake_epicenter", EarthquakeEvent.epicenter, postgresql_using="gist")
