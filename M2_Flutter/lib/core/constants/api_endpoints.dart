class ApiEndpoints {
  // Central M3 FastAPI backend (Local / Production configurable)
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // Section 5 & 14: REST API Specifications
  static const String riskLocation = '/risk/location'; // GET ?lat=&lng=
  static const String riskRoad = '/risk/road'; // GET /risk/road/{id}
  static const String riskArea = '/risk/area'; // GET ?bbox=
  static const String alertsActive = '/alerts/active'; // GET
  static const String routesRiskAware = '/routes/risk-aware'; // GET
  static const String riskHistory = '/risk/history'; // GET ?locationId=
  static const String regionsSummary = '/regions/summary'; // GET
  static const String reports = '/reports'; // POST (Submit report)
  static const String reportVerify = '/reports/{id}/verify'; // POST (Verify report)
  static const String actionStatus = '/actions/{id}/status'; // POST (Update action status)

  // Map & GIS Services (Google Maps Platform)
  static const String googleMapsApiKey = 'ROTATED_PLACEHOLDER_SET_VIA_ENV_OR_CI_SECRET';

  // Hybrid Backend (Supabase + PostGIS) Placeholders
  static const String supabaseUrl = 'https://xyzcompany.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  static const String postgisSpatialQuery = '/rpc/get_landslide_exposure_polygons';
}
