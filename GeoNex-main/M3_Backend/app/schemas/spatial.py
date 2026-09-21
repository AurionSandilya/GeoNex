"""
app/schemas/spatial.py

Pydantic schemas for Road, Village, and Infrastructure layers.
"""

from datetime import datetime
from uuid import UUID
from typing import Optional, List
from pydantic import BaseModel

from app.models.spatial import InfrastructureCategory


class RoadResponse(BaseModel):
    id: UUID
    name: str
    road_number: Optional[str] = None
    category: str

    class Config:
        from_attributes = True


class VillageResponse(BaseModel):
    id: UUID
    name: str
    district: Optional[str] = None
    state: str
    population: Optional[int] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    class Config:
        from_attributes = True


class InfrastructureResponse(BaseModel):
    id: UUID
    name: str
    category: InfrastructureCategory
    district: str
    latitude: float
    longitude: float

    class Config:
        from_attributes = True
