import { INSAR_DISPLACEMENT_GEOJSON, RAINFALL_GRID_GEOJSON } from '../../data/geojson/environmentalGrid.js';

// M3 has no /environmental/* routes - there is no satellite rainfall/InSAR
// ingestion pipeline behind them yet (M1/M3 don't ingest IMERG GPM or
// Sentinel-1 data in this codebase). Calling apiFetch here always 404'd and
// silently fell back to demo data, which looked identical to a real "live"
// response in the UI (audit §5.18/§3.9). Per the audit's own framing -
// "either build the endpoints or remove the calls, but don't leave the
// silent 404-to-mock path in place" - this pass removes the calls rather
// than fabricating a satellite pipeline; every method here is honestly
// `source: 'mock'` until M3 actually has these endpoints.
export const environmentalService = {
  /**
   * Rainfall telemetry grid - demo data only (see file header).
   */
  async getRainfallGrid() {
    return { data: RAINFALL_GRID_GEOJSON, source: 'mock' };
  },

  /**
   * Sentinel-1 InSAR millimeter slope displacement vector grid - demo data only (see file header).
   */
  async getInSARDisplacement() {
    return { data: INSAR_DISPLACEMENT_GEOJSON, source: 'mock' };
  },

  /**
   * 24-hour rainfall cumulative progression timeline - demo data only (see file header).
   */
  async getRainfallTimeline() {
    return {
      data: [
        { time: '00:00', rainfall: 12.4, riskScore: 0.35, threshold: 80 },
        { time: '04:00', rainfall: 28.0, riskScore: 0.42, threshold: 80 },
        { time: '08:00', rainfall: 54.2, riskScore: 0.58, threshold: 80 },
        { time: '12:00', rainfall: 92.5, riskScore: 0.74, threshold: 80 },
        { time: '16:00', rainfall: 148.5, riskScore: 0.92, threshold: 80 },
        { time: '20:00', rainfall: 162.0, riskScore: 0.91, threshold: 80 }
      ],
      source: 'mock',
    };
  }
};
