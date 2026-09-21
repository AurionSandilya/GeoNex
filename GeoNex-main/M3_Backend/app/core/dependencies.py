"""
app/core/dependencies.py

FastAPI Dependency Injection helper module for:
- Database sessions (`get_db`)
- JWT authentication (`get_current_user`)
- Role-Based Access Control / RBAC (`require_roles`)
"""

from typing import List
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import decode_access_token
from app.models.user import User, UserRole

# OAuth2 bearer scheme for Swagger UI & API header authorization
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Validates JWT token and retrieves the current authenticated user.
    Throws HTTP 401 Unauthorized if invalid or expired.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception

    user_id: str = payload.get("sub")
    if user_id is None:
        raise credentials_exception

    # Query database for user
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if user is None:
        raise credentials_exception

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user account",
        )

    return user


def require_roles(allowed_roles: List[UserRole]):
    """
    Role-Based Access Control (RBAC) Dependency Factory.

    Usage:
        @router.post("/verify", dependencies=[Depends(require_roles([UserRole.FIELD_OFFICER, UserRole.ADMIN]))])
    """
    async def role_checker(current_user: User = Depends(get_current_user)):
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"User role '{current_user.role.value}' does not have sufficient permissions. Allowed: {[r.value for r in allowed_roles]}",
            )
        return current_user

    return role_checker
