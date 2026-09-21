import '../constants/app_constants.dart';

class RouteCoordinate {
  final double latitude;
  final double longitude;
  final String? label;

  const RouteCoordinate({
    required this.latitude,
    required this.longitude,
    this.label,
  });
}

class RiskRoute {
  final String routeId;
  final String name; // e.g. "ROUTE A", "ROUTE B"
  final String origin;
  final String destination;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final RiskLevel riskLevel;
  final double riskScore;
  final bool isRecommended;
  final String avoidanceReason; // e.g. "High Slope Instability near Ch 14+200"
  final List<RouteCoordinate> waypoints;
  final List<String> hazardPointsOnRoute;

  const RiskRoute({
    required this.routeId,
    required this.name,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.riskLevel,
    required this.riskScore,
    this.isRecommended = false,
    this.avoidanceReason = '',
    required this.waypoints,
    this.hazardPointsOnRoute = const [],
  });
}
