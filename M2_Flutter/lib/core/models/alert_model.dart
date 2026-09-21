import '../constants/app_constants.dart';

class AlertModel {
  final String alertId;
  final String locationId;
  final String locationName;
  final String region;
  final SeverityLevel severity;
  final String title;
  final String message;
  final String cause; // e.g. "Heavy Rainfall, High Soil Moisture"
  final String recommendedAction; // e.g. "Immediate Inspection"
  final DateTime createdAt;
  final AlertStatus status;
  final List<DeliveryChannel> deliveryChannels;
  final int previousRiskScore;
  final int currentRiskScore;

  const AlertModel({
    required this.alertId,
    required this.locationId,
    required this.locationName,
    required this.region,
    required this.severity,
    required this.title,
    required this.message,
    required this.cause,
    required this.recommendedAction,
    required this.createdAt,
    required this.status,
    required this.deliveryChannels,
    required this.previousRiskScore,
    required this.currentRiskScore,
  });

  AlertModel copyWith({
    String? alertId,
    String? locationId,
    String? locationName,
    String? region,
    SeverityLevel? severity,
    String? title,
    String? message,
    String? cause,
    String? recommendedAction,
    DateTime? createdAt,
    AlertStatus? status,
    List<DeliveryChannel>? deliveryChannels,
    int? previousRiskScore,
    int? currentRiskScore,
  }) {
    return AlertModel(
      alertId: alertId ?? this.alertId,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      region: region ?? this.region,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      cause: cause ?? this.cause,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      deliveryChannels: deliveryChannels ?? this.deliveryChannels,
      previousRiskScore: previousRiskScore ?? this.previousRiskScore,
      currentRiskScore: currentRiskScore ?? this.currentRiskScore,
    );
  }
}
