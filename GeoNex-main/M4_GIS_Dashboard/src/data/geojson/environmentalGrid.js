/**
 * Environmental & Continuous Surface GeoJSON Data Grids
 * Includes GPM IMERG 24h Rainfall, SMAP Soil Moisture, and InSAR Displacement Vectors
 */

export const RAINFALL_GRID_GEOJSON = {
  type: "FeatureCollection",
  features: [
    { type: "Feature", properties: { rainfall_24h_mm: 195.5, intensity: "EXTREME" }, geometry: { type: "Point", coordinates: [93.48, 27.42] } },
    { type: "Feature", properties: { rainfall_24h_mm: 182.0, intensity: "HEAVY" }, geometry: { type: "Point", coordinates: [93.45, 27.38] } },
    { type: "Feature", properties: { rainfall_24h_mm: 168.5, intensity: "HEAVY" }, geometry: { type: "Point", coordinates: [93.43, 27.24] } },
    { type: "Feature", properties: { rainfall_24h_mm: 154.0, intensity: "HEAVY" }, geometry: { type: "Point", coordinates: [93.39, 27.22] } },
    { type: "Feature", properties: { rainfall_24h_mm: 142.5, intensity: "HEAVY" }, geometry: { type: "Point", coordinates: [93.52, 27.28] } },
    { type: "Feature", properties: { rainfall_24h_mm: 130.0, intensity: "MODERATE_HEAVY" }, geometry: { type: "Point", coordinates: [93.58, 27.26] } },
    { type: "Feature", properties: { rainfall_24h_mm: 121.0, intensity: "MODERATE" }, geometry: { type: "Point", coordinates: [93.75, 27.14] } },
    { type: "Feature", properties: { rainfall_24h_mm: 115.0, intensity: "MODERATE" }, geometry: { type: "Point", properties: {}, coordinates: [93.72, 27.12] } },
    { type: "Feature", properties: { rainfall_24h_mm: 98.0, intensity: "MODERATE" }, geometry: { type: "Point", coordinates: [93.66, 27.14] } },
    { type: "Feature", properties: { rainfall_24h_mm: 82.0, intensity: "LIGHT_MODERATE" }, geometry: { type: "Point", coordinates: [93.61, 27.10] } },
    { type: "Feature", properties: { rainfall_24h_mm: 65.0, intensity: "LIGHT" }, geometry: { type: "Point", coordinates: [93.78, 27.16] } },
    { type: "Feature", properties: { rainfall_24h_mm: 52.0, intensity: "LIGHT" }, geometry: { type: "Point", coordinates: [93.82, 27.18] } }
  ]
};

export const SOIL_MOISTURE_GRID_GEOJSON = {
  type: "FeatureCollection",
  features: [
    { type: "Feature", properties: { soil_moisture_pct: 94.2, status: "SATURATED" }, geometry: { type: "Point", coordinates: [93.47, 27.41] } },
    { type: "Feature", properties: { soil_moisture_pct: 91.5, status: "SATURATED" }, geometry: { type: "Point", coordinates: [93.42, 27.23] } },
    { type: "Feature", properties: { soil_moisture_pct: 88.0, status: "NEAR_SATURATION" }, geometry: { type: "Point", coordinates: [93.45, 27.29] } },
    { type: "Feature", properties: { soil_moisture_pct: 84.5, status: "HIGH" }, geometry: { type: "Point", coordinates: [93.51, 27.27] } },
    { type: "Feature", properties: { soil_moisture_pct: 79.2, status: "HIGH" }, geometry: { type: "Point", coordinates: [93.74, 27.13] } },
    { type: "Feature", properties: { soil_moisture_pct: 73.0, status: "ELEVATED" }, geometry: { type: "Point", coordinates: [93.67, 27.13] } },
    { type: "Feature", properties: { soil_moisture_pct: 66.4, status: "MODERATE" }, geometry: { type: "Point", coordinates: [93.60, 27.09] } },
    { type: "Feature", properties: { soil_moisture_pct: 54.0, status: "NORMAL" }, geometry: { type: "Point", coordinates: [93.77, 27.15] } }
  ]
};

export const INSAR_DISPLACEMENT_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "sar-001",
      properties: { point_id: "SAR-PP-104", displacement_mm_yr: -24.8, trend: "Accelerating Downslope", direction: "LOS Downward", confidence: 0.94, location: "Sagalee Escarpment Cut" },
      geometry: { type: "Point", coordinates: [93.4320, 27.2420] }
    },
    {
      type: "Feature",
      id: "sar-002",
      properties: { point_id: "SAR-PP-109", displacement_mm_yr: -19.4, trend: "Accelerating Downslope", direction: "LOS Downward", confidence: 0.91, location: "Mengio High Ridge" },
      geometry: { type: "Point", coordinates: [93.4820, 27.4220] }
    },
    {
      type: "Feature",
      id: "sar-003",
      properties: { point_id: "SAR-PP-112", displacement_mm_yr: -14.2, trend: "Steady Creep", direction: "LOS Lateral", confidence: 0.88, location: "Karsingsa S-Cut" },
      geometry: { type: "Point", coordinates: [93.7440, 27.1240] }
    },
    {
      type: "Feature",
      id: "sar-004",
      properties: { point_id: "SAR-PP-118", displacement_mm_yr: -9.5, trend: "Minor Subsidence", direction: "LOS Vertical", confidence: 0.86, location: "Toru Mountain Pass" },
      geometry: { type: "Point", coordinates: [93.5220, 27.2820] }
    },
    {
      type: "Feature",
      id: "sar-005",
      properties: { point_id: "SAR-PP-122", displacement_mm_yr: -4.1, trend: "Stable Hill Slope", direction: "LOS Minimal", confidence: 0.92, location: "Yupia Access Hill" },
      geometry: { type: "Point", coordinates: [93.6680, 27.1350] }
    }
  ]
};

export const SUSCEPTIBILITY_GRID_GEOJSON = {
  type: "FeatureCollection",
  features: [
    { type: "Feature", properties: { lsi_score: 95, category: "VERY_HIGH" }, geometry: { type: "Point", coordinates: [93.47, 27.42] } },
    { type: "Feature", properties: { lsi_score: 91, category: "VERY_HIGH" }, geometry: { type: "Point", coordinates: [93.43, 27.24] } },
    { type: "Feature", properties: { lsi_score: 84, category: "HIGH" }, geometry: { type: "Point", coordinates: [93.51, 27.28] } },
    { type: "Feature", properties: { lsi_score: 78, category: "HIGH" }, geometry: { type: "Point", coordinates: [93.74, 27.13] } },
    { type: "Feature", properties: { lsi_score: 62, category: "MODERATE" }, geometry: { type: "Point", coordinates: [93.66, 27.13] } },
    { type: "Feature", properties: { lsi_score: 45, category: "LOW" }, geometry: { type: "Point", coordinates: [93.60, 27.09] } },
    { type: "Feature", properties: { lsi_score: 22, category: "VERY_LOW" }, geometry: { type: "Point", coordinates: [93.77, 27.15] } }
  ]
};
