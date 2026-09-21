# SIH 2026 — AI-Powered Landslide Monitoring Backend

**PS ID: 26001** | North Eastern Region (NER)  
**Team Member**: M3 — Backend + PostGIS Engineer

---

## 🎯 Project Overview

The central **FastAPI + PostgreSQL + PostGIS** backend for the Smart India Hackathon (SIH 2026) landslide monitoring, prediction, GIS visualization, field reporting, and early warning platform.

Inter-module connections:
`M1 ML Engine ↕ M3 Backend ↕ M2 Field App ↕ M4 GIS Dashboard ↕ M5 Alert Engine ↕ M6 Verification/DevOps`

---

## 🛠️ Technology Stack

| Layer | Technology |
|-------|-----------|
| **Core API Framework** | Python 3.12+, FastAPI, Uvicorn |
| **Spatial Database** | PostgreSQL 16+ with PostGIS |
| **ORM & Migrations** | SQLAlchemy 2.x (Async) & Alembic |
| **GIS & Spatial** | GeoAlchemy2, Shapely, GeoJSON |
| **Authentication** | JWT (jose) & Password Hashing (bcrypt) |
| **Real-Time** | WebSockets (`/ws/dashboard`) |
| **Testing** | Pytest & HTTPX Async Test Client |
| **Containerization** | Docker & Docker Compose |

---

## 🚀 Quick Start Guide

### 1. Local Setup
```powershell
# 1. Navigate to backend directory
cd "d:\sih 2026\backend"

# 2. Activate virtual environment
.\venv\Scripts\Activate.ps1

# 3. Install requirements
.\venv\Scripts\pip.exe install -r requirements.txt

# 4. Copy environment template
Copy-Item .env.example .env

# 5. Start the FastAPI development server
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Run Automated Pytest Suite
```powershell
.\venv\Scripts\python.exe -m pytest tests/ -v
```

### 3. Run with Docker Compose
```bash
docker-compose up --build
```

---

## 🌐 Core API Endpoints

| Category | Endpoint | Description |
|----------|----------|-------------|
| **Health** | `GET /` | Root system status |
| **Health** | `GET /health` | Health monitoring |
| **Auth** | `POST /api/v1/auth/register` | Register user (Citizen/Officer) |
| **Auth** | `POST /api/v1/auth/login` | Obtain OAuth2 JWT token |
| **Auth** | `GET /api/v1/auth/me` | Current authenticated user profile |
| **Reports** | `POST /api/v1/reports` | Submit geo-tagged report with PostGIS POINT |
| **Reports** | `GET /api/v1/reports/geojson` | GeoJSON FeatureCollection for M4 Dashboard |
| **Reports** | `POST /api/v1/reports/{id}/verify` | M6 Field Officer verification |
| **Risk (M1)** | `GET /api/v1/risk/location` | AI Risk prediction for lat/lon |
| **Risk (M1)** | `GET /api/v1/risk/area` | Bounding box spatial risk grid |
| **Spatial** | `GET /api/v1/roads/geojson` | Roads LineString layer for GIS |
| **Spatial** | `GET /api/v1/villages` | Settlements demographic data |
| **Spatial** | `GET /api/v1/infrastructure` | Critical assets (hospitals, bridges) |
| **Emergency** | `GET /api/v1/emergency/priorities` | Decision support P1/P2/P3 rankings |
| **Alerts (M5)** | `GET /api/v1/alerts` | Active early warning alerts |
| **Alerts (M5)** | `POST /api/v1/alerts/{id}/acknowledge` | Official alert acknowledgement |
| **Real-Time** | `WS /ws/dashboard` | WebSocket stream for live updates |
| **Docs** | `http://localhost:8000/docs` | Swagger OpenAPI UI |

---

## 🗺️ Development Phases Status

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 1 | Project Setup & FastAPI Initialization | ✅ Complete |
| Phase 2 | PostgreSQL + PostGIS Engine Setup | ✅ Complete |
| Phase 3 | Database Architecture (16 Tables) | ✅ Complete |
| Phase 4 | Spatial Database Design (POINT, LINESTRING, POLYGON, SRID 4326) | ✅ Complete |
| Phase 5 | SQLAlchemy 2.x Models | ✅ Complete |
| Phase 6 | Alembic Migrations System | ✅ Complete |
| Phase 7 | Pydantic Request & Response Schemas | ✅ Complete |
| Phase 8 | JWT Authentication & RBAC Roles | ✅ Complete |
| Phase 9 | Field Reporting API & Idempotency Key | ✅ Complete |
| Phase 10 | Geo-Tagged Media Metadata & Hashes | ✅ Complete |
| Phase 11 | Report Retrieval & Spatial Filters | ✅ Complete |
| Phase 12 | PostGIS Spatial Queries | ✅ Complete |
| Phase 13 | GeoJSON APIs (M4 GIS Dashboard) | ✅ Complete |
| Phase 14 | Risk Prediction API Interface | ✅ Complete |
| Phase 15 | M1 ML Model Integration Service Layer | ✅ Complete |
| Phase 16 | Risk Features Contract | ✅ Complete |
| Phase 17 | Risk Storage & Snapshots | ✅ Complete |
| Phase 18 | Risk Area Bounding Box API | ✅ Complete |
| Phase 19 | Roads, Villages & Infrastructure APIs | ✅ Complete |
| Phase 20 | Emergency Priority Decision API (P1/P2/P3) | ✅ Complete |
| Phase 21 | Early Warning Alert Integration (M5) | ✅ Complete |
| Phase 22 | Alert Delivery Records | ✅ Complete |
| Phase 23 | Officer Verification Module (M6) | ✅ Complete |
| Phase 24 | Audit Logging Architecture | ✅ Complete |
| Phase 25 | Idempotent Offline Sync Support | ✅ Complete |
| Phase 26 | Real-Time WebSockets Dashboard Stream | ✅ Complete |
| Phase 27 | OpenAPI Swagger Documentation | ✅ Complete |
| Phase 28 | Standardized Error Handling | ✅ Complete |
| Phase 29 | Security Hardening & CORS | ✅ Complete |
| Phase 30 | Automated Pytest Suite | ✅ Complete |
| Phase 31 | Spatial Performance & GIST Indexing | ✅ Complete |
| Phase 32 | Docker & Docker-Compose Setup | ✅ Complete |
| Phase 33 | Production Deployment & Health Monitoring | ✅ Complete |
| Phase 34 | Complete Multi-Module System Integration | ✅ Complete |
