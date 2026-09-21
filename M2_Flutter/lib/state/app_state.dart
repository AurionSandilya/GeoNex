import 'package:flutter/foundation.dart';
import '../ai/mock_risk_engine.dart';
import '../ai/risk_engine.dart';
import '../backend/backend_client.dart';
import '../backend/mock_backend_client.dart';
import '../core/constants/app_constants.dart';
import '../core/models/action_item.dart';
import '../core/models/alert_model.dart';
import '../core/models/citizen_report.dart';
import '../core/models/exposure_asset.dart';
import '../core/models/priority_item.dart';
import '../core/models/region_summary.dart';
import '../core/models/risk_data.dart';
import '../core/models/user_profile.dart';
import '../data/repositories/risk_repository.dart';
import '../data/services/offline_sync_service.dart';

class AppState extends ChangeNotifier {
  final RiskEngine _riskEngine;
  final BackendClient _backendClient;
  late final RiskRepository _repository;
  late final OfflineSyncService _offlineService;

  // Current User / Role
  UserProfile _currentUser = const UserProfile(
    id: 'usr_001',
    name: 'Er. Talo Koyu',
    emailOrPhone: 'official@arunachal.gov.in',
    role: UserRole.authority,
    designation: 'Director, State Disaster Management Authority',
    assignedRegion: 'Papum Pare District',
    badgeNumber: 'SDMA-NER-889',
  );

  // Active Selected Location for Deep Dive
  String _selectedLocationId = 'loc_papum_pare';

  // State caches
  List<RiskLocation> _locations = [];
  List<ExposureAsset> _assets = [];
  List<PriorityItem> _priorityQueue = [];
  List<ActionItem> _actions = [];
  List<AlertModel> _alerts = [];
  List<CitizenReport> _reports = [];
  List<DistrictRiskSummary> _districtSummaries = [];
  List<RegionHistoryEntry> _regionHistory = [];

  // Map Filter Layer Toggles
  bool _layerRiskZones = true;
  bool _layerRoads = true;
  bool _layerRainfall = true;
  bool _layerSoilMoisture = true;
  bool _layerHistoricalLandslides = true;
  bool _layerInfrastructure = true;
  bool _layerCitizenReports = true;

  // Loading & Error States
  bool _isLoading = true;
  String? _errorMessage;

  AppState({
    RiskEngine? riskEngine,
    BackendClient? backendClient,
  })  : _riskEngine = riskEngine ?? const MockRiskEngine(),
        _backendClient = backendClient ?? MockBackendClient() {
    _repository = RiskRepository(_backendClient);
    _offlineService = OfflineSyncService(_repository);
    loadAllData();
  }

  // Getters
  UserProfile get currentUser => _currentUser;
  UserRole get currentRole => _currentUser.role;
  String get selectedLocationId => _selectedLocationId;
  RiskEngine get riskEngine => _riskEngine;
  BackendClient get backendClient => _backendClient;

  List<RiskLocation> get locations => _locations;
  List<ExposureAsset> get assets => _assets;
  List<PriorityItem> get priorityQueue => _priorityQueue;
  List<ActionItem> get actions => _actions;
  List<AlertModel> get alerts => _alerts;
  List<CitizenReport> get reports => _reports;
  List<DistrictRiskSummary> get districtSummaries => _districtSummaries;
  List<RegionHistoryEntry> get regionHistory => _regionHistory;

  RiskRepository get repository => _repository;
  OfflineSyncService get offlineService => _offlineService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Layer toggles
  bool get layerRiskZones => _layerRiskZones;
  bool get layerRoads => _layerRoads;
  bool get layerRainfall => _layerRainfall;
  bool get layerSoilMoisture => _layerSoilMoisture;
  bool get layerHistoricalLandslides => _layerHistoricalLandslides;
  bool get layerInfrastructure => _layerInfrastructure;
  bool get layerCitizenReports => _layerCitizenReports;

  RiskLocation? get selectedLocation {
    try {
      return _locations.firstWhere((l) => l.id == _selectedLocationId);
    } catch (_) {
      return _locations.isNotEmpty ? _locations.first : null;
    }
  }

  List<ExposureAsset> get selectedLocationAssets {
    return _assets.where((a) => a.locationId == _selectedLocationId).toList();
  }

  List<ActionItem> get selectedLocationActions {
    return _actions.where((a) => a.locationId == _selectedLocationId).toList();
  }

  // Setters & Actions
  void switchUserRole(UserRole newRole) {
    if (newRole == UserRole.authority) {
      _currentUser = const UserProfile(
        id: 'usr_001',
        name: 'Er. Talo Koyu',
        emailOrPhone: 'official@arunachal.gov.in',
        role: UserRole.authority,
        designation: 'Director, State Disaster Management Authority',
        assignedRegion: 'Papum Pare District',
        badgeNumber: 'SDMA-NER-889',
      );
    } else if (newRole == UserRole.fieldOfficer) {
      _currentUser = const UserProfile(
        id: 'usr_002',
        name: 'Inspector Tayeng',
        emailOrPhone: 'tayeng.field@disaster.in',
        role: UserRole.fieldOfficer,
        designation: 'Field Inspection Lead, Rapid Response Unit',
        assignedRegion: 'Papum Pare & Subansiri Corridors',
        badgeNumber: 'FO-AR-402',
      );
    } else {
      _currentUser = const UserProfile(
        id: 'usr_003',
        name: 'Taba Nabam',
        emailOrPhone: 'citizen.reporter@gmail.com',
        role: UserRole.citizen,
        designation: 'Verified Community Reporter & Volunteer',
        assignedRegion: 'Doimukh Ward, Papum Pare',
        badgeNumber: 'CITIZEN-NER-109',
      );
    }
    notifyListeners();
  }

  void selectLocation(String locationId) {
    _selectedLocationId = locationId;
    loadHistoryForSelected();
    notifyListeners();
  }

  void toggleLayer(String layerKey) {
    switch (layerKey) {
      case 'riskZones':
        _layerRiskZones = !_layerRiskZones;
        break;
      case 'roads':
        _layerRoads = !_layerRoads;
        break;
      case 'rainfall':
        _layerRainfall = !_layerRainfall;
        break;
      case 'soilMoisture':
        _layerSoilMoisture = !_layerSoilMoisture;
        break;
      case 'historicalLandslides':
        _layerHistoricalLandslides = !_layerHistoricalLandslides;
        break;
      case 'infrastructure':
        _layerInfrastructure = !_layerInfrastructure;
        break;
      case 'citizenReports':
        _layerCitizenReports = !_layerCitizenReports;
        break;
    }
    notifyListeners();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _locations = await _repository.getLocations();
      _assets = await _repository.getAssets();
      _priorityQueue = await _repository.getPriorityQueue();
      _actions = await _repository.getActions();
      _alerts = await _repository.getAlerts();
      _reports = await _repository.getReports();
      _districtSummaries = await _repository.getDistrictSummaries();
      if (_locations.isNotEmpty) {
        _regionHistory = await _repository.getDistrictHistory(selectedLocation?.district ?? 'Papum Pare');
      }
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadHistoryForSelected() async {
    if (selectedLocation != null) {
      _regionHistory = await _repository.getDistrictHistory(selectedLocation!.district);
      notifyListeners();
    }
  }

  // Action Lifecycle Trigger
  Future<void> updateActionStatus(String actionId, ActionStatus newStatus, {String? notes}) async {
    await _repository.updateActionStatus(actionId, newStatus, notes: notes);
    _actions = await _repository.getActions();
    notifyListeners();
  }

  // Citizen Report Submission & Offline Sync
  Future<void> submitCitizenReport(CitizenReport report) async {
    if (_offlineService.isOnline) {
      await _repository.submitReport(report);
      _reports = await _repository.getReports();
    } else {
      await _offlineService.enqueueReport(report);
    }
    notifyListeners();
  }

  // Field Verification & FEEDBACK LOOP RECALCULATION
  Future<void> verifyFieldReport(String reportId, ReportVerificationStatus status, {String? notes}) async {
    await _repository.verifyReport(
      reportId,
      status,
      verifiedBy: _currentUser.name,
      notes: notes,
    );

    // Refresh entire pipeline to reflect AI recalculations
    _reports = await _repository.getReports();
    _locations = await _repository.getLocations();
    _priorityQueue = await _repository.getPriorityQueue();
    _alerts = await _repository.getAlerts();
    _districtSummaries = await _repository.getDistrictSummaries();

    // Trigger proactive alert if verified critical
    if (status == ReportVerificationStatus.verified || status == ReportVerificationStatus.escalated) {
      final verifiedReport = _reports.firstWhere((r) => r.reportId == reportId);
      final newAlert = AlertModel(
        alertId: 'alt_${DateTime.now().millisecondsSinceEpoch}',
        locationId: _selectedLocationId,
        locationName: verifiedReport.locationName,
        region: 'Papum Pare, Arunachal Pradesh',
        severity: verifiedReport.severity,
        title: 'VERIFIED ${verifiedReport.incidentType.displayName.toUpperCase()} CONFIRMED',
        message: 'Field Officer ${_currentUser.name} verified report #${verifiedReport.reportId}: ${verifiedReport.notes}',
        cause: 'Field Ground Truth Verification',
        recommendedAction: 'Dispatch Road Clearance Team & Update Hazard Zoning',
        createdAt: DateTime.now(),
        status: AlertStatus.active,
        deliveryChannels: const [
          DeliveryChannel.push,
          DeliveryChannel.sms,
          DeliveryChannel.broadcastSiren,
          DeliveryChannel.capIntegration,
        ],
        previousRiskScore: 78,
        currentRiskScore: 92,
      );
      await _repository.createAlert(newAlert);
      _alerts = await _repository.getAlerts();
    }

    notifyListeners();
  }

  // Dynamic Factors Simulation (e.g. slider for Rainfall / Soil Moisture to demo AI response)
  Future<void> simulateDynamicChange({
    required String locationId,
    required double rainfallMm,
    required double soilMoistureIndex,
  }) async {
    final loc = _locations.firstWhere((l) => l.id == locationId);
    final updatedConditions = loc.dynamicConditions.copyWith(
      rainfallMm: rainfallMm,
      soilMoistureIndex: soilMoistureIndex,
    );
    await _repository.updateDynamicFactors(locationId, updatedConditions);

    _locations = await _repository.getLocations();
    _priorityQueue = await _repository.getPriorityQueue();
    _districtSummaries = await _repository.getDistrictSummaries();
    notifyListeners();
  }
}
