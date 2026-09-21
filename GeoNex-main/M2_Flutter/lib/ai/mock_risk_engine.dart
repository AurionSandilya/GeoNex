import 'dart:math';
import '../core/constants/app_constants.dart';
import '../core/models/risk_data.dart';
import 'risk_engine.dart';

/// Prototype implementation of the Risk Engine.
///
/// Implements deterministic geospatial-physical formulas combining:
/// 1. Susceptibility Index (Slope, Historical Landslides, Drainage, Lithology, DEM)
/// 2. Dynamic Trigger Index (24h Rainfall, Soil Moisture SMAP/SMOS, Seismic Mag, Field Reports Feedback)
class MockRiskEngine implements RiskEngine {
  const MockRiskEngine();

  @override
  Future<RiskResult> calculateRisk({
    required String locationId,
    required SusceptibilityFactors susceptibility,
    required DynamicConditions dynamicConditions,
  }) async {
    // Simulate negligible asynchronous calculation latency
    return calculateRiskSync(
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
    // 1. Compute Static Susceptibility Score (0.0 to 100.0)
    // Normalized slope factor (0 to 60 degrees -> normalized)
    final double slopeFactor = (susceptibility.slopeAngleDegrees / 50.0).clamp(0.0, 1.0) * 35.0;

    // Historical landslide weight
    final double historyFactor = (susceptibility.historicalLandslidesCount * 5.0).clamp(0.0, 30.0);

    // Drainage and elevation
    final double drainageFactor = (susceptibility.drainageDensity * 4.0).clamp(0.0, 20.0);
    final double elevationFactor = (susceptibility.elevationMeters / 3000.0).clamp(0.0, 1.0) * 15.0;

    final double susceptibilityIndex = (slopeFactor + historyFactor + drainageFactor + elevationFactor).clamp(0.0, 100.0);

    // 2. Compute Dynamic Trigger Index (0.0 to 100.0)
    // Rainfall trigger (e.g. >100mm is severe in NE India Himalayan terrain)
    final double rainfallFactor = (dynamicConditions.rainfallMm / 150.0).clamp(0.0, 1.0) * 40.0;

    // Soil moisture saturation (SMAP index: 0.0 to 1.0)
    final double soilMoistureFactor = (dynamicConditions.soilMoistureIndex * 30.0).clamp(0.0, 30.0);

    // Seismic trigger (e.g. Mag 4.0 - 7.0)
    final double seismicFactor = (max(0.0, dynamicConditions.seismicActivityMag - 2.0) * 4.0).clamp(0.0, 15.0);

    // Feedback Loop from Verified Citizen/Field Reports
    // Each verified field report adds tangible dynamic weight!
    final double fieldReportsFactor = (dynamicConditions.verifiedFieldReportsCount * 7.5).clamp(0.0, 15.0);

    final double dynamicTriggerIndex = (rainfallFactor + soilMoistureFactor + seismicFactor + fieldReportsFactor).clamp(0.0, 100.0);

    // 3. Composite Risk Score Formula
    // Risk = (Susceptibility * 0.45) + (Dynamic Trigger * 0.55)
    final double rawScore = (susceptibilityIndex * 0.45) + (dynamicTriggerIndex * 0.55);
    final double finalRiskScore = double.parse(rawScore.clamp(5.0, 99.0).toStringAsFixed(1));

    // 4. Determine Risk Level
    final RiskLevel level;
    if (finalRiskScore >= 80.0) {
      level = RiskLevel.critical;
    } else if (finalRiskScore >= 65.0) {
      level = RiskLevel.high;
    } else if (finalRiskScore >= 40.0) {
      level = RiskLevel.moderate;
    } else {
      level = RiskLevel.low;
    }

    // 5. Confidence Score (Based on sensor availability & field reports)
    final double confidence = (0.82 + (dynamicConditions.verifiedFieldReportsCount > 0 ? 0.11 : 0.05) + (dynamicConditions.rainfallMm > 0 ? 0.04 : 0.0)).clamp(0.70, 0.98);

    // 6. Factor contributions map for UI breakdown
    final double totalFactorSum = rainfallFactor + soilMoistureFactor + slopeFactor + historyFactor + seismicFactor + fieldReportsFactor;
    final Map<String, double> contributions = {
      'Rainfall (IMD)': double.parse(((rainfallFactor / (totalFactorSum > 0 ? totalFactorSum : 1)) * 100).toStringAsFixed(1)),
      'Soil Moisture (SMAP)': double.parse(((soilMoistureFactor / (totalFactorSum > 0 ? totalFactorSum : 1)) * 100).toStringAsFixed(1)),
      'Slope & Topography': double.parse(((slopeFactor / (totalFactorSum > 0 ? totalFactorSum : 1)) * 100).toStringAsFixed(1)),
      'Historical Landslides': double.parse(((historyFactor / (totalFactorSum > 0 ? totalFactorSum : 1)) * 100).toStringAsFixed(1)),
      'Seismic Activity': double.parse(((seismicFactor / (totalFactorSum > 0 ? totalFactorSum : 1)) * 100).toStringAsFixed(1)),
      'Field Reports (App)': double.parse(((fieldReportsFactor / (totalFactorSum > 0 ? totalFactorSum : 1)) * 100).toStringAsFixed(1)),
    };

    return RiskResult(
      locationId: locationId,
      riskScore: finalRiskScore,
      riskLevel: level,
      confidence: double.parse(confidence.toStringAsFixed(2)),
      susceptibilityIndex: double.parse(susceptibilityIndex.toStringAsFixed(1)),
      dynamicTriggerIndex: double.parse(dynamicTriggerIndex.toStringAsFixed(1)),
      factorContributions: contributions,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<Map<String, RiskResult>> calculateBatchRisk(List<RiskLocation> locations) async {
    final Map<String, RiskResult> results = {};
    for (final loc in locations) {
      results[loc.id] = calculateRiskSync(
        locationId: loc.id,
        susceptibility: loc.susceptibility,
        dynamicConditions: loc.dynamicConditions,
      );
    }
    return results;
  }
}
