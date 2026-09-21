import '../ai/mock_risk_engine.dart';
import '../ai/risk_engine.dart';
import '../core/constants/app_constants.dart';
import '../core/models/action_item.dart';
import '../core/models/alert_model.dart';
import '../core/models/citizen_report.dart';
import '../core/models/exposure_asset.dart';
import '../core/models/priority_item.dart';
import '../core/models/region_summary.dart';
import '../core/models/risk_data.dart';
import '../core/models/route_model.dart';
import '../data/mock/mock_alerts.dart';
import '../data/mock/mock_analytics.dart';
import '../data/mock/mock_assets.dart';
import '../data/mock/mock_locations.dart';
import '../data/mock/mock_reports.dart';
import '../data/mock/mock_routes.dart';
import 'backend_client.dart';

/// In-memory reactive implementation of [BackendClient]
/// powering the fully functional prototype.
class MockBackendClient implements BackendClient {
  final RiskEngine _riskEngine;

  late List<RiskLocation> _locations;
  late List<ExposureAsset> _assets;
  late List<ActionItem> _actions;
  late List<AlertModel> _alerts;
  late List<CitizenReport> _reports;

  MockBackendClient({RiskEngine? riskEngine})
      : _riskEngine = riskEngine ?? const MockRiskEngine() {
    _initData();
  }

  void _initData() {
    _locations = MockLocationsData.getInitialLocations();
    _assets = MockAssetsData.getInitialAssets();
    _alerts = MockAlertsData.getInitialAlerts();
    _reports = MockReportsData.getInitialReports();

    // Calculate initial risk scores for all locations
    _locations = _locations.map((loc) {
      final res = _riskEngine.calculateRiskSync(
        locationId: loc.id,
        susceptibility: loc.susceptibility,
        dynamicConditions: loc.dynamicConditions,
      );
      return loc.copyWith(calculatedResult: res);
    }).toList();

    // Generate initial actions
    _actions = [
      ActionItem(
        actionId: 'act_001',
        locationId: 'loc_papum_pare',
        locationName: 'Papum Pare (NH-415 Corridor)',
        actionType: ActionType.inspect,
        title: 'Immediate Field Inspection at NH-415 Ch 14+200',
        rationale: 'Tension crack reported with 86/100 risk score and continuous rainfall.',
        status: ActionStatus.pending,
        assignedAuthority: 'BRO 44th Border Roads Task Force',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        dueTime: DateTime.now().add(const Duration(hours: 2)),
      ),
      ActionItem(
        actionId: 'act_002',
        locationId: 'loc_papum_pare',
        locationName: 'Papum Pare (NH-415 Corridor)',
        actionType: ActionType.prepare,
        title: 'Prepare Emergency Road Closure & Divert to Route B',
        rationale: 'Severe debris accumulation probability. Keep Nirjuli Ridge Bypass primed.',
        status: ActionStatus.pending,
        assignedAuthority: 'District Disaster Management Authority (DDMA)',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        dueTime: DateTime.now().add(const Duration(hours: 4)),
      ),
      ActionItem(
        actionId: 'act_003',
        locationId: 'loc_papum_pare',
        locationName: 'Papum Pare (NH-415 Corridor)',
        actionType: ActionType.escalate,
        title: 'Notify Local Authority & Village Council (Doimukh)',
        rationale: 'Alert downstream ward of potential flash debris runout.',
        status: ActionStatus.inProgress,
        assignedAuthority: 'Deputy Commissioner Secretariat',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        dueTime: DateTime.now().add(const Duration(hours: 1)),
      ),
      ActionItem(
        actionId: 'act_004',
        locationId: 'loc_tawang',
        locationName: 'Tawang Pass Corridor',
        actionType: ActionType.monitor,
        title: 'Continuous Radar & Inclinometer Monitoring',
        rationale: 'Scree slope moisture high at 82%.',
        status: ActionStatus.assigned,
        assignedAuthority: 'State Remote Sensing Centre',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        dueTime: DateTime.now().add(const Duration(hours: 6)),
      ),
      ActionItem(
        actionId: 'act_005',
        locationId: 'loc_dima_hasao',
        locationName: 'Haflong Railway Cutting',
        actionType: ActionType.inspect,
        title: 'Inspect Railway Mud Deflector Culverts',
        rationale: 'Clay soil creep along track formation.',
        status: ActionStatus.completed,
        assignedAuthority: 'Northeast Frontier Railway Engineering',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        dueTime: DateTime.now().subtract(const Duration(hours: 1)),
        executionNotes: 'Culverts cleaned and desilted. Drain flow normal.',
      ),
    ];
  }

  @override
  Future<List<RiskLocation>> getRiskLocations() async {
    return List.unmodifiable(_locations);
  }

  @override
  Future<RiskLocation?> getRiskLocationById(String id) async {
    try {
      return _locations.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateDynamicConditions(String locationId, DynamicConditions conditions) async {
    final index = _locations.indexWhere((l) => l.id == locationId);
    if (index != -1) {
      final old = _locations[index];
      final newResult = _riskEngine.calculateRiskSync(
        locationId: locationId,
        susceptibility: old.susceptibility,
        dynamicConditions: conditions,
      );
      _locations[index] = old.copyWith(
        dynamicConditions: conditions,
        calculatedResult: newResult,
      );
    }
  }

  @override
  Future<List<ExposureAsset>> getExposureAssets({String? locationId}) async {
    if (locationId != null) {
      return _assets.where((a) => a.locationId == locationId).toList();
    }
    return List.unmodifiable(_assets);
  }

  @override
  Future<List<PriorityItem>> getPriorityQueue() async {
    final List<PriorityItem> items = [];

    for (final loc in _locations) {
      final res = loc.calculatedResult ??
          _riskEngine.calculateRiskSync(
            locationId: loc.id,
            susceptibility: loc.susceptibility,
            dynamicConditions: loc.dynamicConditions,
          );

      final locAssets = _assets.where((a) => a.locationId == loc.id).toList();
      final double avgExposure = locAssets.isEmpty
          ? 50.0
          : locAssets.map((a) => a.exposureLevel).reduce((a, b) => a + b) / locAssets.length;

      final double avgConnectivity = locAssets.isEmpty
          ? 50.0
          : locAssets.map((a) => a.connectivityImpact).reduce((a, b) => a + b) / locAssets.length;

      final int popAtRisk = locAssets.fold(0, (sum, a) => sum + a.estimatedPopulationAtRisk);

      // Priority Formula: Risk (35%) + Exposure (30%) + Connectivity (20%) + Confidence (15%)
      final double rawPriority = (res.riskScore * 0.35) +
          (avgExposure * 0.30) +
          (avgConnectivity * 0.20) +
          ((res.confidence * 100) * 0.15);

      final double priorityScore = double.parse(rawPriority.clamp(10.0, 99.0).toStringAsFixed(1));

      String threat = 'General Slope Instability';
      if (locAssets.any((a) => a.type == AssetType.hospital && a.exposureLevel > 70)) {
        threat = 'Hospital & Critical Access Threat';
      } else if (locAssets.any((a) => a.type == AssetType.road && a.isBlocked)) {
        threat = 'Arterial Road Blockage & Disconnection';
      } else if (locAssets.any((a) => a.type == AssetType.village && a.exposureLevel > 80)) {
        threat = 'Settlement Inundation / Debris Hazard';
      }

      items.add(PriorityItem(
        locationId: loc.id,
        locationName: loc.name,
        district: loc.district,
        state: loc.state,
        riskScore: res.riskScore,
        riskLevel: res.riskLevel,
        exposureScore: double.parse(avgExposure.toStringAsFixed(1)),
        connectivityScore: double.parse(avgConnectivity.toStringAsFixed(1)),
        confidence: res.confidence,
        priorityScore: priorityScore,
        rank: 1, // Will be sorted and indexed below
        exposedAssetsCount: locAssets.length,
        exposedPopulation: popAtRisk > 0 ? popAtRisk : 2500,
        primaryThreat: threat,
      ));
    }

    // Sort by priorityScore descending
    items.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    // Assign 1-indexed ranks
    final rankedItems = <PriorityItem>[];
    for (int i = 0; i < items.length; i++) {
      rankedItems.add(items[i].copyWith(rank: i + 1));
    }

    return rankedItems;
  }

  @override
  Future<List<ActionItem>> getActions({String? locationId}) async {
    if (locationId != null) {
      return _actions.where((a) => a.locationId == locationId).toList();
    }
    return List.unmodifiable(_actions);
  }

  @override
  Future<void> updateActionStatus(String actionId, ActionStatus status, {String? notes}) async {
    final index = _actions.indexWhere((a) => a.actionId == actionId);
    if (index != -1) {
      _actions[index] = _actions[index].copyWith(
        status: status,
        executionNotes: notes ?? _actions[index].executionNotes,
      );
    }
  }

  @override
  Future<ActionItem> createAction(ActionItem action) async {
    _actions.insert(0, action);
    return action;
  }

  @override
  Future<List<AlertModel>> getAlerts({AlertStatus? status}) async {
    if (status != null) {
      return _alerts.where((a) => a.status == status).toList();
    }
    return List.unmodifiable(_alerts);
  }

  @override
  Future<void> triggerAlert(AlertModel alert) async {
    _alerts.insert(0, alert);
  }

  @override
  Future<void> resolveAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.alertId == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(status: AlertStatus.resolved);
    }
  }

  @override
  Future<List<CitizenReport>> getReports({ReportVerificationStatus? status}) async {
    if (status != null) {
      return _reports.where((r) => r.verificationStatus == status).toList();
    }
    return List.unmodifiable(_reports);
  }

  @override
  Future<CitizenReport> submitReport(CitizenReport report) async {
    _reports.insert(0, report);
    return report;
  }

  @override
  Future<void> verifyReport(String reportId, ReportVerificationStatus status, {String? verifiedBy, String? notes}) async {
    final index = _reports.indexWhere((r) => r.reportId == reportId);
    if (index != -1) {
      final old = _reports[index];
      _reports[index] = old.copyWith(
        verificationStatus: status,
        verifiedBy: verifiedBy ?? 'Field Officer Verified',
        verifiedAt: DateTime.now(),
        verificationNotes: notes ?? old.verificationNotes,
      );

      // FEEDBACK LOOP: If verified, elevate the corresponding location's field report count and recalculate!
      if (status == ReportVerificationStatus.verified || status == ReportVerificationStatus.escalated) {
        // Find matched location
        final locIndex = _locations.indexWhere((l) =>
            old.locationName.toLowerCase().contains(l.name.toLowerCase()) ||
            l.name.toLowerCase().contains(old.locationName.toLowerCase()) ||
            l.id == 'loc_papum_pare');

        if (locIndex != -1) {
          final loc = _locations[locIndex];
          final updatedConditions = loc.dynamicConditions.copyWith(
            verifiedFieldReportsCount: loc.dynamicConditions.verifiedFieldReportsCount + 1,
            slopeDisplacementRate: loc.dynamicConditions.slopeDisplacementRate + 2.5,
          );
          await updateDynamicConditions(loc.id, updatedConditions);
        }
      }
    }
  }

  @override
  Future<List<RiskRoute>> getRiskAwareRoutes(String origin, String destination) async {
    return MockRoutesData.getRoutesForOriginDestination(origin, destination);
  }

  @override
  Future<List<DistrictRiskSummary>> getDistrictSummaries() async {
    return MockAnalyticsData.getDistrictSummaries();
  }

  @override
  Future<List<RegionHistoryEntry>> getRegionHistory(String districtName) async {
    return MockAnalyticsData.getHistoryForDistrict(districtName);
  }
}
