import '../constants/app_constants.dart';

class PriorityItem {
  final String locationId;
  final String locationName;
  final String district;
  final String state;
  final double riskScore; // 0 to 100
  final RiskLevel riskLevel;
  final double exposureScore; // 0 to 100
  final double connectivityScore; // 0 to 100
  final double confidence; // 0.0 to 1.0 (e.g. 0.93)
  final double priorityScore; // 0 to 100
  final int rank; // 1, 2, 3...
  final int exposedAssetsCount;
  final int exposedPopulation;
  final String primaryThreat; // e.g. "Road Disruption to Hospital"

  const PriorityItem({
    required this.locationId,
    required this.locationName,
    required this.district,
    required this.state,
    required this.riskScore,
    required this.riskLevel,
    required this.exposureScore,
    required this.connectivityScore,
    required this.confidence,
    required this.priorityScore,
    required this.rank,
    required this.exposedAssetsCount,
    required this.exposedPopulation,
    required this.primaryThreat,
  });

  PriorityItem copyWith({
    String? locationId,
    String? locationName,
    String? district,
    String? state,
    double? riskScore,
    RiskLevel? riskLevel,
    double? exposureScore,
    double? connectivityScore,
    double? confidence,
    double? priorityScore,
    int? rank,
    int? exposedAssetsCount,
    int? exposedPopulation,
    String? primaryThreat,
  }) {
    return PriorityItem(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      district: district ?? this.district,
      state: state ?? this.state,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
      exposureScore: exposureScore ?? this.exposureScore,
      connectivityScore: connectivityScore ?? this.connectivityScore,
      confidence: confidence ?? this.confidence,
      priorityScore: priorityScore ?? this.priorityScore,
      rank: rank ?? this.rank,
      exposedAssetsCount: exposedAssetsCount ?? this.exposedAssetsCount,
      exposedPopulation: exposedPopulation ?? this.exposedPopulation,
      primaryThreat: primaryThreat ?? this.primaryThreat,
    );
  }
}
