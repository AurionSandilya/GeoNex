import 'package:flutter_test/flutter_test.dart';
import 'package:sih_risk_to_action/ai/mock_risk_engine.dart';
import 'package:sih_risk_to_action/backend/mock_backend_client.dart';
import 'package:sih_risk_to_action/core/constants/app_constants.dart';
import 'package:sih_risk_to_action/core/models/risk_data.dart';
import 'package:sih_risk_to_action/state/app_state.dart';

void main() {
  group('Risk Engine & Pipeline Tests', () {
    const riskEngine = MockRiskEngine();

    test('Risk calculation returns deterministic bounded scores', () {
      const susceptibility = SusceptibilityFactors(
        slopeAngleDegrees: 34.5,
        elevationMeters: 1250,
        lithology: 'Sandstone',
        landCover: 'Steep Escarpment',
        historicalLandslidesCount: 7,
        drainageDensity: 3.8,
      );

      const dynamicConditions = DynamicConditions(
        rainfallMm: 142.0,
        rainfallForecastMm: 165.0,
        soilMoistureIndex: 0.88,
        seismicActivityMag: 3.6,
        verifiedFieldReportsCount: 2,
        slopeDisplacementRate: 8.5,
      );

      final result = riskEngine.calculateRiskSync(
        locationId: 'loc_papum_pare',
        susceptibility: susceptibility,
        dynamicConditions: dynamicConditions,
      );

      expect(result.riskScore, greaterThan(70.0));
      expect(result.riskScore, lessThanOrEqualTo(100.0));
      expect(result.riskLevel, isIn([RiskLevel.high, RiskLevel.critical]));
      expect(result.confidence, greaterThan(0.85));
      expect(result.factorContributions.containsKey('Rainfall (IMD)'), isTrue);
    });

    test('Field Verification triggers dynamic feedback loop recalculation', () async {
      final backend = MockBackendClient(riskEngine: riskEngine);
      final appState = AppState(backendClient: backend, riskEngine: riskEngine);

      await appState.loadAllData();

      final initialLocations = appState.locations;
      expect(initialLocations.isNotEmpty, isTrue);

      // Verify a pending report
      final reports = appState.reports;
      final pendingReport = reports.firstWhere(
        (r) => r.verificationStatus == ReportVerificationStatus.uploaded,
      );

      await appState.verifyFieldReport(
        pendingReport.reportId,
        ReportVerificationStatus.verified,
        notes: 'Confirmed severe tension crack on road cutting.',
      );

      // Verify state reloaded with updated feedback weights
      final updatedReport = appState.reports.firstWhere((r) => r.reportId == pendingReport.reportId);
      expect(updatedReport.verificationStatus, equals(ReportVerificationStatus.verified));
      expect(appState.priorityQueue.first.rank, equals(1));
    });
  });
}
