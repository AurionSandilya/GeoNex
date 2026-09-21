/**
 * GeoJSON FeatureCollection for Papum Pare District Boundary & Sub-divisions
 */

export const PAPUM_PARE_BOUNDARY_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "papum-pare-boundary",
      properties: {
        district: "Papum Pare",
        state: "Arunachal Pradesh",
        headquarters: "Yupia",
        area_sq_km: 2875,
        risk_summary: "High slope instability along NH-415 and Pare river basin"
      },
      geometry: {
        type: "Polygon",
        coordinates: [[
          [93.30, 27.00],
          [93.35, 27.20],
          [93.42, 27.38],
          [93.55, 27.45],
          [93.75, 27.42],
          [93.95, 27.30],
          [93.98, 27.10],
          [93.85, 26.95],
          [93.60, 26.90],
          [93.30, 27.00]
        ]]
      }
    }
  ]
};

export const SUBDIVISIONS_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      properties: { name: "Sagalee Sub-Division", risk_level: "CRITICAL", hq: "Sagalee", risk_score: 0.88 },
      geometry: { type: "Point", coordinates: [93.4300, 27.2400] }
    },
    {
      type: "Feature",
      properties: { name: "Mengio Circle", risk_level: "CRITICAL", hq: "Mengio", risk_score: 0.91 },
      geometry: { type: "Point", coordinates: [93.4800, 27.4200] }
    },
    {
      type: "Feature",
      properties: { name: "Naharlagun Circle", risk_level: "HIGH", hq: "Naharlagun", risk_score: 0.74 },
      geometry: { type: "Point", coordinates: [93.6890, 27.1060] }
    },
    {
      type: "Feature",
      properties: { name: "Doimukh Circle", risk_level: "HIGH", hq: "Doimukh", risk_score: 0.71 },
      geometry: { type: "Point", coordinates: [93.7500, 27.1400] }
    },
    {
      type: "Feature",
      properties: { name: "Yupia Headquarters", risk_level: "MODERATE", hq: "Yupia", risk_score: 0.58 },
      geometry: { type: "Point", coordinates: [93.6620, 27.1400] }
    },
    {
      type: "Feature",
      properties: { name: "Itanagar Capital Circle", risk_level: "MODERATE", hq: "Itanagar", risk_score: 0.49 },
      geometry: { type: "Point", coordinates: [93.6166, 27.1000] }
    },
    {
      type: "Feature",
      properties: { name: "Toru Circle", risk_level: "HIGH", hq: "Toru", risk_score: 0.79 },
      geometry: { type: "Point", coordinates: [93.5200, 27.2800] }
    }
  ]
};
