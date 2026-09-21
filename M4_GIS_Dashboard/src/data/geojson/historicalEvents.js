/**
 * Historical Landslide Incident Catalog for Arunachal Pradesh (GSI & DDMO Verified Data)
 */

export const HISTORICAL_EVENTS_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "hist-2024-sela",
      properties: {
        event_id: "LS-TW-2024-002",
        title: "Sela Pass High-Altitude Rockfall & Debris Slide",
        date: "2024-08-28",
        year: 2024,
        district: "Tawang",
        location_name: "Sela Tunnel Approach (NH-229 km 138)",
        severity: "CRITICAL",
        rainfall_trigger_mm: 218.0,
        soil_moisture_at_event: 94.0,
        slope_deg: 52.0,
        casualties: 0,
        road_closure_days: 6,
        estimated_volume_m3: 32000,
        verification_status: "GSI Verified",
        description: "Severe snowmelt and torrential rainfall caused massive rock avalanche on NH-229 Sela Pass."
      },
      geometry: { type: "Point", coordinates: [92.1000, 27.5000] }
    },
    {
      type: "Feature",
      id: "hist-2024-sagalee",
      properties: {
        event_id: "LS-PP-2024-001",
        title: "Sagalee Highway Debris Flow Slump",
        date: "2024-07-14",
        year: 2024,
        district: "Papum Pare",
        location_name: "Trans-Arunachal Highway km 44 (Sagalee)",
        severity: "CRITICAL",
        rainfall_trigger_mm: 195.4,
        soil_moisture_at_event: 91.5,
        slope_deg: 44.0,
        casualties: 0,
        road_closure_days: 4,
        estimated_volume_m3: 14500,
        verification_status: "GSI Verified",
        description: "Torrential monsoon downpour triggered mass wasting of weathered sandstone and shale along highway cutting."
      },
      geometry: { type: "Point", coordinates: [93.4250, 27.2350] }
    },
    {
      type: "Feature",
      id: "hist-2023-anini",
      properties: {
        event_id: "LS-DV-2023-005",
        title: "Hunli-Anini NH-313 Escarpment Collapse",
        date: "2023-07-08",
        year: 2023,
        district: "Dibang Valley",
        location_name: "NH-313 Hunli Escarpment km 164",
        severity: "CRITICAL",
        rainfall_trigger_mm: 205.0,
        soil_moisture_at_event: 95.0,
        slope_deg: 48.0,
        casualties: 0,
        road_closure_days: 8,
        estimated_volume_m3: 24000,
        verification_status: "DDMO Ground Truthed",
        description: "Massive hill face failure severed communication line to Anini border headquarters."
      },
      geometry: { type: "Point", coordinates: [95.9500, 28.3200] }
    },
    {
      type: "Feature",
      id: "hist-2024-pasighat",
      properties: {
        event_id: "LS-ES-2024-003",
        title: "Pasighat Ranaghat Hill Slope Subsidence",
        date: "2024-06-19",
        year: 2024,
        district: "East Siang",
        location_name: "Pasighat-Pangin Corridor km 12",
        severity: "HIGH",
        rainfall_trigger_mm: 172.5,
        soil_moisture_at_event: 86.0,
        slope_deg: 36.0,
        casualties: 0,
        road_closure_days: 3,
        estimated_volume_m3: 9500,
        verification_status: "GSI Verified",
        description: "Overnight cloudburst washed away highway embankment protection works."
      },
      geometry: { type: "Point", coordinates: [95.3300, 28.0600] }
    },
    {
      type: "Feature",
      id: "hist-2023-karsingsa",
      properties: {
        event_id: "LS-PP-2023-008",
        title: "Karsingsa Blockage on NH-415",
        date: "2023-06-22",
        year: 2023,
        district: "Papum Pare",
        location_name: "NH-415 Karsingsa S-Bend",
        severity: "HIGH",
        rainfall_trigger_mm: 168.0,
        soil_moisture_at_event: 84.0,
        slope_deg: 38.0,
        casualties: 0,
        road_closure_days: 2,
        estimated_volume_m3: 8200,
        verification_status: "DDMO Ground Truthed",
        description: "Rockfall and mudflow blocked capital highway connection between Itanagar and Banderdewa."
      },
      geometry: { type: "Point", coordinates: [93.7420, 27.1280] }
    }
  ]
};

