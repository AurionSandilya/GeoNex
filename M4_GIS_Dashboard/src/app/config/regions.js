/**
 * Geographic Configuration for Arunachal Pradesh Landslide Monitoring Platform
 * Supports hierarchy: North-East India -> State (Arunachal Pradesh) -> District -> Sub-Division/Sector
 */

export const NORTH_EAST_REGIONS = [
  {
    id: 'ne-india',
    name: 'North-East India Region',
    level: 'REGION',
    center: [93.6166, 27.1000],
    defaultZoom: 7.8,
    enabled: true,
    states: [
      {
        id: 'arunachal-pradesh',
        name: 'Arunachal Pradesh',
        level: 'STATE',
        center: [93.6166, 27.1000],
        defaultZoom: 8.2,
        enabled: true,
        districts: [
          {
            id: 'papum-pare',
            name: 'Papum Pare',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [93.65, 27.15],
            defaultZoom: 10.5,
            bounds: [[93.30, 26.90], [94.00, 27.40]],
            headquarters: 'Yupia',
            areaSqKm: 2875,
            population: 176573,
            enabled: true,
            areas: [
              { id: 'itanagar', name: 'Itanagar Capital Complex', center: [93.6166, 27.1000], riskLevel: 'MODERATE' },
              { id: 'naharlagun', name: 'Naharlagun', center: [93.6890, 27.1060], riskLevel: 'HIGH' },
              { id: 'yupia', name: 'Yupia HQ', center: [93.6620, 27.1400], riskLevel: 'MODERATE' },
              { id: 'doimukh', name: 'Doimukh', center: [93.7500, 27.1400], riskLevel: 'HIGH' },
              { id: 'sagalee', name: 'Sagalee Highway Corridor', center: [93.4300, 27.2400], riskLevel: 'CRITICAL' },
              { id: 'toru', name: 'Toru Circle', center: [93.5200, 27.2800], riskLevel: 'HIGH' },
              { id: 'mengio', name: 'Mengio Sub-Division', center: [93.4800, 27.4200], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'tawang',
            name: 'Tawang',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [91.86, 27.58],
            defaultZoom: 10.5,
            bounds: [[91.50, 27.35], [92.20, 27.85]],
            headquarters: 'Tawang',
            areaSqKm: 2172,
            population: 49977,
            enabled: true,
            areas: [
              { id: 'tawang-town', name: 'Tawang Monastery & HQ', center: [91.8600, 27.5800], riskLevel: 'HIGH' },
              { id: 'sela-pass', name: 'Sela Pass Corridor (NH-229)', center: [92.1000, 27.5000], riskLevel: 'CRITICAL' },
              { id: 'jang', name: 'Jang Sub-Division', center: [91.9800, 27.5700], riskLevel: 'HIGH' },
              { id: 'lumla', name: 'Lumla Border Sector', center: [91.7100, 27.5200], riskLevel: 'MODERATE' },
              { id: 'zemithang', name: 'Zemithang Valley', center: [91.7200, 27.7100], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'west-kameng',
            name: 'West Kameng',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [92.40, 27.30],
            defaultZoom: 10,
            bounds: [[92.00, 26.90], [92.80, 27.60]],
            headquarters: 'Bomdila',
            areaSqKm: 7422,
            population: 84000,
            enabled: true,
            areas: [
              { id: 'bomdila', name: 'Bomdila District HQ', center: [92.4000, 27.2600], riskLevel: 'HIGH' },
              { id: 'dirang', name: 'Dirang Valley Corridor', center: [92.2300, 27.3600], riskLevel: 'CRITICAL' },
              { id: 'bhalukpong', name: 'Bhalukpong Gate', center: [92.6400, 27.0100], riskLevel: 'HIGH' },
              { id: 'rupa', name: 'Rupa Township', center: [92.4000, 27.2000], riskLevel: 'MODERATE' }
            ]
          },
          {
            id: 'east-kameng',
            name: 'East Kameng',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [93.03, 27.35],
            defaultZoom: 10,
            bounds: [[92.70, 26.90], [93.40, 27.80]],
            headquarters: 'Seppa',
            areaSqKm: 4134,
            population: 78690,
            enabled: true,
            areas: [
              { id: 'seppa', name: 'Seppa District HQ', center: [93.0300, 27.3500], riskLevel: 'HIGH' },
              { id: 'chayangtajo', name: 'Chayang Tajo', center: [93.1200, 27.6000], riskLevel: 'CRITICAL' },
              { id: 'bameng', name: 'Bameng Sub-Division', center: [92.9500, 27.5000], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'pakke-kessang',
            name: 'Pakke Kessang',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [93.18, 27.02],
            defaultZoom: 10,
            bounds: [[92.90, 26.80], [93.40, 27.20]],
            headquarters: 'Lemmi',
            areaSqKm: 1932,
            population: 32000,
            enabled: true,
            areas: [
              { id: 'lemmi', name: 'Lemmi District HQ', center: [93.1800, 27.0200], riskLevel: 'MODERATE' },
              { id: 'seijosa', name: 'Seijosa Foothills', center: [93.0800, 26.9500], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'lower-subansiri',
            name: 'Lower Subansiri',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [93.83, 27.55],
            defaultZoom: 10,
            bounds: [[93.50, 27.30], [94.10, 27.80]],
            headquarters: 'Ziro',
            areaSqKm: 3460,
            population: 83060,
            enabled: true,
            areas: [
              { id: 'ziro', name: 'Ziro Valley Plateau', center: [93.8300, 27.5500], riskLevel: 'MODERATE' },
              { id: 'yachuli', name: 'Yachuli Highway Cut', center: [93.7600, 27.4500], riskLevel: 'CRITICAL' },
              { id: 'pistana', name: 'Pistana Circle', center: [93.7000, 27.5200], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'kurung-kumey',
            name: 'Kurung Kumey',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [93.35, 27.90],
            defaultZoom: 9.8,
            bounds: [[93.00, 27.60], [93.80, 28.20]],
            headquarters: 'Koloriang',
            areaSqKm: 6340,
            population: 92830,
            enabled: true,
            areas: [
              { id: 'koloriang', name: 'Koloriang Border HQ', center: [93.3500, 27.9000], riskLevel: 'CRITICAL' },
              { id: 'nyapin', name: 'Nyapin Circle', center: [93.4200, 27.7500], riskLevel: 'HIGH' },
              { id: 'sangram', name: 'Sangram Sub-Division', center: [93.5200, 27.7000], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'kra-daadi',
            name: 'Kra Daadi',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [93.65, 27.82],
            defaultZoom: 9.8,
            bounds: [[93.40, 27.60], [93.90, 28.10]],
            headquarters: 'Jamin',
            areaSqKm: 4180,
            population: 43000,
            enabled: true,
            areas: [
              { id: 'palin', name: 'Palin Town', center: [93.6200, 27.7200], riskLevel: 'HIGH' },
              { id: 'chambang', name: 'Chambang Circle', center: [93.7500, 27.9200], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'upper-subansiri',
            name: 'Upper Subansiri',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [94.22, 27.98],
            defaultZoom: 9.8,
            bounds: [[93.80, 27.60], [94.60, 28.40]],
            headquarters: 'Daporijo',
            areaSqKm: 7032,
            population: 83490,
            enabled: true,
            areas: [
              { id: 'daporijo', name: 'Daporijo District HQ', center: [94.2200, 27.9800], riskLevel: 'HIGH' },
              { id: 'dumporijo', name: 'Dumporijo Sub-Division', center: [94.2800, 27.9200], riskLevel: 'CRITICAL' },
              { id: 'nacho', name: 'Nacho Border Pass', center: [93.9500, 28.2500], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'west-siang',
            name: 'West Siang',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [94.80, 28.17],
            defaultZoom: 9.8,
            bounds: [[94.40, 27.80], [95.10, 28.50]],
            headquarters: 'Aalo',
            areaSqKm: 8325,
            population: 112270,
            enabled: true,
            areas: [
              { id: 'aalo', name: 'Aalo District HQ', center: [94.8000, 28.1700], riskLevel: 'HIGH' },
              { id: 'yomcha', name: 'Yomcha Circle', center: [94.6000, 28.2500], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'east-siang',
            name: 'East Siang',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [95.33, 28.06],
            defaultZoom: 10,
            bounds: [[95.00, 27.80], [95.60, 28.30]],
            headquarters: 'Pasighat',
            areaSqKm: 4005,
            population: 99214,
            enabled: true,
            areas: [
              { id: 'pasighat', name: 'Pasighat Smart City Corridor', center: [95.3300, 28.0600], riskLevel: 'HIGH' },
              { id: 'mebo', name: 'Mebo River Bank Sector', center: [95.4500, 28.0200], riskLevel: 'CRITICAL' },
              { id: 'ruksin', name: 'Ruksin Border Gate', center: [95.2000, 27.8500], riskLevel: 'MODERATE' }
            ]
          },
          {
            id: 'siang',
            name: 'Siang',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [94.98, 28.30],
            defaultZoom: 9.8,
            bounds: [[94.70, 28.00], [95.20, 28.60]],
            headquarters: 'Pangin',
            areaSqKm: 2919,
            population: 34000,
            enabled: true,
            areas: [
              { id: 'pangin', name: 'Pangin HQ', center: [94.9800, 28.3000], riskLevel: 'CRITICAL' },
              { id: 'boleng', name: 'Boleng Sub-Division', center: [95.0200, 28.3500], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'upper-siang',
            name: 'Upper Siang',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [94.93, 28.62],
            defaultZoom: 9.5,
            bounds: [[94.40, 28.20], [95.40, 29.10]],
            headquarters: 'Yingkiong',
            areaSqKm: 6188,
            population: 35320,
            enabled: true,
            areas: [
              { id: 'yingkiong', name: 'Yingkiong HQ', center: [94.9300, 28.6200], riskLevel: 'HIGH' },
              { id: 'tuting', name: 'Tuting LAC Border Sector', center: [94.9000, 28.9800], riskLevel: 'CRITICAL' },
              { id: 'geku', name: 'Geku Circle', center: [95.0500, 28.4800], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'shi-yomi',
            name: 'Shi Yomi',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [94.35, 28.60],
            defaultZoom: 9.5,
            bounds: [[94.00, 28.30], [94.70, 28.90]],
            headquarters: 'Tato',
            areaSqKm: 2875,
            population: 13310,
            enabled: true,
            areas: [
              { id: 'mechuka', name: 'Mechuka Valley Airfield', center: [94.1300, 28.6000], riskLevel: 'HIGH' },
              { id: 'tato', name: 'Tato District HQ', center: [94.3500, 28.6000], riskLevel: 'CRITICAL' },
              { id: 'monigong', name: 'Monigong Border Post', center: [94.2800, 28.7500], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'lepa-rada',
            name: 'Lepa Rada',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [94.67, 27.98],
            defaultZoom: 10,
            bounds: [[94.40, 27.80], [94.90, 28.20]],
            headquarters: 'Basar',
            areaSqKm: 1800,
            population: 28000,
            enabled: true,
            areas: [
              { id: 'basar', name: 'Basar Town', center: [94.6700, 27.9800], riskLevel: 'HIGH' },
              { id: 'tirbin', name: 'Tirbin Circle', center: [94.5500, 28.0500], riskLevel: 'MODERATE' }
            ]
          },
          {
            id: 'lower-dibang-valley',
            name: 'Lower Dibang Valley',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [95.83, 28.14],
            defaultZoom: 9.8,
            bounds: [[95.40, 27.80], [96.20, 28.50]],
            headquarters: 'Roing',
            areaSqKm: 3900,
            population: 54080,
            enabled: true,
            areas: [
              { id: 'roing', name: 'Roing Town', center: [95.8300, 28.1400], riskLevel: 'HIGH' },
              { id: 'dambuk', name: 'Dambuk Orange Corridor', center: [95.5500, 28.1500], riskLevel: 'CRITICAL' },
              { id: 'hunli', name: 'Hunli Mountain Escarpment', center: [95.9500, 28.3200], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'dibang-valley',
            name: 'Dibang Valley',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [95.80, 28.80],
            defaultZoom: 9.5,
            bounds: [[95.20, 28.40], [96.40, 29.40]],
            headquarters: 'Anini',
            areaSqKm: 9129,
            population: 8004,
            enabled: true,
            areas: [
              { id: 'anini', name: 'Anini Town & HQ', center: [95.8000, 28.8000], riskLevel: 'CRITICAL' },
              { id: 'etalin', name: 'Etalin Hydro Project Site', center: [95.8800, 28.6200], riskLevel: 'CRITICAL' },
              { id: 'mipi', name: 'Mipi Frontier Sector', center: [95.7500, 28.9500], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'lohit',
            name: 'Lohit',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [96.16, 27.91],
            defaultZoom: 9.8,
            bounds: [[95.80, 27.60], [96.50, 28.20]],
            headquarters: 'Tezu',
            areaSqKm: 2402,
            population: 145720,
            enabled: true,
            areas: [
              { id: 'tezu', name: 'Tezu Airport Corridor', center: [96.1600, 27.9100], riskLevel: 'MODERATE' },
              { id: 'wakro', name: 'Wakro Parasuram Kund', center: [96.3500, 27.8000], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'namsai',
            name: 'Namsai',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [95.86, 27.67],
            defaultZoom: 10.2,
            bounds: [[95.60, 27.50], [96.10, 27.85]],
            headquarters: 'Namsai',
            areaSqKm: 1587,
            population: 95950,
            enabled: true,
            areas: [
              { id: 'namsai', name: 'Namsai Golden Pagoda Town', center: [95.8600, 27.6700], riskLevel: 'MODERATE' },
              { id: 'chongkham', name: 'Chongkham Circle', center: [95.9700, 27.6500], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'anjaw',
            name: 'Anjaw',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [96.80, 28.05],
            defaultZoom: 9.2,
            bounds: [[96.20, 27.60], [97.40, 28.40]],
            headquarters: 'Hawai',
            areaSqKm: 6190,
            population: 21167,
            enabled: true,
            areas: [
              { id: 'hawai', name: 'Hawai HQ', center: [96.8000, 28.0500], riskLevel: 'CRITICAL' },
              { id: 'hayuliang', name: 'Hayuliang Junction', center: [96.5300, 27.9500], riskLevel: 'HIGH' },
              { id: 'kibithu', name: 'Kibithu Easternmost Border', center: [97.0200, 28.2500], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'changlang',
            name: 'Changlang',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [95.73, 27.12],
            defaultZoom: 9.8,
            bounds: [[95.30, 26.70], [96.20, 27.50]],
            headquarters: 'Changlang',
            areaSqKm: 4662,
            population: 148226,
            enabled: true,
            areas: [
              { id: 'changlang', name: 'Changlang HQ', center: [95.7300, 27.1200], riskLevel: 'HIGH' },
              { id: 'miao', name: 'Miao Namdapha Edge', center: [96.2000, 27.4800], riskLevel: 'HIGH' },
              { id: 'jairampur', name: 'Jairampur Stillwell Road', center: [96.0500, 27.3500], riskLevel: 'CRITICAL' }
            ]
          },
          {
            id: 'tirap',
            name: 'Tirap',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [95.49, 27.02],
            defaultZoom: 10.2,
            bounds: [[95.20, 26.80], [95.70, 27.20]],
            headquarters: 'Khonsa',
            areaSqKm: 2362,
            population: 49460,
            enabled: true,
            areas: [
              { id: 'khonsa', name: 'Khonsa Town & HQ', center: [95.4900, 27.0200], riskLevel: 'CRITICAL' },
              { id: 'deomali', name: 'Deomali Foothills', center: [95.4800, 27.1600], riskLevel: 'HIGH' }
            ]
          },
          {
            id: 'longding',
            name: 'Longding',
            level: 'DISTRICT',
            state: 'Arunachal Pradesh',
            center: [95.20, 26.85],
            defaultZoom: 10,
            bounds: [[95.00, 26.60], [95.40, 27.00]],
            headquarters: 'Longding',
            areaSqKm: 1200,
            population: 56953,
            enabled: true,
            areas: [
              { id: 'longding', name: 'Longding Town', center: [95.2000, 26.8500], riskLevel: 'HIGH' },
              { id: 'kanubari', name: 'Kanubari Sector', center: [95.0800, 26.9000], riskLevel: 'MODERATE' }
            ]
          }
        ]
      }
    ]
  }
];

export const DEFAULT_REGION = NORTH_EAST_REGIONS[0];
export const DEFAULT_STATE = NORTH_EAST_REGIONS[0].states[0]; // Arunachal Pradesh
export const DEFAULT_DISTRICT = NORTH_EAST_REGIONS[0].states[0].districts[0]; // Papum Pare

