# NER-LEWS Complete System Architecture
## Smart India Hackathon 2026 — Problem Statement ID: 26001
**AI-Based Early Warning and Smart Landslide Risk Monitoring System for the North-Eastern Region (NER)**  
*Primary Deployment Focus: Papum Pare District, Arunachal Pradesh*

---

## 1. Executive Architectural Overview

The **North-Eastern Region Landslide Early Warning System (NER-LEWS)** integrates five specialized software modules into a cohesive, high-reliability, production-grade disaster prevention and response platform.

The system addresses the unique terrain challenges of the Eastern Himalayas: heavy monsoon rainfall, steep slope gradients, seismic vulnerability, remote tribal settlements, and fragile road connectivity.

```
+---------------------------------------------------------------------------------------------------+
|                                     NER-LEWS SYSTEM ARCHITECTURE                                  |
+---------------------------------------------------------------------------------------------------+

     [ Environmental Sensors & Remote Sensing ]
     (IMD Rainfall, Sentinel/Landsat NDVI, SRTM DEM, Soil Moisture Sensors)
                         │
                         ▼
     +───────────────────────────────────────────────────────────+
     |                 M1: AI / ML RISK ENGINE                   |
     |   • Static Susceptibility Pipeline (RandomForestClassifier) |
     |   • Dynamic Trigger Pipeline (RandomForestClassifier)     |
     |   • 2D Matrix Decision Engine (LOW, MOD, HIGH, VERY HIGH) |
     +───────────────────────────┬───────────────────────────────+
                                 │ In-Memory Python API
                                 ▼
     +───────────────────────────────────────────────────────────+
     |             M3: CANONICAL FASTAPI BACKEND (:8000)         |
     |   • Authentication & RBAC (JWT, Citizen, Officer, Admin)  |
     |   • PostGIS Spatial Intelligence (SRID 4326, ST_DWithin)  |
     |   • Schema Authority for risk_predictions & field_reports |
     |   • Base32 Geohash Spatial Indexing                       |
     |   • Real-Time WebSocket Streaming (/ws/dashboard)         |
     |   • Recipient Resolution Service (/recipients/resolve)    |
     +─────────────┬───────────────────────────────┬─────────────+
                   │ Shared PostgreSQL             │ Webhook
                   ▼                               ▼
     +───────────────────────────+   +───────────────────────────+
     |   POSTGRESQL + POSTGIS    |   |  M5: ALERT ENGINE (:8001) |
     |   Shared Authority DB     |   |  • Event Evaluator        |
     |   • PostGIS 3.4 / PG 16   |   |  • Alert State Machine    |
     |   • Spatial Indexing      |   |  • Cooldown & Dampening   |
     |   • Dual-Tenant Isolation |   |  • SMS & Push Dispatch    |
     +───────────────────────────+   +─────────────┬─────────────+
                   ▲                               │
         REST / WS │                     SMS / FCM │ Push
                   │                               │
       ┌───────────┴───────────┐                   │
       ▼                       ▼                   ▼
+──────────────+        +──────────────+    +──────────────+
|  M2: FLUTTER |        |   M4: GIS    |    | CITIZENS &   |
|  MOBILE APP  |        |  DASHBOARD   |    | FIRST        |
|  Terra Sense |        |  React+Vite  |    | RESPONDERS   |
|  (Citizen &  |        |  MapLibre GL |    | (SMS/Push/   |
|   Officer)   |        |   (:5173)    |    |  In-App)     |
+──────────────+        +──────────────+    +──────────────+
```

---

## 2. Module Ownership & Architectural Boundaries

To prevent split-brain states and data conflicts, the system enforces strict domain boundaries:

| Capability | Owning Module | Authority & Storage |
|---|---|---|
| **ML Inference (Static + Dynamic)** | **M1** | In-memory execution; pre-trained `.pkl` pipelines |
| **Susceptibility & Risk Matrices** | **M1** | Configured decision matrix (`RISK_MATRIX`) |
| **Prediction Identity & Persistence** | **M3** | `risk_predictions` table (PostgreSQL authority) |
| **Geospatial & Spatial Indexing** | **M3** | PostGIS `geometry(Point, 4326)` & Geohash Base32 |
| **Authentication & RBAC** | **M3** | `users` table, JWT Bearer tokens, passlib bcrypt |
| **Field Crowdsourcing & Reports** | **M3** | `field_reports` & `field_verifications` tables |
| **Spatial Infrastructure Layers** | **M3** | `roads`, `villages`, `critical_infrastructure` tables |
| **Real-time Event Broadcasting** | **M3** | FastAPI WebSocket connection manager (`/ws/dashboard`) |
| **Recipient Geo-Resolution** | **M3** | `POST /recipients/resolve` (officer and responder routing) |
| **Alert State Machine & Decisions** | **M5** | `alerts` table (M5 is the sole schema authority) |
| **Notification Dispatch & Cooldown** | **M5** | `alert_deliveries`, `notification_intents`, `notification_cooldowns` |
| **Citizen & Field Officer UI** | **M2** | Flutter Cross-Platform Client (Android / iOS / Web) |
| **Command Center Visualization** | **M4** | React + MapLibre GL Desktop / Tactical Command Center |

---

## 3. Deep Dive into Module Architecture

### 3.1 M1: AI/ML Landslide Risk Engine
- **Architectural Role**: Pure Python computation engine. Imported directly into M3 without HTTP server overhead.
- **Model Architecture**:
  1. **Static Susceptibility Model**: Scikit-Learn `RandomForestClassifier` pipeline trained on 10 terrain factors:
     - `elevation` (m), `slope` (deg), `curvature`, `soil_type`, `ndvi_2017`, `distance_to_river_m`, `distance_to_road_m`, `distance_to_village_m`, `aspect_sin`, `aspect_cos`.
  2. **Dynamic Trigger Model**: Scikit-Learn `RandomForestClassifier` pipeline trained on 15 hydrometeorological features:
     - `rainfall_1d`, `rainfall_3d`, `rainfall_7d`, `rainfall_14d`, `rainfall_30d`, `rainfall_max_3d`, `rainfall_max_7d`, `rainy_days_7d`, `rainy_days_14d`, `rainy_days_30d`, `soil_moisture`, `soil_moisture_3d_mean`, `soil_moisture_7d_mean`, `soil_moisture_change_3d`, `soil_moisture_change_7d`.
  3. **2D Risk Matrix**:
     - Static Risk Class (`LOW`, `MODERATE`, `HIGH`, `VERY HIGH`) $\times$ Dynamic Trigger Class (`LOW`, `MODERATE`, `HIGH`, `VERY HIGH`) $\rightarrow$ Final Risk Output.
- **Contract with M3**:
  - M1 outputs: `LOW`, `MODERATE`, `HIGH`, `VERY HIGH`.
  - M3 maps output to M5-compatible risk bands:
    - `LOW` $\rightarrow$ `NORMAL`
    - `MODERATE` $\rightarrow$ `WATCH`
    - `HIGH` $\rightarrow$ `WARNING`
    - `VERY HIGH` $\rightarrow$ `CRITICAL`

---

### 3.2 M3: FastAPI Canonical Backend & PostGIS Database
- **Architectural Role**: Central nervous system and single source of truth for GIS, users, reports, and risk predictions.
- **Core Subsystems**:
  1. **Authentication & RBAC**:
     - Roles: `CITIZEN`, `FIELD_OFFICER`, `ADMIN`, `DISTRICT_ADMIN`.
     - JWT Bearer Authentication with 60-minute token lifespan.
  2. **PostGIS Spatial Engine**:
     - SRID 4326 (WGS 84) coordinate storage.
     - Spatial indexes (`GIST`) on report coordinates, roads, and village polygons.
     - Pure-Python Base32 Geohashing: Maps `(lat, lon)` into 5-character geohashes (~4.9 km $\times$ 4.9 km) serving as canonical `area_id` across M3 and M5.
  3. **Inter-Service Webhook**:
     - When risk is predicted, M3 commits the row to `risk_predictions` and triggers an async, non-blocking webhook to `POST http://localhost:8001/internal/risk-event` with `prediction_id` and `area_id`.
  4. **Recipient Resolution Service**:
     - Servicing M5's dispatch loop: M5 queries `POST /recipients/resolve` on M3 to resolve all field officers, district control rooms, and citizens in the affected `area_id`.
  5. **WebSocket Push Broadcaster**:
     - Connects GIS dashboards and field clients to `/ws/dashboard`.
     - Broadcasts real-time events: `RISK_PREDICTION_UPDATED`, `ALERT_ACKNOWLEDGED`, `REPORT_VERIFIED`.

---

### 3.3 M5: Early Warning Alert & Notification Engine
- **Architectural Role**: Decoupled, event-driven alert evaluator and notification dispatcher.
- **Port**: `8001` (independent process from M3 on `8000`).
- **Database Model**:
  - Operates on the same shared PostgreSQL database instance (`sih_landslide`).
  - Owns tables: `alerts`, `alert_deliveries`, `alert_config`, `notification_intents`, `notification_cooldowns`, `alert_audit_log`, `processed_risk_events`.
  - Reads `risk_predictions` table via read-only `SELECT` queries (using `prediction_id`).
- **Alert State Machine**:
  - `ACTIVE` $\rightarrow$ `ACKNOWLEDGED` $\rightarrow$ `RESOLVED` / `EXPIRED` / `CANCELLED`.
  - **Escalation Invariant**: An acknowledged alert that experiences a higher risk trigger will escalate from `WARNING` to `CRITICAL` without losing its operational audit history.
  - **Dampening & Cooldown**: Enforces notification cooldown periods per recipient and channel to prevent SMS/push notification storms during ongoing rainstorms.

---

### 3.4 M4: GIS Command Center Dashboard
- **Architectural Role**: Browser-based command center for SDMA, District Disaster Management Authorities (DDMA), and District Emergency Operation Centers (DEOC).
- **Tech Stack**: React 18, Vite, MapLibre GL, Tailwind CSS.
- **Key Features**:
  1. **Interactive 2D/3D Terrain Map**:
     - Visualizes slope risk rasters, road blockage vectors, and village buffer zones in Papum Pare District.
  2. **Live Alert Triage Bar**:
     - Color-coded alert markers by severity:
       - `CRITICAL` (Red / P1)
       - `WARNING` (Orange / P2)
       - `WATCH` (Yellow / P3)
       - `NORMAL` (Green / P4)
  3. **One-Click Officer Acknowledgement**:
     - Operational officers can acknowledge active alerts, triggering state updates in M5 and WebSocket broadcasts to all connected screens.
  4. **Crowdsourced Report Feed**:
     - Real-time display of citizen photos, GPS coordinates, and verification statuses.

---

### 3.5 M2: Mobile Application ("Terra Sense")
- **Architectural Role**: Offline-first mobile interface for citizens and deployed field response squads.
- **Tech Stack**: Flutter 3.x / Dart.
- **Key Features**:
  1. **Dual-Role UX**:
     - *Citizen Mode*: Live localized danger badge, emergency SOS broadcast, emergency contact speed dial, evacuation safe zones, vernacular alert messages.
     - *Field Officer Mode*: Verification queue, GPS camera capture, road obstruction logging, on-site hazard classification.
  2. **Resilient Backend Integration**:
     - `FastApiBackendClient` connects directly to M3 (`/api/v1`).
     - Includes automatic, seamless fallback to `MockBackendClient` during remote valley network blackouts, allowing full offline usability.

---

## 4. Cross-Cutting Engineering Specifications

### 4.1 Security & Inter-Service Trust
- **Client $\rightarrow$ M3 Backend**: Standard OAuth2 Password Bearer flow with JWT signed via HMAC-SHA256 (`SECRET_KEY`).
- **M3 $\leftrightarrow$ M5 Service-to-Service**: Protected via HTTP header `X-Internal-Service-Key` (`m3-m5-internal-shared-key`). No unauthorized traffic can trigger alert evaluations or recipient resolutions.
- **Data Isolation**: Passwords hashed using `bcrypt` (cost factor 12). PII (phone numbers, device tokens) strictly guarded in internal network calls.

### 4.2 Database Dual-Tenant Architecture
Both M3 and M5 share a single PostgreSQL database instance (`sih_landslide`), but with zero table overlap:
```
Database: sih_landslide
├── M3 Schema Authority:
│   ├── users
│   ├── risk_predictions
│   ├── field_reports
│   ├── field_verifications
│   ├── roads
│   ├── villages
│   ├── critical_infrastructure
│   └── audit_log
└── M5 Schema Authority:
    ├── alerts
    ├── alert_deliveries
    ├── alert_config
    ├── notification_intents
    ├── notification_cooldowns
    ├── alert_audit_log
    └── processed_risk_events
```

### 4.3 High Availability & Fault Tolerance
1. **Asynchronous Non-Blocking Webhooks**: If M5 is temporarily unavailable, M3 commits the prediction and logs a retry notice; M5's background reconciler picks up unprocessed predictions upon restart.
2. **Offline Idempotency**: M2 mobile reports transmit a client-generated UUID (`client_report_id`), ensuring zero duplicate submissions when mobile squads reconnect to cellular networks.
3. **Database-Independent State Fallback**: When PostgreSQL is offline in demonstration environments, both M3 and M2 fall back cleanly to cached/mock operational telemetry.
