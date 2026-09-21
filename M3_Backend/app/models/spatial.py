"""
app/models/spatial.py

SQLAlchemy models for geographic reference layers:
- Roads (LINESTRING geometry, e.g., NH-44, Border roads in NER)
- Villages / Settlements (POINT geometry)
- Infrastructure / Critical Assets (POINT geometry, e.g., Hospitals, Bridges, Schools)
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum

from geoalchemy2 import Geometry
from geoalchemy2.shape import to_shape
from sqlalchemy import String, Integer, Float, DateTime, Enum, func, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


def _parse_point(geom) -> tuple[float, float] | None:
    """(lon, lat) from a loaded GeoAlchemy2 WKBElement, or None if unset."""
    if geom is None:
        return None
    point = to_shape(geom)
    return (point.x, point.y)


class InfrastructureCategory(str, PyEnum):
    HOSPITAL = "HOSPITAL"
    SCHOOL = "SCHOOL"
    BRIDGE = "BRIDGE"
    GOVERNMENT_BUILDING = "GOVERNMENT_BUILDING"
    POWER_STATION = "POWER_STATION"
    COMMUNICATION_TOWER = "COMMUNICATION_TOWER"
    HELIPAD = "HELIPAD"
    OTHER = "OTHER"


class Road(Base):
    __tablename__ = "roads"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    # Real migrated columns are `road_name`/`road_type`, not `name`/
    # `category` (see migrations/versions/0001_initial_m3_schema.py) -
    # mapped via `name=` below so the API schema (RoadResponse) can keep
    # using the friendlier `name`/`category` attribute names (audit §5.11).
    name: Mapped[str] = mapped_column("road_name", String(255), nullable=False, index=True)
    road_number: Mapped[str | None] = mapped_column(String(100), nullable=True)  # e.g. NH-27
    category: Mapped[str] = mapped_column("road_type", String(100), default="NATIONAL_HIGHWAY", nullable=False)
    length_km: Mapped[float | None] = mapped_column(Float, nullable=True)
    surface_type: Mapped[str | None] = mapped_column(String(50), nullable=True)

    # PostGIS LINESTRING Geometry (SRID 4326)
    geometry: Mapped[str] = mapped_column(
        Geometry(geometry_type="LINESTRING", srid=4326), nullable=False
    )
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class Village(Base):
    __tablename__ = "villages"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    # Real migrated column is `village_name`, not `name` (audit §5.11).
    name: Mapped[str] = mapped_column("village_name", String(255), nullable=False, index=True)
    district: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    block: Mapped[str | None] = mapped_column(String(100), nullable=True)
    population: Mapped[int | None] = mapped_column(Integer, nullable=True)
    households: Mapped[int | None] = mapped_column(Integer, nullable=True)
    landslide_hazard_zone: Mapped[str | None] = mapped_column(String(30), nullable=True)

    # PostGIS POINT Geometry (SRID 4326) - the migrated table has no
    # `state`/`latitude`/`longitude` columns at all, only this geometry
    # column (plus a `boundary` polygon). `latitude`/`longitude` below are
    # computed from it rather than mapped to nonexistent columns.
    location: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=True
    )
    boundary: Mapped[str | None] = mapped_column(
        Geometry(geometry_type="POLYGON", srid=4326), nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # `state` has no backing column in the migrated schema - every place
    # this codebase names a village is within Arunachal Pradesh (NER), so
    # rather than drop the field from the API response (a wider ripple into
    # M4's VillageResponse consumers) this is a fixed, honest constant
    # rather than a per-row DB value that doesn't exist.
    @property
    def state(self) -> str:
        return "Arunachal Pradesh"

    @property
    def latitude(self) -> float | None:
        point = _parse_point(self.location)
        return point[1] if point else None

    @property
    def longitude(self) -> float | None:
        point = _parse_point(self.location)
        return point[0] if point else None


class Infrastructure(Base):
    __tablename__ = "infrastructure"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    category: Mapped[InfrastructureCategory] = mapped_column(
        Enum(InfrastructureCategory, name="infrastructure_category", native_enum=False, length=50), nullable=False, index=True
    )
    district: Mapped[str] = mapped_column(String(100), nullable=False)

    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)

    # PostGIS POINT Geometry (SRID 4326)
    location: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=False
    )

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)


# GIST Spatial Indexes
Index("idx_roads_geometry", Road.geometry, postgresql_using="gist")
Index("idx_villages_location", Village.location, postgresql_using="gist")
Index("idx_infrastructure_location", Infrastructure.location, postgresql_using="gist")
