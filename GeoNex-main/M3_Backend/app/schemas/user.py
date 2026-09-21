"""
app/schemas/user.py

Pydantic schemas for authentication and user management.
Validates input email format, password strength, coordinate ranges, etc.
"""

from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, EmailStr, Field

from app.models.user import UserRole


class UserBase(BaseModel):
    email: EmailStr
    full_name: str = Field(..., min_length=2, max_length=255)


class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="Minimum 8 characters password")
    role: UserRole = UserRole.CITIZEN


class UserResponse(UserBase):
    id: UUID
    role: UserRole
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class TokenPayload(BaseModel):
    sub: str | None = None
    role: str | None = None
