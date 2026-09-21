"""
app/models/landslide_inventory.py

Historical landslide records database.
"""

import uuid
from datetime import datetime

from geoalchemy2 import Geometry
from sqlalchemy import String, Float, DateTime, Text, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class LandslideInventory(Base):
    __tablename__ = "landslide_inventory"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    event_date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    location_name: Mapped[str] = mapped_column(String(255), nullable=False)
    
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)

    location: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=False
    )
    
    trigger_type: Mapped[str] = mapped_column(String(100), nullable=False)  # HEAVY_RAINFALL, EARTHQUAKE, ROAD_CUTTING
    severity: Mapped[str] = mapped_column(String(50), nullable=False)        # MINOR, MAJOR, CATASTROPHIC
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


Index("idx_landslide_inventory_location", LandslideInventory.location, postgresql_using="gist")
