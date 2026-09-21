/**
 * Dynamic Risk Zones & Susceptibility Polygons for Arunachal Pradesh
 */

export const RISK_ZONES_GEOJSON = {
  type: "FeatureCollection",
  features: [
    // PAPUM PARE - CRITICAL ZONE - Sagalee River Valley Corridor
    {
      type: "Feature",
      id: "zone-sagalee-corridor",
      properties: {
        zone_id: "RZ-PP-001",
        name: "Sagalee - Parang Highway Corridor",
        district: "Papum Pare",
        state: "Arunachal Pradesh",
        risk_level: "CRITICAL",
        risk_score: 0.92,
        confidence: 0.88,
        model_version: "v1.4-XGBoost",
        slope_deg: 42.5,
        rainfall_24h_mm: 148.5,
        soil_moisture_pct: 86.2,
        sar_shift_mm_yr: 18.4,
        susceptibility_index: 89,
        nearest_road: "Trans-Arunachal Highway (NH-229)",
        nearest_settlement: "Sagalee Town & Parang Village",
        population_exposed: 4200,
        hospitals_nearby: 1,
        schools_nearby: 3,
        last_updated: "2026-09-09T18:30:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [93.38, 27.20],
          [93.47, 27.22],
          [93.50, 27.29],
          [93.42, 27.31],
          [93.36, 27.25],
          [93.38, 27.20]
        ]]
      }
    },
    // PAPUM PARE - CRITICAL ZONE - Mengio Upper Hills
    {
      type: "Feature",
      id: "zone-mengio-hills",
      properties: {
        zone_id: "RZ-PP-002",
        name: "Mengio High Susceptibility Escarpment",
        district: "Papum Pare",
        state: "Arunachal Pradesh",
        risk_level: "CRITICAL",
        risk_score: 0.87,
        confidence: 0.84,
        model_version: "v1.4-XGBoost",
        slope_deg: 48.0,
        rainfall_24h_mm: 162.0,
        soil_moisture_pct: 89.1,
        sar_shift_mm_yr: 22.1,
        susceptibility_index: 92,
        nearest_road: "Sagalee-Mengio Arterial Road",
        nearest_settlement: "Mengio Village & Saki habitations",
        population_exposed: 1850,
        hospitals_nearby: 0,
        schools_nearby: 2,
        last_updated: "2026-09-09T18:30:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [93.44, 27.38],
          [93.54, 27.40],
          [93.52, 27.46],
          [93.42, 27.44],
          [93.44, 27.38]
        ]]
      }
    },
    // PAPUM PARE - HIGH ZONE - Karsingsa NH-415 Slope Cut
    {
      type: "Feature",
      id: "zone-karsingsa-cut",
      properties: {
        zone_id: "RZ-PP-003",
        name: "Karsingsa - Banderdewa NH-415 Slope Hazard",
        district: "Papum Pare",
        state: "Arunachal Pradesh",
        risk_level: "HIGH",
        risk_score: 0.76,
        confidence: 0.86,
        model_version: "v1.4-XGBoost",
        slope_deg: 36.0,
        rainfall_24h_mm: 112.0,
        soil_moisture_pct: 78.5,
        sar_shift_mm_yr: 11.2,
        susceptibility_index: 77,
        nearest_road: "National Highway 415 (NH-415)",
        nearest_settlement: "Karsingsa & Banderdewa Checkgate",
        population_exposed: 6500,
        hospitals_nearby: 1,
        schools_nearby: 4,
        last_updated: "2026-09-09T18:30:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [93.72, 27.12],
          [93.82, 27.14],
          [93.85, 27.20],
          [93.76, 27.18],
          [93.72, 27.12]
        ]]
      }
    },
    // TAWANG - CRITICAL ZONE - Sela Pass Tunnel & Slope Corridor
    {
      type: "Feature",
      id: "zone-sela-pass",
      properties: {
        zone_id: "RZ-TW-001",
        name: "Sela Pass High Altitude Debris Flow Corridor",
        district: "Tawang",
        state: "Arunachal Pradesh",
        risk_level: "CRITICAL",
        risk_score: 0.95,
        confidence: 0.91,
        model_version: "v1.4-XGBoost",
        slope_deg: 52.0,
        rainfall_24h_mm: 175.0,
        soil_moisture_pct: 91.0,
        sar_shift_mm_yr: 28.5,
        susceptibility_index: 96,
        nearest_road: "Bhalukpong-Tawang Highway (NH-229)",
        nearest_settlement: "Jang & Jaswant Garh",
        population_exposed: 3100,
        hospitals_nearby: 1,
        schools_nearby: 1,
        last_updated: "2026-09-10T12:00:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [92.05, 27.46],
          [92.15, 27.48],
          [92.18, 27.53],
          [92.08, 27.52],
          [92.05, 27.46]
        ]]
      }
    },
    // WEST KAMENG - HIGH ZONE - Dirang Valley Escarpment
    {
      type: "Feature",
      id: "zone-dirang-valley",
      properties: {
        zone_id: "RZ-WK-001",
        name: "Dirang - Bomdila Ridge Escarpment",
        district: "West Kameng",
        state: "Arunachal Pradesh",
        risk_level: "HIGH",
        risk_score: 0.81,
        confidence: 0.87,
        model_version: "v1.4-XGBoost",
        slope_deg: 40.0,
        rainfall_24h_mm: 130.0,
        soil_moisture_pct: 82.0,
        sar_shift_mm_yr: 15.0,
        susceptibility_index: 81,
        nearest_road: "NH-229 Arterial",
        nearest_settlement: "Dirang Township & Munna Camp",
        population_exposed: 5400,
        hospitals_nearby: 1,
        schools_nearby: 3,
        last_updated: "2026-09-10T12:00:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [92.20, 27.32],
          [92.28, 27.34],
          [92.30, 27.40],
          [92.22, 27.38],
          [92.20, 27.32]
        ]]
      }
    },
    // LOWER SUBANSIRI - CRITICAL ZONE - Yachuli Highway Cut
    {
      type: "Feature",
      id: "zone-yachuli-cut",
      properties: {
        zone_id: "RZ-LS-001",
        name: "Yachuli - Ziro Access Corridor Escarpment",
        district: "Lower Subansiri",
        state: "Arunachal Pradesh",
        risk_level: "CRITICAL",
        risk_score: 0.88,
        confidence: 0.89,
        model_version: "v1.4-XGBoost",
        slope_deg: 44.0,
        rainfall_24h_mm: 155.0,
        soil_moisture_pct: 87.5,
        sar_shift_mm_yr: 19.2,
        susceptibility_index: 89,
        nearest_road: "Itanagar-Ziro Road",
        nearest_settlement: "Yachuli Market & Pistana Circle",
        population_exposed: 6200,
        hospitals_nearby: 1,
        schools_nearby: 4,
        last_updated: "2026-09-10T12:00:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [93.72, 27.42],
          [93.80, 27.44],
          [93.78, 27.50],
          [93.70, 27.48],
          [93.72, 27.42]
        ]]
      }
    },
    // EAST SIANG - HIGH ZONE - Pasighat River Bank Escarpment
    {
      type: "Feature",
      id: "zone-pasighat-escarpment",
      properties: {
        zone_id: "RZ-ES-001",
        name: "Pasighat Hill Slope & Mebo Erosion Edge",
        district: "East Siang",
        state: "Arunachal Pradesh",
        risk_level: "HIGH",
        risk_score: 0.79,
        confidence: 0.85,
        model_version: "v1.4-XGBoost",
        slope_deg: 35.0,
        rainfall_24h_mm: 140.0,
        soil_moisture_pct: 80.0,
        sar_shift_mm_yr: 13.5,
        susceptibility_index: 79,
        nearest_road: "Pasighat-Pangin Highway",
        nearest_settlement: "Pasighat Town & Mebo Circle",
        population_exposed: 14000,
        hospitals_nearby: 2,
        schools_nearby: 5,
        last_updated: "2026-09-10T12:00:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [95.30, 28.02],
          [95.42, 28.04],
          [95.40, 28.10],
          [95.28, 28.08],
          [95.30, 28.02]
        ]]
      }
    },
    // DIBANG VALLEY - CRITICAL ZONE - Anini - Etalin Gorge
    {
      type: "Feature",
      id: "zone-anini-gorge",
      properties: {
        zone_id: "RZ-DV-001",
        name: "Anini - Etalin High Mountain Active Cut",
        district: "Dibang Valley",
        state: "Arunachal Pradesh",
        risk_level: "CRITICAL",
        risk_score: 0.94,
        confidence: 0.90,
        model_version: "v1.4-XGBoost",
        slope_deg: 50.0,
        rainfall_24h_mm: 185.0,
        soil_moisture_pct: 92.0,
        sar_shift_mm_yr: 26.0,
        susceptibility_index: 95,
        nearest_road: "Roing-Anini Highway (NH-313)",
        nearest_settlement: "Anini Town & Etalin Village",
        population_exposed: 2400,
        hospitals_nearby: 1,
        schools_nearby: 2,
        last_updated: "2026-09-10T12:00:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [95.74, 28.60],
          [95.86, 28.62],
          [95.84, 28.72],
          [95.72, 28.70],
          [95.74, 28.60]
        ]]
      }
    },
    // SHI YOMI - HIGH ZONE - Mechuka Valley Escarpment
    {
      type: "Feature",
      id: "zone-mechuka-valley",
      properties: {
        zone_id: "RZ-SY-001",
        name: "Mechuka Valley Airfield Slope Cut",
        district: "Shi Yomi",
        state: "Arunachal Pradesh",
        risk_level: "HIGH",
        risk_score: 0.82,
        confidence: 0.86,
        model_version: "v1.4-XGBoost",
        slope_deg: 38.0,
        rainfall_24h_mm: 128.0,
        soil_moisture_pct: 81.5,
        sar_shift_mm_yr: 14.2,
        susceptibility_index: 82,
        nearest_road: "Aalo-Mechuka Border Highway",
        nearest_settlement: "Mechuka Town & Tato HQ",
        population_exposed: 3500,
        hospitals_nearby: 1,
        schools_nearby: 2,
        last_updated: "2026-09-10T12:00:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [94.08, 28.56],
          [94.18, 28.58],
          [94.16, 28.64],
          [94.06, 28.62],
          [94.08, 28.56]
        ]]
      }
    },
    // TIRAP - CRITICAL ZONE - Khonsa Ridge Slope Cut
    {
      type: "Feature",
      id: "zone-khonsa-ridge",
      properties: {
        zone_id: "RZ-TR-001",
        name: "Khonsa Mountain Ridge Active Slide",
        district: "Tirap",
        state: "Arunachal Pradesh",
        risk_level: "CRITICAL",
        risk_score: 0.89,
        confidence: 0.88,
        model_version: "v1.4-XGBoost",
        slope_deg: 43.0,
        rainfall_24h_mm: 152.0,
        soil_moisture_pct: 88.0,
        sar_shift_mm_yr: 20.1,
        susceptibility_index: 90,
        nearest_road: "Khonsa-Deomali Arterial Road",
        nearest_settlement: "Khonsa HQ & Deomali",
        population_exposed: 8900,
        hospitals_nearby: 1,
        schools_nearby: 4,
        last_updated: "2026-09-10T12:00:00Z"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [95.44, 26.98],
          [95.54, 27.00],
          [95.52, 27.06],
          [95.42, 27.04],
          [95.44, 26.98]
        ]]
      }
    }
  ]
};

