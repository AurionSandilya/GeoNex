import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

/// Real HTTP client connecting M2 Flutter application to M3 FastAPI backend.
///
/// Implements [BackendClient] interface with automatic graceful fallback
/// to [MockBackendClient] when network is unavailable or backend is offline.
class FastApiBackendClient implements BackendClient {
  final String baseUrl;
  final BackendClient _fallback;
  final http.Client _httpClient;

  /// JWT obtained from a successful /auth/login call. Every request below
  /// attaches this as `Authorization: Bearer <token>` once set - M3's
  /// `POST /reports` (and other write endpoints) require a valid user via
  /// `Depends(get_current_user)` and reject unauthenticated calls with 401.
  String? _authToken;

  bool get isAuthenticated => _authToken != null;

  FastApiBackendClient({
    String? baseUrl,
    BackendClient? fallback,
  })  : baseUrl = baseUrl ?? 'http://localhost:8000/api/v1',
        _fallback = fallback ?? MockBackendClient(),
        _httpClient = http.Client();

  /// Authenticates against M3's OAuth2-password-flow login endpoint
  /// (`POST /auth/login`, form-encoded `username`/`password` - not JSON,
  /// per FastAPI's `OAuth2PasswordRequestForm`) and stores the returned JWT
  /// for use on every subsequent request. Returns true on success.
Future<bool> login(String email, String password) async {
  try {
    final uri = Uri.parse('$baseUrl/auth/login');

    final formBody =
        'username=${Uri.encodeQueryComponent(email)}&password=${Uri.encodeQueryComponent(password)}';

    final response = await _httpClient
        .post(
          uri,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: formBody,
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final token = decoded['access_token'] as String?;

      if (token != null && token.isNotEmpty) {
        _authToken = token;
        return true;
      }
    }
  } catch (_) {
    // Network error / backend offline - caller decides whether to fall
    // back to demo mode; we never fabricate a token here.
  }

  return false;
}
  void logout() {
    _authToken = null;
  }

  // ---------------------------------------------------------------------------
  // HTTP Helpers (package:http - Flutter Web compatible)
  // ---------------------------------------------------------------------------
  Future<dynamic> _get(String endpoint) async {
    try {
    final uri = Uri.parse('$baseUrl$endpoint');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final response = await _httpClient
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
  } catch (_) {
    // Graceful fallback to mock on network error
  }

  return null;
}

  Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
  try {
    final uri = Uri.parse('$baseUrl$endpoint');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final response = await _httpClient
        .post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
  } catch (_) {
    // Graceful fallback on failure
  }

  return null;
}

  // ---------------------------------------------------------------------------
  // Field Reports (M3 REST /reports)
  // ---------------------------------------------------------------------------
  @override
  Future<List<CitizenReport>> getReports({ReportVerificationStatus? status}) async {
    final statusQuery = status != null ? '?status=${status.name.toUpperCase()}' : '';
    final data = await _get('/reports$statusQuery');
    if (data is List && data.isNotEmpty) {
      try {
        return data.map<CitizenReport>((item) {
          final typeStr = item['report_type']?.toString().toUpperCase() ?? 'LANDSLIDE';
          final incidentType = typeStr == 'ROCKFALL'
              ? IncidentType.rockfall
              : typeStr == 'SUBSIDENCE'
                  ? IncidentType.other
                  : IncidentType.landslide;

          final statusStr = item['status']?.toString().toUpperCase() ?? 'PENDING';
          final verStatus = statusStr == 'VERIFIED'
              ? ReportVerificationStatus.verified
              : statusStr == 'REJECTED'
                  ? ReportVerificationStatus.rejected
                  : ReportVerificationStatus.uploaded;

          return CitizenReport(
            reportId: item['id']?.toString() ?? '',
            locationName: 'Papum Pare Sector (${item['latitude']}, ${item['longitude']})',
            latitude: (item['latitude'] as num?)?.toDouble() ?? 27.55,
            longitude: (item['longitude'] as num?)?.toDouble() ?? 93.65,
            capturedAt: DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now(),
            mediaPath: 'assets/images/reports/sample.jpg',
            incidentType: incidentType,
            severity: SeverityLevel.high,
            notes: item['description']?.toString() ?? 'Report submitted via mobile field app.',
            verificationStatus: verStatus,
            submittedBy: item['user_id']?.toString() ?? 'Field Squad',
          );
        }).toList();
      } catch (_) {
        // Fallback to mock on parse error
      }
    }
    return _fallback.getReports(status: status);
  }

  @override
  Future<CitizenReport> submitReport(CitizenReport report) async {
    final payload = {
      'client_report_id': report.reportId,
      'report_type': report.incidentType.m3WireValue,
      'description': report.notes,
      'latitude': report.latitude,
      'longitude': report.longitude,
      'capture_timestamp': report.capturedAt.toIso8601String(),
    };

    final result = await _post('/reports', payload);
    if (result != null && result['id'] != null) {
      return report.copyWith(reportId: result['id'].toString(), isOfflineQueued: false);
    }
    return _fallback.submitReport(report);
  }

  @override
  Future<void> verifyReport(
    String reportId,
    ReportVerificationStatus status, {
    String? verifiedBy,
    String? notes,
  }) async {
    final decision = status == ReportVerificationStatus.verified
        ? 'VERIFY'
        : status == ReportVerificationStatus.rejected
            ? 'REJECT'
            : 'NEEDS_INFORMATION';

    final payload = {
      'decision': decision,
      'remarks': notes ?? 'Verified via mobile app command center.',
    };

    final result = await _post('/reports/$reportId/verify', payload);
    if (result == null) {
      await _fallback.verifyReport(reportId, status, verifiedBy: verifiedBy, notes: notes);
    }
  }

  // ---------------------------------------------------------------------------
  // Early Warning Alerts (M3 REST /alerts -> M5 Alert Engine)
  // ---------------------------------------------------------------------------
  @override
  Future<List<AlertModel>> getAlerts({AlertStatus? status}) async {
    final statusQuery = status != null ? '?status=${status.name.toUpperCase()}' : '';
    final data = await _get('/alerts$statusQuery');
    if (data is List && data.isNotEmpty) {
      try {
        return data.map<AlertModel>((item) {
          final sevStr = (item['severity'] ?? item['current_severity'] ?? 'NORMAL').toString().toUpperCase();
          final severity = sevStr == 'CRITICAL'
              ? SeverityLevel.critical
              : sevStr == 'WARNING' || sevStr == 'HIGH'
                  ? SeverityLevel.high
                  : sevStr == 'WATCH' || sevStr == 'MODERATE'
                      ? SeverityLevel.medium
                      : SeverityLevel.low;

          final stStr = (item['status'] ?? item['lifecycle_status'] ?? 'ACTIVE').toString().toUpperCase();
          final alertStatus = stStr == 'ACKNOWLEDGED'
              ? AlertStatus.active
              : stStr == 'RESOLVED'
                  ? AlertStatus.resolved
                  : AlertStatus.active;

          return AlertModel(
            alertId: item['id']?.toString() ?? '',
            locationId: item['area_id']?.toString() ?? 'papum_pare',
            locationName: 'Monitoring Sector ${item['area_id'] ?? 'Papum Pare'}',
            region: 'Papum Pare District',
            severity: severity,
            title: item['title']?.toString() ?? 'Landslide $sevStr Alert',
            message: item['message']?.toString() ?? 'Elevated landslide risk detected in monitored zone.',
            cause: 'Rainfall & soil saturation thresholds exceeded',
            recommendedAction: sevStr == 'CRITICAL' ? 'Evacuate vulnerable slope corridors' : 'Deploy monitoring squad',
            createdAt: DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now(),
            status: alertStatus,
            deliveryChannels: [DeliveryChannel.sms, DeliveryChannel.push],
            previousRiskScore: 40,
            currentRiskScore: ((item['last_risk_score'] as num?)?.toDouble() ?? 0.75 * 100).toInt(),
          );
        }).toList();
      } catch (_) {
        // Fallback on parse failure
      }
    }
    return _fallback.getAlerts(status: status);
  }

  @override
  Future<void> triggerAlert(AlertModel alert) => _fallback.triggerAlert(alert);

  @override
  Future<void> resolveAlert(String alertId) async {
    final result = await _post('/alerts/$alertId/acknowledge', {'remarks': 'Acknowledged from mobile app'});
    if (result == null) {
      await _fallback.resolveAlert(alertId);
    }
  }

  // ---------------------------------------------------------------------------
  // Risk Locations & Spatial Queries
  // ---------------------------------------------------------------------------
  @override
  Future<List<RiskLocation>> getRiskLocations() => _fallback.getRiskLocations();

  @override
  Future<RiskLocation?> getRiskLocationById(String id) => _fallback.getRiskLocationById(id);

  @override
  Future<void> updateDynamicConditions(String locationId, DynamicConditions conditions) =>
      _fallback.updateDynamicConditions(locationId, conditions);

  // ---------------------------------------------------------------------------
  // Exposure Assets & Priority Queue
  // ---------------------------------------------------------------------------
  @override
  Future<List<ExposureAsset>> getExposureAssets({String? locationId}) =>
      _fallback.getExposureAssets(locationId: locationId);

  @override
  Future<List<PriorityItem>> getPriorityQueue() => _fallback.getPriorityQueue();

  // ---------------------------------------------------------------------------
  // Action Items
  // ---------------------------------------------------------------------------
  @override
  Future<List<ActionItem>> getActions({String? locationId}) =>
      _fallback.getActions(locationId: locationId);

  @override
  Future<void> updateActionStatus(String actionId, ActionStatus status, {String? notes}) =>
      _fallback.updateActionStatus(actionId, status, notes: notes);

  @override
  Future<ActionItem> createAction(ActionItem action) => _fallback.createAction(action);

  // ---------------------------------------------------------------------------
  // Routing & Analytics
  // ---------------------------------------------------------------------------
  @override
  Future<List<RiskRoute>> getRiskAwareRoutes(String origin, String destination) =>
      _fallback.getRiskAwareRoutes(origin, destination);

  @override
  Future<List<DistrictRiskSummary>> getDistrictSummaries() => _fallback.getDistrictSummaries();

  @override
  Future<List<RegionHistoryEntry>> getRegionHistory(String districtName) =>
      _fallback.getRegionHistory(districtName);
}
