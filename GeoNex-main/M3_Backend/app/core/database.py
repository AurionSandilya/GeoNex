"""
app/core/database.py

What this file does:
    - Creates the async SQLAlchemy engine connected to PostgreSQL + PostGIS
    - Provides a session factory for database operations
    - Has a startup connectivity check so the app fails fast if DB is down

Why async?
    FastAPI is async. Using async SQLAlchemy means database queries don't
    block the server — it can handle many concurrent requests efficiently.
"""

from sqlalchemy.ext.asyncio import (
    AsyncSession,
    create_async_engine,
    async_sessionmaker,
)
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy import text

from app.core.config import get_settings

settings = get_settings()

# ---------------------------------------------------------------------------
# Engine — the core PostgreSQL connection pool
# ---------------------------------------------------------------------------
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,       # Print SQL in DEBUG mode (dev only)
    pool_pre_ping=True,        # Test connections before using them
    pool_size=10,              # Keep 10 connections warm
    max_overflow=20,           # Allow up to 20 extra in burst
    pool_timeout=30,           # Wait max 30s for a free connection
    pool_recycle=1800,         # Recycle connections every 30 minutes
)

# ---------------------------------------------------------------------------
# Session Factory
# ---------------------------------------------------------------------------
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

# ---------------------------------------------------------------------------
# Base — all SQLAlchemy models inherit from this
# ---------------------------------------------------------------------------
class Base(DeclarativeBase):
    pass


# ---------------------------------------------------------------------------
# Startup check — called from main.py lifespan
# ---------------------------------------------------------------------------
async def check_db_connection() -> dict:
    """
    Verifies PostgreSQL + PostGIS are accessible at startup.
    
    Returns a dict with status info.
    Raises an exception if connection fails (app won't start).
    """
    async with AsyncSessionLocal() as session:
        # Check basic PostgreSQL connection
        result = await session.execute(text("SELECT version()"))
        pg_version = result.scalar()

        # Check PostGIS extension is enabled
        postgis_result = await session.execute(text("SELECT PostGIS_Version()"))
        postgis_version = postgis_result.scalar()

    return {
        "postgresql": pg_version,
        "postgis": postgis_version,
    }


# ---------------------------------------------------------------------------
# Dependency: get_db — used in every route that needs the database
# ---------------------------------------------------------------------------
async def get_db() -> AsyncSession:
    """
    FastAPI dependency to get a database session per request.

    Usage in any router:
        @router.get("/something")
        async def my_endpoint(db: AsyncSession = Depends(get_db)):
            result = await db.execute(select(User))

    Automatically:
      - Commits on success
      - Rolls back on any exception
      - Returns connection to the pool when done
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
