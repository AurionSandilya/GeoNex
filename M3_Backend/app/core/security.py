"""
app/core/security.py

What this file does:
    - Password hashing and verification (using bcrypt)
    - JWT token creation and decoding

Why we need this:
    - NEVER store plain-text passwords. bcrypt hashes them so even if the
      database is leaked, passwords are not exposed.
    - JWT (JSON Web Tokens) let mobile apps and frontends authenticate
      without sending username/password on every request.

This file will be fully used in Phase 8 (Authentication).
For Phase 1, it just stubs the functions so imports don't break.
"""

from datetime import datetime, timedelta, timezone
from typing import Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import get_settings

settings = get_settings()

# ---------------------------------------------------------------------------
# Password Hashing
# ---------------------------------------------------------------------------
# CryptContext uses bcrypt algorithm.
# bcrypt is industry-standard for password hashing:
#   - It is intentionally slow (cost factor), making brute-force hard
#   - It includes a random salt automatically (no rainbow-table attacks)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(plain_password: str) -> str:
    """
    Hash a plain-text password.
    
    Example:
        hashed = hash_password("mypassword123")
        # "$2b$12$..." — never looks like the original
    """
    return pwd_context.hash(plain_password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Check a plain-text password against its stored hash.
    Returns True if they match, False otherwise.
    
    Example:
        verify_password("mypassword123", stored_hash)  # True
        verify_password("wrongpassword", stored_hash)  # False
    """
    return pwd_context.verify(plain_password, hashed_password)


# ---------------------------------------------------------------------------
# JWT Tokens
# ---------------------------------------------------------------------------
def create_access_token(
    subject: str | Any,
    expires_delta: timedelta | None = None,
) -> str:
    """
    Create a signed JWT access token.
    
    Args:
        subject: Usually the user's ID (str or UUID)
        expires_delta: How long until token expires
    
    Returns:
        A signed JWT string like "eyJ0eXAiOiJKV1Qi..."
    
    The token encodes:
        - 'sub': subject (user ID)
        - 'exp': expiry time
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    payload = {
        "sub": str(subject),
        "exp": expire,
        "iat": datetime.now(timezone.utc),   # issued-at
    }

    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_access_token(token: str) -> dict | None:
    """
    Decode and verify a JWT token.
    
    Returns the payload dict if valid, None if expired or tampered.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
        return payload
    except JWTError:
        return None
