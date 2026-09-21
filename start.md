# NER-LEWS Launch Guide
## Smart India Hackathon 2026 — PS ID: 26001
**AI-Based Early Warning and Smart Landslide Risk Monitoring System for the North-Eastern Region (NER)**

This guide provides the complete, step-by-step instructions to launch and run all integrated components of the NER-LEWS platform on your local machine.

---

## 1. System Topology & Port Mapping

| Component | Technology | Default Port / URL | Role |
|---|---|---|---|
| **PostgreSQL + PostGIS** | Docker / Native | `localhost:5432` (`sih_landslide`) | Shared database authority |
| **M1 ML Engine** | Scikit-Learn / Joblib | In-Memory (Imported by M3) | Dual Random Forest pipelines |
| **M3 Backend** | FastAPI + SQLAlchemy | `http://localhost:8000` | Canonical API, Auth, PostGIS, WebSockets |
| **M5 Alert Engine** | FastAPI + AsyncPG | `http://localhost:8001` | Early warning evaluator, state machine & notifications |
| **M4 GIS Dashboard** | React + Vite + MapLibre | `http://localhost:5173` | Real-time map & disaster command center |
| **M2 Mobile App** | Flutter / Dart | Mobile device / Chrome | Citizen warnings & Field officer reporting |

---

## 2. Prerequisites

Ensure you have the following installed on your system:
- **Python 3.10+** (Python 3.10 or 3.13 recommended)
- **Node.js 18+** & `npm`
- **Docker Desktop** (or local PostgreSQL 15+ with PostGIS extension installed)
- **Flutter SDK** (optional, for running the M2 mobile app)

#### One-Time Python Dependencies Install (Root Directory)
Install all required packages for **M1**, **M3**, and **M5** at once from the root directory:
```powershell
cd "d:\Landslide integration"
pip install -r requirements.txt
```

---

## 3. Step-by-Step Launch Sequence

Open separate terminals for each component in the following order:

### Terminal 0: Database (PostgreSQL + PostGIS)

#### Option A: Using Docker (Fastest & Recommended)
```powershell
cd "d:\Landslide integration\M3_Backend"
docker compose up -d db
```

#### Option B: Using Local PostgreSQL Installation
```powershell
# Create the database and enable PostGIS
createdb -U postgres sih_landslide
psql -U postgres -d sih_landslide -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

---

### Terminal 1: Apply Migrations & Start M3 Backend (:8000)

1. **Navigate to M3 directory**:
   ```powershell
   cd "d:\Landslide integration\M3_Backend"
   ```

2. **Verify / Update `.env`**:
   Ensure `DATABASE_URL` matches your postgres password in `d:\Landslide integration\M3_Backend\.env`:
   ```ini
   DATABASE_URL=postgresql+asyncpg://postgres:sih2026postgis@localhost:5432/sih_landslide
   ```
   *(If using Docker Option A above, default password is `sih2026postgis`)*

3. **Run Alembic Migrations**:
   ```powershell
   alembic upgrade head
   ```

4. **Start the FastAPI Backend**:
   ```powershell
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
   - **Interactive Swagger Docs**: [http://localhost:8000/docs](http://localhost:8000/docs)
   - **Health Check**: [http://localhost:8000/health](http://localhost:8000/health)

---

### Terminal 2: Start M5 Alert Engine (:8001)

1. **Navigate to M5 directory**:
   ```powershell
   cd "d:\Landslide integration\M5_Alert_Engine\LANDSLIDE SIH M5"
   ```

2. **Verify `.env`**:
   Ensure database password in `d:\Landslide integration\M5_Alert_Engine\LANDSLIDE SIH M5\.env` matches M3:
   ```ini
   DATABASE_URL=postgresql+asyncpg://postgres:sih2026postgis@localhost:5432/sih_landslide
   M3_BASE_URL=http://localhost:8000
   ```

3. **Start the Alert Engine**:
   ```powershell
   python -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload
   ```
   - **M5 Health Check**: [http://localhost:8001/health](http://localhost:8001/health)
   - **M5 Swagger Docs**: [http://localhost:8001/docs](http://localhost:8001/docs)

---

### Terminal 3: Start M4 GIS React Dashboard (:5173)

1. **Navigate to M4 directory**:
   ```powershell
   cd "d:\Landslide integration\M4_GIS_Dashboard"
   ```

2. **Install Dependencies** (if first time running):
   ```powershell
   npm install
   ```

3. **Launch Vite Development Server**:
   ```powershell
   npm run dev
   ```
   - **Command Center Dashboard**: [http://localhost:5173](http://localhost:5173)
   - Note: Vite automatically proxies `/api` and `/ws` to `http://localhost:8000`.

---

### Terminal 4: Start M2 Flutter Mobile App

1. **Navigate to M2 directory**:
   ```powershell
   cd "d:\Landslide integration\M2_Flutter"
   ```

2. **Fetch dependencies**:
   ```powershell
   flutter pub get
   ```

3. **Run the App**:
   ```powershell
   # Run in Chrome browser
   flutter run -d chrome

   # Or run on connected physical Android phone / emulator
   flutter run
   ```
   - The app connects to `http://localhost:8000/api/v1` via `FastApiBackendClient`.
   - If the backend is stopped or offline, the app automatically fails over to built-in mock telemetry so field features can still be demonstrated.

---

## 4. End-to-End Verification & Sanity Checks

### Check 1: Verify M3 Backend Health
```powershell
curl.exe http://localhost:8000/health
```
**Expected response**:
```json
{"status":"healthy","app":"SIH Landslide Backend","version":"1.0.0"}
```

### Check 2: Trigger Real M1 ML Risk Inference
```powershell
curl.exe "http://localhost:8000/api/v1/risk/location?lat=27.55&lon=93.65&rainfall_24h=110.0&slope=34.0&soil_moisture=0.82"
```
**Expected response**:
- Valid geohash `area_id` (e.g., `whfd7`)
- Calculated `risk_score` from dynamic rainfall accumulators + static terrain models
- `risk_band` (`NORMAL`, `WATCH`, `WARNING`, or `CRITICAL`)
- M3 automatically persists prediction and dispatches internal event to M5

### Check 3: Verify M5 Recipient Resolution Call
```powershell
curl.exe -X POST http://localhost:8000/recipients/resolve `
  -H "Content-Type: application/json" `
  -d '{\"area_id\":\"whfd7\",\"alert_id\":\"00000000-0000-0000-0000-000000000001\",\"severity\":\"CRITICAL\"}'
```
**Expected response**:
- List of geo-targeted incident command contacts and field officers (DEOC Papum Pare, NDRF 12th Bn, SDMA).

### Check 4: Run Automated M3 Pytest Test Suite
```powershell
cd "d:\Landslide integration"
python -m pytest M3_Backend/tests/test_api.py -v
```
**Expected output**: All 7 integration tests pass (`100%`).

---

## 5. Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| `ConnectionRefusedError: [WinError 1225]` on port 5432 | PostgreSQL is not running | Run `docker compose up -d db` in `M3_Backend` or start PostgreSQL service. |
| `scikit-learn unpickle InconsistentVersionWarning` | Pickle created in scikit-learn 1.6.x | Benign warning; unpickle patches are automatically applied in `M1_ML/inference.py` and `ml_service.py`. |
| M4 Dashboard shows `Network Error` | Backend not on port 8000 | Verify M3 is running on `http://localhost:8000`. Dashboard includes mock fallbacks if backend is restarting. |
| M5 webhook connection refused | M5 is not started | Start M5 on port 8001 using Terminal 2 command. M3 logs a gentle notice and continues without blocking if M5 is temporarily down. |
| Port 8000 or 8001 already in use | Another process listening | Check running processes: `Get-NetTCPConnection -LocalPort 8000` and kill the PID if needed. |
