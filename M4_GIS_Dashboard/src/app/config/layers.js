/**
 * Configuration-driven GIS Layer definitions
 * Categorized into: Risk, Environmental, Events, Infrastructure
 */

export const GIS_LAYER_CATEGORIES = [
  { id: 'risk', name: 'RISK & SUSCEPTIBILITY', icon: 'ShieldAlert' },
  { id: 'environmental', name: 'ENVIRONMENTAL MONITORING', icon: 'CloudRain' },
  { id: 'events', name: 'LANDSLIDE / REPORT DATA', icon: 'FileText' },
  { id: 'infrastructure', name: 'INFRASTRUCTURE', icon: 'Building2' }
];

export const INITIAL_GIS_LAYERS = [
  // 1. RISK & SUSCEPTIBILITY
  {
    id: 'susceptibility',
    name: 'Landslide Susceptibility',
    category: 'risk',
    description: 'Geological, slope gradient, lithology, and land-use susceptibility index surface',
    visible: true,
    opacity: 0.65,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: true,
    legendType: 'susceptibility-gradient',
    icon: 'Activity'
  },
  {
    id: 'current-risk',
    name: 'Current Risk',
    category: 'risk',
    description: 'Dynamic ML risk surface inference driven by real-time telemetry (LOW to CRITICAL)',
    visible: true,
    opacity: 0.75,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: true,
    legendType: 'risk-categories',
    icon: 'ShieldAlert'
  },

  // 2. ENVIRONMENTAL MONITORING
  {
    id: 'rainfall',
    name: 'Rainfall',
    category: 'environmental',
    description: 'GPM IMERG 24h satellite rainfall accumulation heatmap grid (mm)',
    visible: false,
    opacity: 0.60,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: false,
    legendType: 'rainfall-heatmap',
    icon: 'CloudRain',
    timePeriod: 'Last 24 hours'
  },
  {
    id: 'soil-moisture',
    name: 'Soil Moisture',
    category: 'environmental',
    description: 'Continuous surface soil saturation heatmap (% volumetric water content)',
    visible: false,
    opacity: 0.55,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: false,
    legendType: 'soil-moisture-gradient',
    icon: 'Droplets'
  },
  {
    id: 'sar-observations',
    name: 'SAR Observations',
    category: 'environmental',
    description: 'Sentinel-1 InSAR millimeter-level ground deformation shift vectors',
    visible: false,
    opacity: 0.85,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: false,
    legendType: 'sar-graduated',
    icon: 'Radio'
  },

  // 3. LANDSLIDE / REPORT DATA
  {
    id: 'historical-landslides',
    name: 'Historical Landslides',
    category: 'events',
    description: 'Geological Survey of India (GSI) historical landslide incident catalog',
    visible: false,
    opacity: 0.85,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: false,
    legendType: 'marker-historical',
    icon: 'History'
  },
  {
    id: 'citizen-reports',
    name: 'Citizen Reports',
    category: 'events',
    description: 'Crowdsourced unverified landslide sightings submitted via mobile/web',
    visible: true,
    opacity: 1.0,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: true,
    legendType: 'marker-citizen',
    icon: 'UserAlert'
  },
  {
    id: 'verified-reports',
    name: 'Verified Reports',
    category: 'events',
    description: 'Ground-truthed reports verified by District Disaster Management Officers (DDMO)',
    visible: true,
    opacity: 1.0,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: true,
    legendType: 'marker-verified',
    icon: 'CheckCircle2'
  },

  // 4. INFRASTRUCTURE
  {
    id: 'roads',
    name: 'Roads',
    category: 'infrastructure',
    description: 'National Highways (NH-415, TAH-229), arterial connects, and rural roads',
    visible: true,
    opacity: 0.90,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: true,
    legendType: 'line-roads',
    icon: 'Navigation'
  },
  {
    id: 'villages',
    name: 'Villages',
    category: 'infrastructure',
    description: 'Rural habitations, administrative settlements, and indigenous village clusters',
    visible: true,
    opacity: 0.85,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: true,
    legendType: 'marker-villages',
    icon: 'Home'
  },
  {
    id: 'schools',
    name: 'Schools',
    category: 'infrastructure',
    description: 'Primary schools, higher secondary institutions, and university campuses',
    visible: false,
    opacity: 0.90,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: false,
    legendType: 'marker-schools',
    icon: 'GraduationCap'
  },
  {
    id: 'hospitals',
    name: 'Hospitals',
    category: 'infrastructure',
    description: 'District hospitals, tertiary care medical institutes (TRIHMS), and health centers',
    visible: false,
    opacity: 0.90,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: false,
    legendType: 'marker-hospitals',
    icon: 'Cross'
  },
  {
    id: 'critical-infrastructure',
    name: 'Critical Infrastructure',
    category: 'infrastructure',
    description: 'Pare River bridges, culverts, emergency operation centres, and power assets',
    visible: true,
    opacity: 0.95,
    sourceType: 'geojson',
    interactive: true,
    defaultOn: true,
    legendType: 'marker-critical-infra',
    icon: 'Zap'
  }
];
