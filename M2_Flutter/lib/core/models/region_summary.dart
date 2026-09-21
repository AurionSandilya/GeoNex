import '../constants/app_constants.dart';

class RegionHistoryEntry {
  final DateTime date;
  final double riskScore;
  final RiskLevel riskLevel;
  final double rainfallMm;
  final int incidentCount;
  final String notes;

  const RegionHistoryEntry({
    required this.date,
    required this.riskScore,
    required this.riskLevel,
    required this.rainfallMm,
    required this.incidentCount,
    required this.notes,
  });
}

class DistrictRiskSummary {
  final String districtName;
  final String stateName;
  final double riskScore;
  final RiskLevel riskLevel;
  final int highRiskZonesCount;
  final int activeAlertsCount;
  final int exposedPopulation;
  final int blockedRoadsCount;
  final double avgRainfallMm;
  final double avgSoilMoisture;

  const DistrictRiskSummary({
    required this.districtName,
    required this.stateName,
    required this.riskScore,
    required this.riskLevel,
    required this.highRiskZonesCount,
    required this.activeAlertsCount,
    required this.exposedPopulation,
    required this.blockedRoadsCount,
    required this.avgRainfallMm,
    required this.avgSoilMoisture,
  });
}
