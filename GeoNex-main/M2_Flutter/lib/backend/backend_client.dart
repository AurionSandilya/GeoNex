import '../core/constants/app_constants.dart';
import '../core/models/action_item.dart';
import '../core/models/alert_model.dart';
import '../core/models/citizen_report.dart';
import '../core/models/exposure_asset.dart';
import '../core/models/priority_item.dart';
import '../core/models/region_summary.dart';
import '../core/models/risk_data.dart';
import '../core/models/route_model.dart';

/// Abstract backend interface representing the Hybrid Backend (Supabase + PostGIS + Custom APIs).
abstract class BackendClient {
  // Locations & Risk
  Future<List<RiskLocation>> getRiskLocations();
  Future<RiskLocation?> getRiskLocationById(String id);
  Future<void> updateDynamicConditions(String locationId, DynamicConditions conditions);

  // Exposure Assets
  Future<List<ExposureAsset>> getExposureAssets({String? locationId});

  // Priority Items
  Future<List<PriorityItem>> getPriorityQueue();

  // Action Items
  Future<List<ActionItem>> getActions({String? locationId});
  Future<void> updateActionStatus(String actionId, ActionStatus status, {String? notes});
  Future<ActionItem> createAction(ActionItem action);

  // Alerts
  Future<List<AlertModel>> getAlerts({AlertStatus? status});
  Future<void> triggerAlert(AlertModel alert);
  Future<void> resolveAlert(String alertId);

  // Citizen & Field Reports
  Future<List<CitizenReport>> getReports({ReportVerificationStatus? status});
  Future<CitizenReport> submitReport(CitizenReport report);
  Future<void> verifyReport(String reportId, ReportVerificationStatus status, {String? verifiedBy, String? notes});

  // Risk-Aware Routes
  Future<List<RiskRoute>> getRiskAwareRoutes(String origin, String destination);

  // Analytics & History
  Future<List<DistrictRiskSummary>> getDistrictSummaries();
  Future<List<RegionHistoryEntry>> getRegionHistory(String districtName);
}
