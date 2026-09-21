"""
tests/test_api.py

Automated pytest test suite for SIH 2026 Landslide Backend API.
Tests health checks, risk API, GeoJSON formatting, authentication, and emergency priority endpoint.
"""

import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_root_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "SIH Landslide Backend" in data["message"]


@pytest.mark.asyncio
async def test_health_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"


@pytest.mark.asyncio
async def test_risk_location_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/api/v1/risk/location?lat=27.55&lon=93.65&rainfall_24h=80.0&slope=35.0")
    assert response.status_code == 200
    data = response.json()
    assert "risk_score" in data
    assert "risk_level" in data
    assert data["risk_score"] > 0.0


@pytest.mark.asyncio
async def test_reports_geojson_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/api/v1/reports/geojson")
    assert response.status_code == 200
    data = response.json()
    assert data["type"] == "FeatureCollection"
    assert isinstance(data["features"], list)


@pytest.mark.asyncio
async def test_emergency_priorities_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/api/v1/emergency/priorities")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]) > 0


@pytest.mark.asyncio
async def test_recipients_resolve_endpoint_root_and_versioned():
    payload = {
        "area_id": "whfd7",
        "alert_id": "00000000-0000-0000-0000-000000000001",
        "severity": "CRITICAL"
    }
    # Test root endpoint (called directly by M5 HTTP client)
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response_root = await ac.post("/recipients/resolve", json=payload)
    assert response_root.status_code == 200
    recipients = response_root.json()
    assert isinstance(recipients, list)
    assert len(recipients) > 0
    assert "recipient_id" in recipients[0]
    assert "preferred_channels" in recipients[0]

    # Test versioned endpoint
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response_v1 = await ac.post("/api/v1/recipients/resolve", json=payload)
    assert response_v1.status_code == 200
    assert len(response_v1.json()) > 0


@pytest.mark.asyncio
async def test_risk_predict_endpoint():
    features = {
        "latitude": 27.15,
        "longitude": 93.65,
        "rainfall_24h": 90.0,
        "slope": 30.0,
        "soil_moisture": 0.65
    }
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post("/api/v1/risk/predict", json=features)
    assert response.status_code == 200
    data = response.json()
    assert "area_id" in data
    assert "risk_score" in data
    assert "risk_band" in data
    assert data["risk_band"] in ["NORMAL", "WATCH", "WARNING", "CRITICAL"]

