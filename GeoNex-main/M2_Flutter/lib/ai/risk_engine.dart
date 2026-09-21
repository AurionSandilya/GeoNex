import '../core/models/risk_data.dart';

/// Abstract interface for the Risk Engine.
///
/// The UI and pipeline MUST interact ONLY through this abstraction.
/// This allows transparent switching between [MockRiskEngine] (local offline prototype)
/// and [FutureRiskApiEngine] (production trained ML model: Random Forest / XGBoost / Deep Learning).
abstract class RiskEngine {
  /// Computes a [RiskResult] given static susceptibility factors and dynamic conditions.
  Future<RiskResult> calculateRisk({
    required String locationId,
    required SusceptibilityFactors susceptibility,
    required DynamicConditions dynamicConditions,
  });

  /// Recalculates risk when dynamic environmental factors change (e.g. new rainfall or field report).
  RiskResult calculateRiskSync({
    required String locationId,
    required SusceptibilityFactors susceptibility,
    required DynamicConditions dynamicConditions,
  });

  /// Batch calculates risk for a list of locations.
  Future<Map<String, RiskResult>> calculateBatchRisk(List<RiskLocation> locations);
}
