/**
 * Road Network & Highway Segments for Arunachal Pradesh
 */

export const ROAD_NETWORK_GEOJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "road-nh415",
      properties: {
        road_id: "RD-NH415",
        name: "National Highway 415 (NH-415)",
        district: "Papum Pare",
        type: "National Highway",
        route: "Itanagar - Naharlagun - Banderdewa",
        length_km: 34.5,
        hazard_level: "HIGH",
        vulnerable_choke_points: "Karsingsa slope & Ganga Lake junction",
        status: "Active Traffic - Watch Advisory"
      },
      geometry: {
        type: "LineString",
        coordinates: [
          [93.6166, 27.1000],
          [93.6400, 27.1020],
          [93.6890, 27.1060],
          [93.7200, 27.1200],
          [93.7800, 27.1400],
          [93.8200, 27.1550]
        ]
      }
    },
    {
      type: "Feature",
      id: "road-tah-sagalee",
      properties: {
        road_id: "RD-TAH229",
        name: "Trans-Arunachal Highway (NH-229 / Sagalee Sector)",
        district: "Papum Pare",
        type: "Trans-Arunachal Highway",
        route: "Doimukh - Toru - Sagalee - Nechipu",
        length_km: 78.0,
        hazard_level: "CRITICAL",
        vulnerable_choke_points: "Pare Bridge approach & Sagalee bypass km 42-46",
        status: "High Risk - Restricted Heavy Vehicles"
      },
      geometry: {
        type: "LineString",
        coordinates: [
          [93.7500, 27.1400],
          [93.6500, 27.2000],
          [93.5200, 27.2800],
          [93.4300, 27.2400],
          [93.3800, 27.2200]
        ]
      }
    },
    {
      type: "Feature",
      id: "road-tawang-highway",
      properties: {
        road_id: "RD-TW229",
        name: "Bhalukpong - Dirang - Tawang Highway (NH-229)",
        district: "Tawang / West Kameng",
        type: "National Highway",
        route: "Bhalukpong - Bomdila - Dirang - Sela Pass - Tawang",
        length_km: 185.0,
        hazard_level: "CRITICAL",
        vulnerable_choke_points: "Sela Pass km 135-142 & Dirang escarpment",
        status: "Landslide Risk - Border Patrol Escort Active"
      },
      geometry: {
        type: "LineString",
        coordinates: [
          [92.6400, 27.0100],
          [92.4000, 27.2000],
          [92.4000, 27.2600],
          [92.2300, 27.3600],
          [92.1000, 27.5000],
          [91.9800, 27.5700],
          [91.8600, 27.5800]
        ]
      }
    },
    {
      type: "Feature",
      id: "road-roing-anini",
      properties: {
        road_id: "RD-NH313",
        name: "Roing - Hunli - Anini Highway (NH-313)",
        district: "Lower Dibang Valley / Dibang Valley",
        type: "National Highway",
        route: "Roing - Hunli - Etalin - Anini",
        length_km: 235.0,
        hazard_level: "CRITICAL",
        vulnerable_choke_points: "Hunli escarpment & Etalin gorge km 180",
        status: "Debris Clearing active at km 164"
      },
      geometry: {
        type: "LineString",
        coordinates: [
          [95.8300, 28.1400],
          [95.9500, 28.3200],
          [95.8800, 28.6200],
          [95.8000, 28.8000]
        ]
      }
    },
    {
      type: "Feature",
      id: "road-pasighat-yingkiong",
      properties: {
        road_id: "RD-PSGH01",
        name: "Pasighat - Pangin - Yingkiong Highway",
        district: "East Siang / Siang / Upper Siang",
        type: "Arterial Highway",
        route: "Pasighat - Ranaghat - Pangin - Boleng - Yingkiong",
        length_km: 142.0,
        hazard_level: "HIGH",
        vulnerable_choke_points: "Rotung slide zone & Pangin confluence",
        status: "Passable with caution"
      },
      geometry: {
        type: "LineString",
        coordinates: [
          [95.3300, 28.0600],
          [95.1000, 28.1800],
          [94.9800, 28.3000],
          [95.0200, 28.3500],
          [94.9300, 28.6200]
        ]
      }
    },
    {
      type: "Feature",
      id: "road-ziro-daporijo",
      properties: {
        road_id: "RD-ZRO02",
        name: "Ziro - Daporijo Highway Corridor",
        district: "Lower Subansiri / Upper Subansiri",
        type: "District Arterial",
        route: "Ziro - Yachuli - Raga - Daporijo",
        length_km: 160.0,
        hazard_level: "HIGH",
        vulnerable_choke_points: "Yachuli hill cut & Raga ridge",
        status: "Active monitoring"
      },
      geometry: {
        type: "LineString",
        coordinates: [
          [93.8300, 27.5500],
          [93.7600, 27.4500],
          [94.0000, 27.7000],
          [94.2200, 27.9800]
        ]
      }
    },
    {
      type: "Feature",
      id: "road-aalo-mechuka",
      properties: {
        road_id: "RD-MCH01",
        name: "Aalo - Tato - Mechuka Border Highway",
        district: "West Siang / Shi Yomi",
        type: "Strategic Border Road",
        route: "Aalo - Yomcha - Tato - Mechuka",
        length_km: 180.0,
        hazard_level: "CRITICAL",
        vulnerable_choke_points: "Siyom River gorge & Tato pass",
        status: "Controlled Military & Border Transport"
      },
      geometry: {
        type: "LineString",
        coordinates: [
          [94.8000, 28.1700],
          [94.6000, 28.2500],
          [94.3500, 28.6000],
          [94.1300, 28.6000]
        ]
      }
    }
  ]
};

