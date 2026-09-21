"""
app/models/user.py

SQLAlchemy 2.x Model for system users.
Supports Roles: CITIZEN, FIELD_OFFICER, ADMIN, DISTRICT_ADMIN
"""

import uuid
from datetime import datetime, timezone
from enum import Enum as PyEnum

from sqlalchemy import String, Boolean, DateTime, Enum, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class UserRole(str, PyEnum):
    CITIZEN = "CITIZEN"
    FIELD_OFFICER = "FIELD_OFFICER"
    ADMIN = "ADMIN"
    DISTRICT_ADMIN = "DISTRICT_ADMIN"


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    # The 0001 migration created this column as a plain VARCHAR(50), not a
    # native Postgres enum type - Enum(..., name="user_role") without
    # native_enum=False expects a CREATE TYPE user_role that was never
    # migrated, so every insert failed with `type "user_role" does not
    # exist`. native_enum=False keeps Python-side validation (UserRole
    # membership is still enforced) while storing/reading the column as the
    # VARCHAR it actually is in the migrated schema - the smaller fix
    # compared to writing a new migration to convert the column type.
    role: Mapped[UserRole] = mapped_column(
        Enum(UserRole, name="user_role", native_enum=False, length=50),
        default=UserRole.CITIZEN, nullable=False,
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    # Relationships
    reports = relationship("FieldReport", back_populates="user", cascade="all, delete-orphan")
    verifications = relationship("FieldVerification", back_populates="officer")
