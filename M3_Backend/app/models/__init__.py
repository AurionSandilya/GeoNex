"""
app/models/__init__.py

Exports all models so Alembic can find them for migrations.
Every model must be imported here.
"""

from app.models.user import User, UserRole
from app.models.field_report import FieldReport, ReportType, ReportStatus
from app.models.media import Media, MediaType
from app.models.field_verification import FieldVerification, VerificationDecision
from app.models.landslide_inventory import LandslideInventory
from app.models.risk_prediction import RiskPrediction, RiskLevel
from app.models.observation import RainfallObservation, SoilMoistureObservation, SARObservation
from app.models.earthquake import EarthquakeEvent
from app.models.spatial import Road, Village, Infrastructure, InfrastructureCategory
from app.models.model_version import ModelVersion
from app.models.audit_log import AuditLog
# Note: Alert is owned by M5 (Alert Engine). M3 reads via app.models.alert.Alert on detached M5Base.
from app.models.alert import Alert, AlertStatus

__all__ = [
    "User", "UserRole",
    "FieldReport", "ReportType", "ReportStatus",
    "Media", "MediaType",
    "FieldVerification", "VerificationDecision",
    "LandslideInventory",
    "RiskPrediction", "RiskLevel",
    "RainfallObservation", "SoilMoistureObservation", "SARObservation",
    "EarthquakeEvent",
    "Road", "Village", "Infrastructure", "InfrastructureCategory",
    "ModelVersion",
    "AuditLog",
]
