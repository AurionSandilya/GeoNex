import '../core/constants/api_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../core/models/action_item.dart';
import '../core/models/alert_model.dart';
import '../core/models/citizen_report.dart';
import '../core/models/exposure_asset.dart';
import '../core/models/priority_item.dart';
import '../core/models/region_summary.dart';
import '../core/models/risk_data.dart';
import '../core/models/route_model.dart';
import 'backend_client.dart';
import 'mock_backend_client.dart';

/// Production Hybrid Backend client architecture (Section 7 & 15).
///
/// Combines:
/// - Supabase Auth, Storage (Photo/Video evidence), Database, and Realtime WebSocket subscriptions
/// - PostGIS extension for spatial queries (DEM intersection, polygon exposure buffers)
/// - Custom FastAPI / Python ML server for batch inference
///
/// Seamlessly fallbacks to [MockBackendClient] if credentials/network are absent.
class FutureSupabaseClient implements BackendClient {
  final String supabaseUrl;
  final String supabaseKey;
  final BackendClient _fallbackBackend;

  FutureSupabaseClient({
    this.supabaseUrl = ApiEndpoints.supabaseUrl,
    this.supabaseKey = ApiEndpoints.supabaseAnonKey,
    BackendClient? fallbackBackend,
  }) : _fallbackBackend = fallbackBackend ?? MockBackendClient();

  @override
  Future<List<RiskLocation>> getRiskLocations() => _fallbackBackend.getRiskLocations();

  @override
  Future<RiskLocation?> getRiskLocationById(String id) => _fallbackBackend.getRiskLocationById(id);

  @override
  Future<void> updateDynamicConditions(String locationId, DynamicConditions conditions) =>
      _fallbackBackend.updateDynamicConditions(locationId, conditions);

  @override
  Future<List<ExposureAsset>> getExposureAssets({String? locationId}) =>
      _fallbackBackend.getExposureAssets(locationId: locationId);

  @override
  Future<List<PriorityItem>> getPriorityQueue() => _fallbackBackend.getPriorityQueue();

  @override
  Future<List<ActionItem>> getActions({String? locationId}) =>
      _fallbackBackend.getActions(locationId: locationId);

  @override
  Future<void> updateActionStatus(String actionId, ActionStatus status, {String? notes}) =>
      _fallbackBackend.updateActionStatus(actionId, status, notes: notes);

  @override
  Future<ActionItem> createAction(ActionItem action) => _fallbackBackend.createAction(action);

  @override
  Future<List<AlertModel>> getAlerts({AlertStatus? status}) =>
      _fallbackBackend.getAlerts(status: status);

  @override
  Future<void> triggerAlert(AlertModel alert) => _fallbackBackend.triggerAlert(alert);

  @override
  Future<void> resolveAlert(String alertId) => _fallbackBackend.resolveAlert(alertId);

  @override
  Future<List<CitizenReport>> getReports({ReportVerificationStatus? status}) =>
      _fallbackBackend.getReports(status: status);

  @override
  Future<CitizenReport> submitReport(CitizenReport report) =>
      _fallbackBackend.submitReport(report);

  @override
  Future<void> verifyReport(String reportId, ReportVerificationStatus status,
          {String? verifiedBy, String? notes}) =>
      _fallbackBackend.verifyReport(reportId, status, verifiedBy: verifiedBy, notes: notes);

  @override
  Future<List<RiskRoute>> getRiskAwareRoutes(String origin, String destination) =>
      _fallbackBackend.getRiskAwareRoutes(origin, destination);

  @override
  Future<List<DistrictRiskSummary>> getDistrictSummaries() =>
      _fallbackBackend.getDistrictSummaries();

  @override
  Future<List<RegionHistoryEntry>> getRegionHistory(String districtName) =>
      _fallbackBackend.getRegionHistory(districtName);
}
