/**
 * Categorized Infrastructure Facilities and Habitations for Arunachal Pradesh
 * Separated into Villages, Schools, Hospitals, and Critical Infrastructure
 */

// 1. VILLAGES & SETTLEMENTS
export const VILLAGES_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "vil-sagalee",
      properties: {
        infra_id: "VIL-01",
        name: "Sagalee Town & Circle HQ",
        district: "Papum Pare",
        category: "Village",
        type: "Sub-Divisional HQ",
        population: 4200,
        risk_exposure: "CRITICAL",
        nearest_road: "Trans-Arunachal Highway (NH-229)"
      },
      geometry: { type: "Point", coordinates: [93.4280, 27.2370] }
    },
    {
      type: "Feature",
      id: "vil-yupia",
      properties: {
        infra_id: "VIL-02",
        name: "Yupia Model Village & District HQ",
        district: "Papum Pare",
        category: "Village",
        type: "District HQ Settlement",
        population: 3400,
        risk_exposure: "MODERATE",
        nearest_road: "Yupia Access Road"
      },
      geometry: { type: "Point", coordinates: [93.6650, 27.1420] }
    },
    {
      type: "Feature",
      id: "vil-tawang",
      properties: {
        infra_id: "VIL-03",
        name: "Tawang Town & Monastery Sector",
        district: "Tawang",
        category: "Village",
        type: "District HQ",
        population: 11200,
        risk_exposure: "HIGH",
        nearest_road: "NH-229 Tawang Highway"
      },
      geometry: { type: "Point", coordinates: [91.8600, 27.5800] }
    },
    {
      type: "Feature",
      id: "vil-bomdila",
      properties: {
        infra_id: "VIL-04",
        name: "Bomdila Township",
        district: "West Kameng",
        category: "Village",
        type: "District HQ",
        population: 8400,
        risk_exposure: "HIGH",
        nearest_road: "NH-229 Bhalukpong Road"
      },
      geometry: { type: "Point", coordinates: [92.4000, 27.2600] }
    },
    {
      type: "Feature",
      id: "vil-ziro",
      properties: {
        infra_id: "VIL-05",
        name: "Ziro Valley & Hapoli Town",
        district: "Lower Subansiri",
        category: "Village",
        type: "District HQ",
        population: 12800,
        risk_exposure: "MODERATE",
        nearest_road: "Itanagar-Ziro Road"
      },
      geometry: { type: "Point", coordinates: [93.8300, 27.5500] }
    },
    {
      type: "Feature",
      id: "vil-pasighat",
      properties: {
        infra_id: "VIL-06",
        name: "Pasighat Smart City",
        district: "East Siang",
        category: "Village",
        type: "District HQ",
        population: 28000,
        risk_exposure: "HIGH",
        nearest_road: "Pasighat-Pangin Highway"
      },
      geometry: { type: "Point", coordinates: [95.3300, 28.0600] }
    },
    {
      type: "Feature",
      id: "vil-anini",
      properties: {
        infra_id: "VIL-07",
        name: "Anini Frontier HQ",
        district: "Dibang Valley",
        category: "Village",
        type: "District HQ",
        population: 2400,
        risk_exposure: "CRITICAL",
        nearest_road: "NH-313 Roing-Anini Road"
      },
      geometry: { type: "Point", coordinates: [95.8000, 28.8000] }
    },
    {
      type: "Feature",
      id: "vil-mechuka",
      properties: {
        infra_id: "VIL-08",
        name: "Mechuka Border Township",
        district: "Shi Yomi",
        category: "Village",
        type: "Border Settlement",
        population: 3100,
        risk_exposure: "HIGH",
        nearest_road: "Aalo-Mechuka Road"
      },
      geometry: { type: "Point", coordinates: [94.1300, 28.6000] }
    }
  ]
};

// 2. SCHOOLS & EDUCATIONAL INSTITUTIONS
export const SCHOOLS_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "school-rgu",
      properties: {
        infra_id: "SCH-01",
        name: "Rajiv Gandhi University (RGU) Campus",
        district: "Papum Pare",
        category: "School",
        type: "Central University",
        location: "Rono Hills, Doimukh",
        students_count: 4500,
        risk_exposure: "LOW",
        nearest_road: "Doimukh Main Road"
      },
      geometry: { type: "Point", coordinates: [93.7650, 27.1480] }
    },
    {
      type: "Feature",
      id: "school-jnv-tawang",
      properties: {
        infra_id: "SCH-02",
        name: "Jawahar Navodaya Vidyalaya Tawang",
        district: "Tawang",
        category: "School",
        type: "Navodaya Residential School",
        location: "Tawang",
        students_count: 520,
        risk_exposure: "HIGH",
        nearest_road: "NH-229 Tawang Highway"
      },
      geometry: { type: "Point", coordinates: [91.8650, 27.5850] }
    }
  ]
};

// 3. HOSPITALS & HEALTHCARE FACILITIES
export const HOSPITALS_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "hosp-trihms",
      properties: {
        infra_id: "HSP-01",
        name: "Tomo Riba Institute of Health & Medical Sciences (TRIHMS)",
        district: "Papum Pare",
        category: "Hospital",
        type: "Tertiary Referral Medical Institute",
        location: "Naharlagun",
        beds: 500,
        risk_exposure: "MODERATE",
        nearest_road: "NH-415",
        emergency_helipad: true,
        contact: "+91 360 2350331"
      },
      geometry: { type: "Point", coordinates: [93.6920, 27.1080] }
    },
    {
      type: "Feature",
      id: "hosp-tawang",
      properties: {
        infra_id: "HSP-02",
        name: "Khandro Drowa Tsangmu District Hospital Tawang",
        district: "Tawang",
        category: "Hospital",
        type: "District Hospital",
        location: "Tawang HQ",
        beds: 120,
        risk_exposure: "HIGH",
        nearest_road: "NH-229",
        emergency_helipad: true,
        contact: "+91 3794 222234"
      },
      geometry: { type: "Point", coordinates: [91.8620, 27.5790] }
    },
    {
      type: "Feature",
      id: "hosp-pasighat",
      properties: {
        infra_id: "HSP-03",
        name: "Bakin Pertin General Hospital Pasighat",
        district: "East Siang",
        category: "Hospital",
        type: "Zonal General Hospital",
        location: "Pasighat",
        beds: 300,
        risk_exposure: "HIGH",
        nearest_road: "Pasighat-Pangin Highway",
        emergency_helipad: true,
        contact: "+91 368 2222231"
      },
      geometry: { type: "Point", coordinates: [95.3320, 28.0620] }
    }
  ]
};

// 4. CRITICAL INFRASTRUCTURE
export const CRITICAL_INFRASTRUCTURE_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "crit-sela-tunnel",
      properties: {
        infra_id: "CRT-01",
        name: "Sela Tunnel & Twin Tube Portal Complex",
        district: "Tawang / West Kameng",
        category: "Critical Infrastructure",
        type: "Strategic High-Altitude Highway Tunnel",
        location: "Sela Pass",
        span_meters: 12000,
        risk_exposure: "CRITICAL",
        nearest_road: "NH-229",
        status: "24/7 Debris & Avalanche Watch Active"
      },
      geometry: { type: "Point", coordinates: [92.1000, 27.5000] }
    },
    {
      type: "Feature",
      id: "crit-pare-bridge",
      properties: {
        infra_id: "CRT-02",
        name: "Pare River Reinforced Steel Bridge",
        district: "Papum Pare",
        category: "Critical Infrastructure",
        type: "Major River Span Bridge",
        location: "Doimukh - Sagalee Crossing",
        span_meters: 180,
        risk_exposure: "CRITICAL",
        nearest_road: "Trans-Arunachal Highway",
        status: "Structural Sensor Monitoring Active"
      },
      geometry: { type: "Point", coordinates: [93.5800, 27.1850] }
    },
    {
      type: "Feature",
      id: "crit-itanagar-eoc",
      properties: {
        infra_id: "CRT-03",
        name: "State Emergency Operations Centre (SEOC) Itanagar",
        district: "Papum Pare",
        category: "Critical Infrastructure",
        type: "State Command Center",
        location: "Itanagar Secretariat",
        risk_exposure: "MODERATE",
        nearest_road: "NH-415",
        status: "24/7 State Command Control Room Active"
      },
      geometry: { type: "Point", coordinates: [93.6166, 27.1000] }
    }
  ]
};

// Combined Export
export const INFRASTRUCTURE_GEOJSON = {
  type: "FeatureCollection",
  features: [
    ...VILLAGES_GEOJSON.features,
    ...SCHOOLS_GEOJSON.features,
    ...HOSPITALS_GEOJSON.features,
    ...CRITICAL_INFRASTRUCTURE_GEOJSON.features
  ]
};

