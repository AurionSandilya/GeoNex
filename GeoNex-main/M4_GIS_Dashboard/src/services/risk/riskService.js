import { RISK_ZONES_GEOJSON } from '../../data/geojson/riskZones.js';
import { apiFetch } from '../apiClient.js';
import { evaluateSpatialRisk } from './spatialRiskEvaluator.js';

export const riskService = {
  /**
   * Fetch spatial GeoJSON risk area grid (M4 GIS Dashboard layer)
   */
  async getRiskArea(minLat = 26.8, maxLat = 27.6, minLon = 93.1, maxLon = 94.0) {
    try {
      const data = await apiFetch(`/risk/area?min_lat=${minLat}&max_lat=${maxLat}&min_lon=${minLon}&max_lon=${maxLon}`);
      // A successful response with an empty FeatureCollection is a real
      // "no risk zones currently computed" answer, not a failure - only an
      // actual fetch exception below should fall back to demo data
      // (audit §5.10).
      if (data && Array.isArray(data.features)) {
        return { data, source: 'live' };
      }
      return { data: RISK_ZONES_GEOJSON, source: 'mock' };
    } catch {
      return { data: RISK_ZONES_GEOJSON, source: 'mock' };
    }
  },

  /**
   * Fetch AI prediction for a single coordinate point (M1 interface)
   * If backend is not available, uses rich spatialRiskEvaluator
   */
  async getRiskByLocation(lat, lon, rainfall24h = null, slope = null) {
    const spatialAssessment = evaluateSpatialRisk(lat, lon);
    const rain = rainfall24h !== null ? rainfall24h : spatialAssessment.rainfall_24h;
    const slp = slope !== null ? slope : spatialAssessment.slope_deg;

    try {
      const liveData = await apiFetch(`/risk/location?lat=${lat}&lon=${lon}&rainfall_24h=${rain}&slope=${slp}`);
      if (liveData) {
        return {
          ...spatialAssessment,
          ...liveData,
          risk_score: liveData.risk_score ?? spatialAssessment.risk_score,
          risk_level: liveData.risk_level ?? spatialAssessment.risk_level,
          confidence: liveData.confidence ?? spatialAssessment.confidence,
          rainfall_24h: liveData.rainfall_24h ?? rain,
          slope_deg: liveData.slope ?? slp,
          source: 'live',
        };
      }
      return { ...spatialAssessment, source: 'mock' };
    } catch {
      return { ...spatialAssessment, source: 'mock' };
    }
  },

  /**
   * Directly evaluate spatial risk for tapped coordinate point
   */
  evaluatePointRisk(lat, lon) {
    return evaluateSpatialRisk(lat, lon);
  }
};

