"""
app/models/media.py

SQLAlchemy model for media attachments associated with field reports.
Stores Cloudinary/ImageKit URLs, SHA-256 file hashes, and metadata.
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum

from sqlalchemy import String, Integer, DateTime, Enum, ForeignKey, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class MediaType(str, PyEnum):
    IMAGE = "IMAGE"
    VIDEO = "VIDEO"


class Media(Base):
    __tablename__ = "media"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    report_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("field_reports.id", ondelete="CASCADE"), nullable=False, index=True
    )
    
    # Real migrated columns (see \d media) are `url`, `thumbnail_url`,
    # `file_size_bytes`, `mime_type` - not `media_url`/`file_size`/
    # `file_hash`. Mapping the Python attribute names to the actual
    # `name=` column names below keeps the existing MediaResponse schema
    # surface stable while matching what's really in the database.
    # `file_hash` has no equivalent column in the migrated schema and
    # nothing in the codebase computes or reads it yet, so it's dropped
    # here rather than left pointing at a column that doesn't exist.
    media_url: Mapped[str] = mapped_column("url", String(2048), nullable=False)
    media_type: Mapped[MediaType] = mapped_column(
        Enum(MediaType, name="media_type", native_enum=False, length=30), default=MediaType.IMAGE, nullable=False
    )
    thumbnail_url: Mapped[str | None] = mapped_column(String(2048), nullable=True)
    file_size: Mapped[int | None] = mapped_column("file_size_bytes", Integer, nullable=True)
    mime_type: Mapped[str | None] = mapped_column(String(100), nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationship
    report = relationship("FieldReport", back_populates="media")
