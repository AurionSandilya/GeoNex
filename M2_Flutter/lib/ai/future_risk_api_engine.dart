import '../core/constants/api_endpoints.dart';
import '../core/models/risk_data.dart';
import 'risk_engine.dart';
import 'mock_risk_engine.dart';

/// Production AI Engine placeholder connecting to the Model Training Workflow
/// (Section 3 & 16: Random Forest / XGBoost / Deep Learning Model served via REST API).
///
/// When the production ML model server is deployed, this implementation handles
/// the HTTP REST communication with `/risk/location` and `/risk/area` endpoints.
class FutureRiskApiEngine implements RiskEngine {
  final String apiEndpoint;
  final String? authToken;
  final MockRiskEngine _fallbackEngine = const MockRiskEngine();

  FutureRiskApiEngine({
    this.apiEndpoint = ApiEndpoints.baseUrl,
    this.authToken,
  });

  @override
  Future<RiskResult> calculateRisk({
    required String locationId,
    required SusceptibilityFactors susceptibility,
    required DynamicConditions dynamicConditions,
  }) async {
    // In production, this executes:
    // final response = await http.post(
    //   Uri.parse('$apiEndpoint${ApiEndpoints.riskLocation}'),
    //   headers: {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'locationId': locationId,
    //     'slope': susceptibility.slopeAngleDegrees,
    //     'elevation': susceptibility.elevationMeters,
    //     'rainfall_24h': dynamicConditions.rainfallMm,
    //     'soil_moisture': dynamicConditions.soilMoistureIndex,
    //     'seismic_mag': dynamicConditions.seismicActivityMag,
    //     'verified_reports': dynamicConditions.verifiedFieldReportsCount,
    //   }),
    // );
    // return RiskResult.fromJson(jsonDecode(response.body));

    // Offline / demo fallback:
    return _fallbackEngine.calculateRiskSync(
      locationId: locationId,
      susceptibility: susceptibility,
      dynamicConditions: dynamicConditions,
    );
  }

  @override
  RiskResult calculateRiskSync({
    required String locationId,
    required SusceptibilityFactors susceptibility,
    required DynamicConditions dynamicConditions,
  }) {
    return _fallbackEngine.calculateRiskSync(
      locationId: locationId,
      susceptibility: susceptibility,
      dynamicConditions: dynamicConditions,
    );
  }

  @override
  Future<Map<String, RiskResult>> calculateBatchRisk(List<RiskLocation> locations) async {
    return _fallbackEngine.calculateBatchRisk(locations);
  }
}
