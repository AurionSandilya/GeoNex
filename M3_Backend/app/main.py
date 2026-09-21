"""
app/main.py

Central FastAPI Application Entry Point for SIH 2026 Landslide Monitoring Backend.
Mounts all Routers, CORS Middleware, Error Handlers, and Lifespan startup check.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.core.config import get_settings
from app.routers import auth, reports, risk, spatial, emergency, alerts, websocket, recipients
from app.middleware.error_handler import (
    custom_http_exception_handler,
    validation_exception_handler,
)

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan startup and shutdown hooks.
    """
    print(f"\n{'='*60}")
    print(f"  {settings.APP_NAME} v{settings.APP_VERSION}")
    print(f"  Environment : {settings.ENVIRONMENT}")
    print(f"  Debug mode  : {settings.DEBUG}")
    print(f"  Docs        : http://127.0.0.1:8000/docs")
    print(f"{'='*60}\n")
    
    yield
    
    print("\nShutting down gracefully...")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="""
## SIH 2026 — AI-Powered Real-Time Landslide Monitoring Platform
**PS ID: 26001** | North Eastern Region (NER)

### Central M3 Backend API Architecture
- 🔐 **Authentication & RBAC** (JWT, Roles: Citizen, Field Officer, Admin)
- 🗺️ **Geo-Tagged Field Reports** (PostGIS Point Geometry, Offline Sync Idempotency)
- 🤖 **ML Risk Prediction** (M1 XGBoost Contract & Threshold Integration)
- 🌐 **GeoJSON GIS Layers** (Roads, Villages, Infrastructure for M4 Dashboard)
- 🚨 **Early Warning Alerts** (M5 Delivery & Officer Acknowledgement)
- 🚑 **Emergency Prioritization** (Decision Support Ranking P1/P2/P3)
- ⚡ **Real-Time Stream** (WebSockets for Live Dashboard)
    """,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    lifespan=lifespan,
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Standardized Error Handlers (Phase 28)
app.add_exception_handler(StarletteHTTPException, custom_http_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)

# Include All API Routers under /api/v1 (API Versioning)
api_prefix = settings.API_V1_PREFIX

app.include_router(auth.router, prefix=api_prefix)
app.include_router(reports.router, prefix=api_prefix)
app.include_router(risk.router, prefix=api_prefix)
app.include_router(spatial.router, prefix=api_prefix)
app.include_router(emergency.router, prefix=api_prefix)
app.include_router(alerts.router, prefix=api_prefix)
app.include_router(recipients.router, prefix=api_prefix)
app.include_router(recipients.router)
app.include_router(websocket.router)


@app.get("/", tags=["Health"])
async def root():
    return {
        "status": "ok",
        "message": f"{settings.APP_NAME} is running",
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
        "docs": "http://127.0.0.1:8000/docs",
        "team": "M3 — Backend + PostGIS",
        "project": "SIH 2026 | PS ID: 26001",
    }


@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
    }
