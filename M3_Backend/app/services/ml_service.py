"""
app/services/ml_service.py

M1 ML Model Integration Service.

Connects M3 to M1's dual-pipeline landslide susceptibility & dynamic trigger model:
- Static Susceptibility (Random Forest Pipeline: terrain, geology, land use)
- Dynamic Trigger (Random Forest Pipeline: rainfall accumulators, soil moisture)
- 2D Risk Matrix evaluation -> Final Risk Band (NORMAL, WATCH, WARNING, CRITICAL)

Also provides:
- Standard pure-Python geohash area_id derivation
- Robust fallback when running in lightweight environments without scikit-learn
"""

import logging
import math
import sys
from pathlib import Path
from typing import Dict, Any, Tuple

logger = logging.getLogger(__name__)

# Standard Base32 character map for Geohash encoding
_BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"


def lat_lon_to_geohash(latitude: float, longitude: float, precision: int = 6) -> str:
    """
    Encode latitude/longitude to a standard Geohash string of given precision.
    Precision 5 ~ 4.9km x 4.9km; Precision 6 ~ 1.2km x 0.6km.
    M5 Alert Engine uses this as the authoritative area_id for spatial monitoring.
    """
    lat_interval = [-90.0, 90.0]
    lon_interval = [-180.0, 180.0]
    geohash = []
    bits = [16, 8, 4, 2, 1]
    bit = 0
    ch = 0
    even = True

    while len(geohash) < precision:
        if even:
            mid = (lon_interval[0] + lon_interval[1]) / 2.0
            if longitude > mid:
                ch |= bits[bit]
                lon_interval[0] = mid
            else:
                lon_interval[1] = mid
        else:
            mid = (lat_interval[0] + lat_interval[1]) / 2.0
            if latitude > mid:
                ch |= bits[bit]
                lat_interval[0] = mid
            else:
                lat_interval[1] = mid

        even = not even
        if bit < 4:
            bit += 1
        else:
            geohash.append(_BASE32[ch])
            bit = 0
            ch = 0

    return "".join(geohash)


def map_m1_to_m5_risk_band(m1_level: str) -> str:
    """
    Map M1 4-class output to M5 Severity enum:
    M1: LOW, MODERATE, HIGH, VERY HIGH
    M5: NORMAL, WATCH, WARNING, CRITICAL
    """
    mapping = {
        "LOW": "NORMAL",
        "NORMAL": "NORMAL",
        "MODERATE": "WATCH",
        "WATCH": "WATCH",
        "HIGH": "WARNING",
        "WARNING": "WARNING",
        "VERY HIGH": "CRITICAL",
        "CRITICAL": "CRITICAL",
    }
    return mapping.get(m1_level.upper(), "NORMAL")


class MLModelService:
    def __init__(self):
        self.model_version = "v1.0-rf-dual"
        self._m1_module = None
        self._load_m1_module()

    def _load_m1_module(self):
        """
        Dynamically locate and load M1 inference module from M1_ML directory.
        """
        try:
            # Look up M1_ML folder relative to workspace
            current_file = Path(__file__).resolve()
            # M3_Backend is 2 levels below workspace root (app/services/ml_service.py -> app/services -> app -> M3_Backend -> root)
            workspace_root = current_file.parents[3]
            m1_path = workspace_root / "M1_ML"
            if m1_path.exists() and str(m1_path) not in sys.path:
                sys.path.insert(0, str(m1_path))

            # Enable sklearn compatibility patch if newer sklearn is present
            try:
                import sklearn.compose._column_transformer as ct
                if not hasattr(ct, "_RemainderColsList"):
                    class _RemainderColsList(list):
                        pass
                    ct._RemainderColsList = _RemainderColsList
                from sklearn.impute import SimpleImputer
                _orig_transform = SimpleImputer.transform
                def _patched_transform(self, X):
                    if not hasattr(self, "_fill_dtype"):
                        self._fill_dtype = getattr(self, "_fit_dtype", float)
                    return _orig_transform(self, X)
                SimpleImputer.transform = _patched_transform
            except Exception:
                pass

            import inference as m1_inference
            self._m1_module = m1_inference
            logger.info("Successfully loaded real M1 inference engine (dual Random Forest pipelines).")
        except Exception as exc:
            logger.warning("Real M1 inference module unavailable (%s). Using calibrated fallback engine.", exc)
            self._m1_module = None

    def _prepare_m1_features(self, features: Dict[str, Any]) -> Tuple[Dict[str, Any], Dict[str, Any]]:
        """
        Construct static & dynamic feature dictionaries matching M1 schema.
        Fills missing environmental features with intelligent regional defaults for Papum Pare / NER.
        """
        # Static terrain features (M1 STATIC_FEATURES)
        slope = float(features.get("slope", 25.0))
        elevation = float(features.get("elevation", 1150.0))
        curvature = float(features.get("curvature", 0.05))
        soil_type = str(features.get("soil_type", "Loam"))
        ndvi_2017 = float(features.get("ndvi_2017", 0.55))
        dist_river = float(features.get("distance_to_river_m", 350.0))
        dist_road = float(features.get("distance_to_road_m", 120.0))
        dist_village = float(features.get("distance_to_village_m", 450.0))
        aspect_sin = float(features.get("aspect_sin", 0.40))
        aspect_cos = float(features.get("aspect_cos", 0.60))

        static_features = {
            "elevation": elevation,
            "slope": slope,
            "curvature": curvature,
            "soil_type": soil_type,
            "ndvi_2017": ndvi_2017,
            "distance_to_river_m": dist_river,
            "distance_to_road_m": dist_road,
            "distance_to_village_m": dist_village,
            "aspect_sin": aspect_sin,
            "aspect_cos": aspect_cos,
        }

        # Dynamic trigger features (M1 DYNAMIC_FEATURES)
        rainfall_24h = float(features.get("rainfall_24h", features.get("rainfall_1d", 45.0)))
        rainfall_3d = float(features.get("rainfall_3d", rainfall_24h * 2.2))
        rainfall_7d = float(features.get("rainfall_7d", rainfall_24h * 4.5))
        rainfall_14d = float(features.get("rainfall_14d", rainfall_24h * 7.0))
        rainfall_30d = float(features.get("rainfall_30d", rainfall_24h * 11.0))
        soil_m = float(features.get("soil_moisture", 0.42))

        dynamic_features = {
            "rainfall_1d": rainfall_24h,
            "rainfall_3d": rainfall_3d,
            "rainfall_7d": rainfall_7d,
            "rainfall_14d": rainfall_14d,
            "rainfall_30d": rainfall_30d,
            "rainfall_max_3d": float(features.get("rainfall_max_3d", rainfall_24h * 1.3)),
            "rainfall_max_7d": float(features.get("rainfall_max_7d", rainfall_24h * 1.6)),
            "rainy_days_7d": int(features.get("rainy_days_7d", 5 if rainfall_24h > 20 else 2)),
            "rainy_days_14d": int(features.get("rainy_days_14d", 9 if rainfall_24h > 20 else 4)),
            "rainy_days_30d": int(features.get("rainy_days_30d", 18 if rainfall_24h > 20 else 8)),
            "soil_moisture": soil_m,
            "soil_moisture_3d_mean": float(features.get("soil_moisture_3d_mean", soil_m * 0.95)),
            "soil_moisture_7d_mean": float(features.get("soil_moisture_7d_mean", soil_m * 0.90)),
            "soil_moisture_change_3d": float(features.get("soil_moisture_change_3d", 0.04)),
            "soil_moisture_change_7d": float(features.get("soil_moisture_change_7d", 0.08)),
        }

        return static_features, dynamic_features

    async def predict_risk(self, features: Dict[str, Any]) -> Dict[str, Any]:
        """
        Calculates authoritative landslide risk score and risk band.
        Uses M1's dual trained Random Forest pipelines if available,
        with seamless fallback to calibrated heuristic matrix.
        """
        lat = float(features.get("latitude", 27.55))
        lon = float(features.get("longitude", 93.65))
        area_id = features.get("area_id") or lat_lon_to_geohash(lat, lon, precision=5)

        static_feat, dynamic_feat = self._prepare_m1_features(features)

        # 1. Try real M1 inference
        if self._m1_module is not None:
            try:
                res = self._m1_module.predict_risk(static_feat, dynamic_feat)
                static_score = float(res.get("static_score", 0.0))
                dynamic_score = float(res.get("dynamic_score", 0.0))
                m1_final_risk = str(res.get("final_risk", "LOW"))

                # Combined risk score (weighted dynamic + static)
                risk_score = round(min(max(0.60 * dynamic_score + 0.40 * static_score, 0.01), 0.99), 3)
                risk_band = map_m1_to_m5_risk_band(m1_final_risk)
                confidence = round(min(max(0.80 + (risk_score * 0.15), 0.50), 0.98), 2)

                return {
                    "area_id": area_id,
                    "risk_score": risk_score,
                    "risk_band": risk_band,
                    "risk_level": risk_band,
                    "confidence": confidence,
                    "model_version": self.model_version,
                    "m1_details": res,
                    "feature_snapshot": {**static_feat, **dynamic_feat, "latitude": lat, "longitude": lon},
                }
            except Exception as e:
                logger.error("Error executing M1 inference: %s. Using fallback.", e)

        # 2. Calibrated heuristic fallback matching M1 matrix
        rainfall_1d = dynamic_feat["rainfall_1d"]
        slope = static_feat["slope"]
        soil_m = dynamic_feat["soil_moisture"]

        # Static score proxy
        static_score = min(slope / 45.0, 1.0) * 0.70 + (1.0 - min(static_feat["distance_to_road_m"] / 500.0, 1.0)) * 0.30
        # Dynamic score proxy
        dynamic_score = min(rainfall_1d / 120.0, 1.0) * 0.65 + min(soil_m, 1.0) * 0.35

        score = round(min(max(0.60 * dynamic_score + 0.40 * static_score, 0.02), 0.98), 2)

        if score >= 0.70:
            band = "CRITICAL"
        elif score >= 0.50:
            band = "WARNING"
        elif score >= 0.30:
            band = "WATCH"
        else:
            band = "NORMAL"

        confidence = round(0.85 + (score * 0.10), 2)

        return {
            "area_id": area_id,
            "risk_score": score,
            "risk_band": band,
            "risk_level": band,
            "confidence": confidence,
            "model_version": "v1.0-heuristic-fallback",
            "m1_details": {"static_score": static_score, "dynamic_score": dynamic_score, "final_risk": band},
            "feature_snapshot": {**static_feat, **dynamic_feat, "latitude": lat, "longitude": lon},
        }


ml_service = MLModelService()
