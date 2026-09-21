import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class DynamicConditions {
  final double rainfallMm; // 24h Rainfall in mm
  final double rainfallForecastMm; // 48h Forecast
  final double soilMoistureIndex; // 0.0 - 1.0 (SMAP/SMOS)
  final double seismicActivityMag; // Richter magnitude (USGS/ISC)
  final int verifiedFieldReportsCount; // Recent verified incidents
  final double slopeDisplacementRate; // mm/day

  const DynamicConditions({
    required this.rainfallMm,
    required this.rainfallForecastMm,
    required this.soilMoistureIndex,
    required this.seismicActivityMag,
    required this.verifiedFieldReportsCount,
    required this.slopeDisplacementRate,
  });

  DynamicConditions copyWith({
    double? rainfallMm,
    double? rainfallForecastMm,
    double? soilMoistureIndex,
    double? seismicActivityMag,
    int? verifiedFieldReportsCount,
    double? slopeDisplacementRate,
  }) {
    return DynamicConditions(
      rainfallMm: rainfallMm ?? this.rainfallMm,
      rainfallForecastMm: rainfallForecastMm ?? this.rainfallForecastMm,
      soilMoistureIndex: soilMoistureIndex ?? this.soilMoistureIndex,
      seismicActivityMag: seismicActivityMag ?? this.seismicActivityMag,
      verifiedFieldReportsCount: verifiedFieldReportsCount ?? this.verifiedFieldReportsCount,
      slopeDisplacementRate: slopeDisplacementRate ?? this.slopeDisplacementRate,
    );
  }
}

class SusceptibilityFactors {
  final double slopeAngleDegrees; // e.g. 34.5 degrees
  final double elevationMeters; // DEM
  final String lithology; // Soil / Rock type
  final String landCover; // Forest, Deforested, Plantation, Urban
  final int historicalLandslidesCount; // GSI records
  final double drainageDensity; // km/km2

  const SusceptibilityFactors({
    required this.slopeAngleDegrees,
    required this.elevationMeters,
    required this.lithology,
    required this.landCover,
    required this.historicalLandslidesCount,
    required this.drainageDensity,
  });
}

class RiskLocation {
  final String id;
  final String name;
  final String district;
  final String state;
  final double latitude;
  final double longitude;
  final SusceptibilityFactors susceptibility;
  final DynamicConditions dynamicConditions;
  final RiskResult? calculatedResult;

  const RiskLocation({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.susceptibility,
    required this.dynamicConditions,
    this.calculatedResult,
  });

  RiskLocation copyWith({
    String? id,
    String? name,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    SusceptibilityFactors? susceptibility,
    DynamicConditions? dynamicConditions,
    RiskResult? calculatedResult,
  }) {
    return RiskLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      district: district ?? this.district,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      susceptibility: susceptibility ?? this.susceptibility,
      dynamicConditions: dynamicConditions ?? this.dynamicConditions,
      calculatedResult: calculatedResult ?? this.calculatedResult,
    );
  }
}

class RiskResult {
  final String locationId;
  final double riskScore; // 0 to 100
  final RiskLevel riskLevel; // Low, Moderate, High, Critical
  final double confidence; // 0.0 to 1.0 (e.g. 93%)
  final double susceptibilityIndex; // 0 to 100
  final double dynamicTriggerIndex; // 0 to 100
  final Map<String, double> factorContributions; // Rainfall: 40%, Soil: 25%, Slope: 20%, etc.
  final DateTime timestamp;

  const RiskResult({
    required this.locationId,
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
    required this.susceptibilityIndex,
    required this.dynamicTriggerIndex,
    required this.factorContributions,
    required this.timestamp,
  });

  Color get color {
    switch (riskLevel) {
      case RiskLevel.low:
        return AppColors.riskLow;
      case RiskLevel.moderate:
        return AppColors.riskModerate;
      case RiskLevel.high:
        return AppColors.riskHigh;
      case RiskLevel.critical:
        return AppColors.riskCritical;
    }
  }

  String get label => riskLevel.displayName;
}
