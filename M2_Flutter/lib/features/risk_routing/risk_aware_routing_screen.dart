import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/route_model.dart';
import '../../state/app_state.dart';
import '../../widgets/risk_badge.dart';

class RiskAwareRoutingScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onBack;

  const RiskAwareRoutingScreen({
    super.key,
    required this.appState,
    this.onBack,
  });

  @override
  State<RiskAwareRoutingScreen> createState() => _RiskAwareRoutingScreenState();
}

class _RiskAwareRoutingScreenState extends State<RiskAwareRoutingScreen> {
  final String _origin = 'Papum Pare';
  final String _destination = 'Hospital';
  List<RiskRoute> _routes = [];
  RiskRoute? _selectedRoute;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  void _loadRoutes() {
    widget.appState.repository.getRoutes(_origin, _destination).then((routesList) {
      if (mounted) {
        setState(() {
          _routes = routesList;
          _selectedRoute = _routes.firstWhere((r) => r.isRecommended, orElse: () => _routes.first);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Safe Route'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Origin & Destination Card matching wireframe
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trip_origin, size: 16, color: AppColors.teal),
                      const SizedBox(width: 8),
                      const Text('Origin: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      Expanded(
                        child: Text(
                          _origin,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.riskHigh),
                      const SizedBox(width: 8),
                      const Text('Destination: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      Expanded(
                        child: Text(
                          _destination,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Interactive Route Vector Visualization
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _RouteMapVectorPainter(
                    selectedRoute: _selectedRoute,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Route Safety Comparison',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            // 3. Alternative Route Cards matching wireframe
            if (_routes.isNotEmpty)
              ..._routes.map((route) {
                final isSelected = _selectedRoute?.routeId == route.routeId;
                final Color cardBg = route.isRecommended
                    ? AppColors.riskLowPastel
                    : (route.riskLevel == RiskLevel.high ? AppColors.riskHighPastel : AppColors.riskModeratePastel);
                final Color cardBorder = route.isRecommended
                    ? AppColors.riskLowBorder
                    : (route.riskLevel == RiskLevel.high ? AppColors.riskHighBorder : AppColors.riskModerateBorder);

                return GestureDetector(
                  onTap: () => setState(() => _selectedRoute = route),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg.withAlpha(150),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : cardBorder,
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              route.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: route.isRecommended ? AppColors.teal : AppColors.textPrimary,
                              ),
                            ),
                            if (route.isRecommended)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.teal.withAlpha(80)),
                                ),
                                child: const Text(
                                  'LOW RISK RECOMMENDED',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.teal),
                                ),
                              )
                            else if (route.riskLevel == RiskLevel.high)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.riskHigh.withAlpha(80)),
                                ),
                                child: const Text(
                                  'HIGH RISK Avoid',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.riskHigh),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.riskModerate.withAlpha(80)),
                                ),
                                child: const Text(
                                  'MODERATE RISK',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.riskModerate),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '${route.distanceKm} km, ${route.estimatedDurationMinutes} min',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                            ),
                            const Spacer(),
                            RiskBadge(riskLevel: route.riskLevel, score: route.riskScore, isCompact: true),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          route.avoidanceReason,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 14),

            // Confirm Selection Button matching wireframe (`Use Recommended Route`)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Safe route engaged: ${_selectedRoute?.name ?? "Route B"}!'),
                      backgroundColor: AppColors.teal,
                    ),
                  );
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Use Recommended Route'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RouteMapVectorPainter extends CustomPainter {
  final RiskRoute? selectedRoute;

  _RouteMapVectorPainter({this.selectedRoute});

  @override
  void paint(Canvas canvas, Size size) {
    // Route A: High Risk Path (Crimson)
    final paintA = Paint()
      ..color = AppColors.riskHigh.withAlpha(selectedRoute?.routeId == 'route_a' ? 255 : 90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = selectedRoute?.routeId == 'route_a' ? 4.5 : 2.5;

    final pathA = Path();
    pathA.moveTo(40, size.height * 0.7);
    pathA.quadraticBezierTo(size.width * 0.4, size.height * 0.8, size.width * 0.5, size.height * 0.45);
    pathA.lineTo(size.width - 40, size.height * 0.3);
    canvas.drawPath(pathA, paintA);

    // Hazard Marker on Route A
    final hazardPaint = Paint()..color = AppColors.riskCritical;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.45), 6.0, hazardPaint);

    // Route B: Low Risk Recommended Path (Teal/Green)
    final paintB = Paint()
      ..color = AppColors.teal.withAlpha(selectedRoute?.routeId == 'route_b' ? 255 : 100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = selectedRoute?.routeId == 'route_b' ? 4.5 : 2.5;

    final pathB = Path();
    pathB.moveTo(40, size.height * 0.7);
    pathB.quadraticBezierTo(size.width * 0.3, size.height * 0.15, size.width * 0.7, size.height * 0.15);
    pathB.lineTo(size.width - 40, size.height * 0.3);
    canvas.drawPath(pathB, paintB);

    // Start Pin (Origin)
    final startPin = Paint()..color = AppColors.teal;
    canvas.drawCircle(Offset(40, size.height * 0.7), 7.0, startPin);

    // End Pin (Hospital)
    final endPin = Paint()..color = AppColors.riskHigh;
    canvas.drawCircle(Offset(size.width - 40, size.height * 0.3), 7.0, endPin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
