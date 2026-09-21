"""
app/routers/spatial.py

Spatial reference layer APIs for M4 GIS Dashboard:
- GET /api/v1/roads
- GET /api/v1/villages
- GET /api/v1/infrastructure
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from geoalchemy2.shape import to_shape

from app.core.database import get_db
from app.models.spatial import Road, Village, Infrastructure, InfrastructureCategory
from app.schemas.spatial import RoadResponse, VillageResponse, InfrastructureResponse
from app.schemas.field_report import GeoJSONFeatureCollection, GeoJSONFeature, GeoJSONGeometry

router = APIRouter(prefix="", tags=["Spatial Layers (GIS)"])


@router.get("/roads/geojson", response_model=GeoJSONFeatureCollection)
async def get_roads_geojson(db: AsyncSession = Depends(get_db)):
    """
    Returns the real roads layer (LINESTRING) from the `roads` table as
    GeoJSON for M4 Dashboard. Previously this endpoint never queried the
    database at all and always returned two hardcoded sample roads
    regardless of what was actually in the table - a fabricated-data
    pattern the audit flagged for /reports/geojson (§5.12) that turned out
    to apply here too (§5.11/§1.5 - no new mock-data patterns, and no
    silently keeping old ones either).
    """
    result = await db.execute(select(Road))
    roads = result.scalars().all()
    features = []
    for road in roads:
        line = to_shape(road.geometry)
        features.append(GeoJSONFeature(
            type="Feature",
            geometry=GeoJSONGeometry(type="LineString", coordinates=[[x, y] for x, y in line.coords]),
            properties={
                "id": str(road.id),
                "name": road.name,
                "road_number": road.road_number,
                "category": road.category,
                "length_km": road.length_km,
                "surface_type": road.surface_type,
            },
        ))
    return GeoJSONFeatureCollection(type="FeatureCollection", features=features)


@router.get("/villages", response_model=List[VillageResponse])
async def list_villages(
    district: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
):
    """
    Get list of villages with demographic and spatial coordinates.
    """
    query = select(Village)
    if district:
        query = query.where(Village.district == district)
    result = await db.execute(query.limit(limit))
    return result.scalars().all()


@router.get("/infrastructure", response_model=List[InfrastructureResponse])
async def list_infrastructure(
    category: Optional[InfrastructureCategory] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
):
    """
    Get list of critical assets (hospitals, schools, bridges).
    """
    query = select(Infrastructure)
    if category:
        query = query.where(Infrastructure.category == category)
    result = await db.execute(query.limit(limit))
    return result.scalars().all()
