/**
 * Subsystem Health & Status Configuration (Modules M1 to M6)
 */

export const INITIAL_SYSTEM_STATUS = [
  {
    id: 'm1-ml-engine',
    module: 'M1',
    name: 'Landslide Susceptibility & ML Inference Pipeline',
    status: 'OPERATIONAL',
    latencyMs: 142,
    lastSync: '2 mins ago',
    details: 'XGBoost + Random Forest ensemble model v1.4 active. Processing 10m grid spatial features.'
  },
  {
    id: 'm2-citizen-reports',
    module: 'M2',
    name: 'Citizen Report Ingestion Gateway',
    status: 'OPERATIONAL',
    latencyMs: 85,
    lastSync: 'Just now',
    details: 'Web & SMS report gateway active. 14 unverified reports in Queue.'
  },
  {
    id: 'm3-backend-postgis',
    module: 'M3',
    name: 'Backend API & PostGIS Spatial DB',
    status: 'OPERATIONAL',
    latencyMs: 45,
    lastSync: 'Just now',
    details: 'PostgreSQL 16 + PostGIS 3.4 running. Spatial index spatial_ref_sys EPSG:4326 verified.'
  },
  {
    id: 'm4-gis-dashboard',
    module: 'M4',
    name: 'GIS Operational Command Center (Frontend)',
    status: 'OPERATIONAL',
    latencyMs: 12,
    lastSync: 'Live',
    details: 'MapLibre GL client active. Vector layer tile cache hit rate 98.4%.'
  },
  {
    id: 'm5-alerts-environmental',
    module: 'M5',
    name: 'Alert Dispatch & Satellite Feeds (GPM/InSAR)',
    status: 'OPERATIONAL',
    latencyMs: 310,
    lastSync: '15 mins ago',
    details: 'GPM IMERG 24h precipitation stream connected. Sentinel-1 SAR orbit pass sync completed.'
  },
  {
    id: 'm6-verification-devops',
    module: 'M6',
    name: 'Field Verification & Operational Reliability',
    status: 'OPERATIONAL',
    latencyMs: 65,
    lastSync: '1 hour ago',
    details: 'District Disaster Management Office (DDMO) verification sync active.'
  }
];
