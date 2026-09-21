import '../../backend/backend_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/action_item.dart';
import '../../core/models/alert_model.dart';
import '../../core/models/citizen_report.dart';
import '../../core/models/exposure_asset.dart';
import '../../core/models/priority_item.dart';
import '../../core/models/region_summary.dart';
import '../../core/models/risk_data.dart';
import '../../core/models/route_model.dart';

class RiskRepository {
  final BackendClient _backendClient;

  RiskRepository(this._backendClient);

  Future<List<RiskLocation>> getLocations() => _backendClient.getRiskLocations();
  Future<RiskLocation?> getLocationById(String id) => _backendClient.getRiskLocationById(id);
  Future<void> updateDynamicFactors(String locationId, DynamicConditions conditions) =>
      _backendClient.updateDynamicConditions(locationId, conditions);

  Future<List<ExposureAsset>> getAssets({String? locationId}) =>
      _backendClient.getExposureAssets(locationId: locationId);

  Future<List<PriorityItem>> getPriorityQueue() => _backendClient.getPriorityQueue();

  Future<List<ActionItem>> getActions({String? locationId}) =>
      _backendClient.getActions(locationId: locationId);
  Future<void> updateActionStatus(String actionId, ActionStatus status, {String? notes}) =>
      _backendClient.updateActionStatus(actionId, status, notes: notes);
  Future<ActionItem> addAction(ActionItem action) => _backendClient.createAction(action);

  Future<List<AlertModel>> getAlerts({AlertStatus? status}) =>
      _backendClient.getAlerts(status: status);
  Future<void> createAlert(AlertModel alert) => _backendClient.triggerAlert(alert);
  Future<void> resolveAlert(String alertId) => _backendClient.resolveAlert(alertId);

  Future<List<CitizenReport>> getReports({ReportVerificationStatus? status}) =>
      _backendClient.getReports(status: status);
  Future<CitizenReport> submitReport(CitizenReport report) =>
      _backendClient.submitReport(report);
  Future<void> verifyReport(String reportId, ReportVerificationStatus status,
          {String? verifiedBy, String? notes}) =>
      _backendClient.verifyReport(reportId, status, verifiedBy: verifiedBy, notes: notes);

  Future<List<RiskRoute>> getRoutes(String origin, String destination) =>
      _backendClient.getRiskAwareRoutes(origin, destination);

  Future<List<DistrictRiskSummary>> getDistrictSummaries() =>
      _backendClient.getDistrictSummaries();

  Future<List<RegionHistoryEntry>> getDistrictHistory(String district) =>
      _backendClient.getRegionHistory(district);
}
