import '../../core/constants/app_constants.dart';
import '../../core/models/region_summary.dart';

class MockAnalyticsData {
  static List<DistrictRiskSummary> getDistrictSummaries() {
    return const [
      DistrictRiskSummary(
        districtName: 'Papum Pare',
        stateName: 'Arunachal Pradesh',
        riskScore: 86.0,
        riskLevel: RiskLevel.high,
        highRiskZonesCount: 4,
        activeAlertsCount: 3,
        exposedPopulation: 42500,
        blockedRoadsCount: 2,
        avgRainfallMm: 142.0,
        avgSoilMoisture: 0.88,
      ),
      DistrictRiskSummary(
        districtName: 'Tawang',
        stateName: 'Arunachal Pradesh',
        riskScore: 82.0,
        riskLevel: RiskLevel.high,
        highRiskZonesCount: 3,
        activeAlertsCount: 2,
        exposedPopulation: 18200,
        blockedRoadsCount: 1,
        avgRainfallMm: 118.0,
        avgSoilMoisture: 0.82,
      ),
      DistrictRiskSummary(
        districtName: 'Dima Hasao',
        stateName: 'Assam',
        riskScore: 76.0,
        riskLevel: RiskLevel.high,
        highRiskZonesCount: 2,
        activeAlertsCount: 1,
        exposedPopulation: 31000,
        blockedRoadsCount: 1,
        avgRainfallMm: 98.0,
        avgSoilMoisture: 0.79,
      ),
      DistrictRiskSummary(
        districtName: 'East Khasi Hills',
        stateName: 'Meghalaya',
        riskScore: 78.0,
        riskLevel: RiskLevel.high,
        highRiskZonesCount: 3,
        activeAlertsCount: 2,
        exposedPopulation: 54000,
        blockedRoadsCount: 0,
        avgRainfallMm: 168.0,
        avgSoilMoisture: 0.85,
      ),
      DistrictRiskSummary(
        districtName: 'West Sikkim',
        stateName: 'Sikkim',
        riskScore: 48.0,
        riskLevel: RiskLevel.moderate,
        highRiskZonesCount: 1,
        activeAlertsCount: 0,
        exposedPopulation: 14500,
        blockedRoadsCount: 0,
        avgRainfallMm: 62.0,
        avgSoilMoisture: 0.58,
      ),
      DistrictRiskSummary(
        districtName: 'Kohima',
        stateName: 'Nagaland',
        riskScore: 35.0,
        riskLevel: RiskLevel.low,
        highRiskZonesCount: 0,
        activeAlertsCount: 0,
        exposedPopulation: 22000,
        blockedRoadsCount: 0,
        avgRainfallMm: 45.0,
        avgSoilMoisture: 0.44,
      ),
    ];
  }

  static List<RegionHistoryEntry> getHistoryForDistrict(String district) {
    return [
      RegionHistoryEntry(
        date: DateTime(2026, 9, 10),
        riskScore: 86.0,
        riskLevel: RiskLevel.high,
        rainfallMm: 142.0,
        incidentCount: 4,
        notes: 'Monsoon peak triggered multiple cut-slope tension cracks along NH-415.',
      ),
      RegionHistoryEntry(
        date: DateTime(2026, 9, 9),
        riskScore: 74.0,
        riskLevel: RiskLevel.high,
        rainfallMm: 92.0,
        incidentCount: 2,
        notes: 'Soil saturation reached 80%. Precautionary alert issued.',
      ),
      RegionHistoryEntry(
        date: DateTime(2026, 9, 8),
        riskScore: 68.0,
        riskLevel: RiskLevel.moderate,
        rainfallMm: 64.0,
        incidentCount: 1,
        notes: 'Initial rain band entered valley. Catchments began swelling.',
      ),
      RegionHistoryEntry(
        date: DateTime(2026, 9, 7),
        riskScore: 45.0,
        riskLevel: RiskLevel.moderate,
        rainfallMm: 28.0,
        incidentCount: 0,
        notes: 'Stable conditions with moderate cloud cover.',
      ),
      RegionHistoryEntry(
        date: DateTime(2026, 9, 6),
        riskScore: 32.0,
        riskLevel: RiskLevel.low,
        rainfallMm: 12.0,
        incidentCount: 0,
        notes: 'Clear weather, slope sensors nominal.',
      ),
      RegionHistoryEntry(
        date: DateTime(2026, 9, 5),
        riskScore: 28.0,
        riskLevel: RiskLevel.low,
        rainfallMm: 5.0,
        incidentCount: 0,
        notes: 'Dry spell baseline.',
      ),
    ];
  }
}
