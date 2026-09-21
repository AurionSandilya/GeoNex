import { apiFetch } from '../apiClient.js';

export const emergencyService = {
  /**
   * Fetch ranked emergency decision-support priority locations
   */
  async getEmergencyPriorities(minRiskScore = 0.50) {
    try {
      const result = await apiFetch(`/emergency/priorities?min_risk_score=${minRiskScore}`);
      // A successful response with an empty priorities array is real live
      // data (nothing currently meets the threshold), not a failure - only
      // an actual fetch exception below should fall back to demo data
      // (audit §5.10).
      if (result && Array.isArray(result.data)) {
        return { data: result.data, source: 'live' };
      }
      return { data: emergencyMockData(), source: 'mock' };
    } catch {
      return { data: emergencyMockData(), source: 'mock' };
    }
  }
};

function emergencyMockData() {
  return [
      {
        priority: "P1",
        location_name: "NH-229 KM-142 (Sagalee Pass)",
        coordinates: [93.42, 27.24],
        priority_score: 0.94,
        risk_score: 0.88,
        factors: {
          population_exposed: 4500,
          critical_assets: ["Sagalee Sub-Division Hospital", "Toru Access Bridge"],
          road_blockage_impact: "CRITICAL_TRANS_HIGHWAY"
        },
        recommendation: "Deploy emergency earthmovers squad and issue instant traffic rerouting."
      },
      {
        priority: "P2",
        location_name: "NH-415 Karsingsa S-Bend",
        coordinates: [93.72, 27.12],
        priority_score: 0.81,
        risk_score: 0.78,
        factors: {
          population_exposed: 2800,
          critical_assets: ["Power Substation", "Checkgate Access"],
          road_blockage_impact: "CAPITAL_ARTERIAL_ROAD"
        },
        recommendation: "Dispatch PWD field inspection officer for on-ground slope verification."
      },
      {
        priority: "P3",
        location_name: "Yupia District Secretariat Road",
        coordinates: [93.61, 27.15],
        priority_score: 0.64,
        risk_score: 0.62,
        factors: {
          population_exposed: 1100,
          critical_assets: ["Govt Hr Sec School"],
          road_blockage_impact: "LOCAL_ACCESS_HILL_ROAD"
        },
        recommendation: "Inspect hydromet rain gauges and clear hillside drainage channels."
      }
  ];
}
