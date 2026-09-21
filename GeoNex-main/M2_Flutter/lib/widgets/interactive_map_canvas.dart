import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/models/citizen_report.dart';
import '../core/models/exposure_asset.dart';
import '../core/models/risk_data.dart';

class InteractiveMapCanvas extends StatefulWidget {
  final List<RiskLocation> locations;
  final List<ExposureAsset> assets;
  final List<CitizenReport> reports;
  final String? selectedLocationId;
  final Function(String locationId)? onSelectLocation;
  final Function(ExposureAsset asset)? onSelectAsset;
  final Function(CitizenReport report)? onSelectReport;

  // Layer flags
  final bool showRiskZones;
  final bool showRoads;
  final bool showRainfallOverlay;
  final bool showSoilMoistureOverlay;
  final bool showHistoricalLandslides;
  final bool showInfrastructure;
  final bool showCitizenReports;

  const InteractiveMapCanvas({
    super.key,
    required this.locations,
    required this.assets,
    required this.reports,
    this.selectedLocationId,
    this.onSelectLocation,
    this.onSelectAsset,
    this.onSelectReport,
    this.showRiskZones = true,
    this.showRoads = true,
    this.showRainfallOverlay = true,
    this.showSoilMoistureOverlay = true,
    this.showHistoricalLandslides = true,
    this.showInfrastructure = true,
    this.showCitizenReports = true,
  });

  @override
  State<InteractiveMapCanvas> createState() => _InteractiveMapCanvasState();
}

class _InteractiveMapCanvasState extends State<InteractiveMapCanvas> {
  final TransformationController _transformController = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Soft light pastel map canvas
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Interactive Canvas
          InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.8,
            maxScale: 3.5,
            child: SizedBox(
              width: 800,
              height: 600,
              child: CustomPaint(
                painter: _TopographicTerrainPainter(
                  locations: widget.locations,
                  assets: widget.assets,
                  reports: widget.reports,
                  selectedLocationId: widget.selectedLocationId,
                  showRiskZones: widget.showRiskZones,
                  showRoads: widget.showRoads,
                  showRainfallOverlay: widget.showRainfallOverlay,
                  showSoilMoistureOverlay: widget.showSoilMoistureOverlay,
                  showHistoricalLandslides: widget.showHistoricalLandslides,
                ),
                child: _buildInteractiveOverlayPins(),
              ),
            ),
          ),

          // Map Control HUD & Compass
          Positioned(
            top: 14,
            right: 14,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.add,
                  onTap: () {
                    final matrix = _transformController.value.clone();
                    matrix.scale(1.2);
                    _transformController.value = matrix;
                  },
                ),
                const SizedBox(height: 6),
                _buildMapButton(
                  icon: Icons.remove,
                  onTap: () {
                    final matrix = _transformController.value.clone();
                    matrix.scale(0.8);
                    _transformController.value = matrix;
                  },
                ),
                const SizedBox(height: 6),
                _buildMapButton(
                  icon: Icons.center_focus_strong,
                  onTap: () {
                    _transformController.value = Matrix4.identity();
                  },
                ),
              ],
            ),
          ),

          // Map Legend Indicator (Pastel Pills)
          Positioned(
            bottom: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendItem('HIGH', AppColors.riskHigh, AppColors.riskHighPastel),
                  const SizedBox(width: 8),
                  _legendItem('MEDIUM', AppColors.riskModerate, AppColors.riskModeratePastel),
                  const SizedBox(width: 8),
                  _legendItem('LOW', AppColors.riskLow, AppColors.riskLowPastel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildInteractiveOverlayPins() {
    return Stack(
      children: [
        // Location Risk Center Pins
        if (widget.showRiskZones)
          ...widget.locations.map((loc) {
            final pos = _mapCoordinatesToCanvas(loc.latitude, loc.longitude);
            final isSelected = loc.id == widget.selectedLocationId;
            final score = loc.calculatedResult?.riskScore.toInt() ?? 80;
            final color = loc.calculatedResult?.color ?? AppColors.riskHigh;

            return Positioned(
              left: pos.dx - 45,
              top: pos.dy - 40,
              child: GestureDetector(
                onTap: () => widget.onSelectLocation?.call(loc.id),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : color,
                          width: isSelected ? 2 : 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            loc.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white24 : color.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$score',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isSelected ? AppColors.primary : color,
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          }),

        // Infrastructure Pins
        if (widget.showInfrastructure)
          ...widget.assets.map((asset) {
            final pos = _mapCoordinatesToCanvas(asset.latitude, asset.longitude);
            return Positioned(
              left: pos.dx - 14,
              top: pos.dy - 14,
              child: GestureDetector(
                onTap: () => widget.onSelectAsset?.call(asset),
                child: Tooltip(
                  message: '${asset.name} (${asset.type.displayName})',
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: asset.isBlocked ? AppColors.riskHigh : AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x18000000), blurRadius: 4),
                      ],
                    ),
                    child: Icon(
                      asset.type.icon,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),

        // Verified Citizen Reports
        if (widget.showCitizenReports)
          ...widget.reports.map((report) {
            final pos = _mapCoordinatesToCanvas(report.latitude, report.longitude);
            return Positioned(
              left: pos.dx - 12,
              top: pos.dy - 12,
              child: GestureDetector(
                onTap: () => widget.onSelectReport?.call(report),
                child: Tooltip(
                  message: 'Report #${report.reportId}: ${report.notes}',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: report.verificationStatus == ReportVerificationStatus.verified
                          ? AppColors.teal
                          : AppColors.statusPending,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Offset _mapCoordinatesToCanvas(double lat, double lng) {
    final double normX = ((lng - 91.5) / 3.0).clamp(0.05, 0.95);
    final double normY = (1.0 - ((lat - 25.0) / 3.0)).clamp(0.05, 0.95);
    return Offset(normX * 800, normY * 600);
  }
}

class _TopographicTerrainPainter extends CustomPainter {
  final List<RiskLocation> locations;
  final List<ExposureAsset> assets;
  final List<CitizenReport> reports;
  final String? selectedLocationId;
  final bool showRiskZones;
  final bool showRoads;
  final bool showRainfallOverlay;
  final bool showSoilMoistureOverlay;
  final bool showHistoricalLandslides;

  _TopographicTerrainPainter({
    required this.locations,
    required this.assets,
    required this.reports,
    this.selectedLocationId,
    required this.showRiskZones,
    required this.showRoads,
    required this.showRainfallOverlay,
    required this.showSoilMoistureOverlay,
    required this.showHistoricalLandslides,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Soft pastel map base
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 1. Draw Elevation Contours & Mountain Ridges
    _drawContourLines(canvas, size);

    // 2. Draw Soil Moisture & Rainfall Heatmap Buffers (Pastel Cyan / Blue)
    if (showSoilMoistureOverlay || showRainfallOverlay) {
      _drawRainfallMoistureHeatmap(canvas, size);
    }

    // 3. Draw Pastel Hazard Risk Polygons
    if (showRiskZones) {
      _drawRiskZones(canvas, size);
    }

    // 4. Draw Road Network Lines
    if (showRoads) {
      _drawRoadNetwork(canvas, size);
    }

    // 5. Draw Historical Landslide Scars
    if (showHistoricalLandslides) {
      _drawHistoricalScars(canvas, size);
    }
  }

  void _drawContourLines(Canvas canvas, Size size) {
    final contourPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 8; i++) {
      final path = Path();
      final double yBase = (size.height / 8) * i;
      path.moveTo(0, yBase + 20);
      path.quadraticBezierTo(
        size.width * 0.25,
        yBase - 30 + (i * 5),
        size.width * 0.5,
        yBase + 15,
      );
      path.quadraticBezierTo(
        size.width * 0.75,
        yBase + 45 - (i * 6),
        size.width,
        yBase - 10,
      );
      canvas.drawPath(path, contourPaint);
    }

    // River Drainage Channel (Pastel Sky Blue)
    final riverPaint = Paint()
      ..color = const Color(0xFF7DD3FC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final riverPath = Path();
    riverPath.moveTo(size.width * 0.1, 0);
    riverPath.cubicTo(
      size.width * 0.35,
      size.height * 0.3,
      size.width * 0.45,
      size.height * 0.7,
      size.width * 0.85,
      size.height,
    );
    canvas.drawPath(riverPath, riverPaint);
  }

  void _drawRainfallMoistureHeatmap(Canvas canvas, Size size) {
    for (final loc in locations) {
      final pos = _mapCoordinatesToCanvas(loc.latitude, loc.longitude);
      final double radius = 70.0 + (loc.dynamicConditions.rainfallMm / 3.0);

      final heatPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF0284C7).withAlpha(35),
            const Color(0xFF38BDF8).withAlpha(15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: radius));

      canvas.drawCircle(pos, radius, heatPaint);
    }
  }

  void _drawRiskZones(Canvas canvas, Size size) {
    for (final loc in locations) {
      final pos = _mapCoordinatesToCanvas(loc.latitude, loc.longitude);
      final score = loc.calculatedResult?.riskScore ?? 75;
      final Color zoneColor = score >= 80
          ? AppColors.riskCritical
          : (score >= 65 ? AppColors.riskHigh : AppColors.riskModerate);

      final zoneFill = Paint()
        ..color = zoneColor.withAlpha(45)
        ..style = PaintingStyle.fill;

      final zoneBorder = Paint()
        ..color = zoneColor.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Realistic non-symmetric hazard polygon
      final path = Path();
      path.moveTo(pos.dx - 45, pos.dy - 30);
      path.lineTo(pos.dx + 40, pos.dy - 35);
      path.lineTo(pos.dx + 55, pos.dy + 25);
      path.lineTo(pos.dx + 10, pos.dy + 45);
      path.lineTo(pos.dx - 50, pos.dy + 35);
      path.close();

      canvas.drawPath(path, zoneFill);
      canvas.drawPath(path, zoneBorder);
    }
  }

  void _drawRoadNetwork(Canvas canvas, Size size) {
    // NH-415 Highway Line
    final roadPaintSafe = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final roadPaintHazard = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Segment 1 (Safe)
    final pathSafe = Path();
    pathSafe.moveTo(150, 450);
    pathSafe.lineTo(320, 320);
    canvas.drawPath(pathSafe, roadPaintSafe);

    // Segment 2 (Hazardous Cut Slope)
    final pathHazard = Path();
    pathHazard.moveTo(320, 320);
    pathHazard.lineTo(480, 240);
    canvas.drawPath(pathHazard, roadPaintHazard);

    // Segment 3 (Safe link to Hospital)
    final pathSafe2 = Path();
    pathSafe2.moveTo(480, 240);
    pathSafe2.lineTo(620, 160);
    canvas.drawPath(pathSafe2, roadPaintSafe);
  }

  void _drawHistoricalScars(Canvas canvas, Size size) {
    final scarPaint = Paint()
      ..color = const Color(0xFFF97316).withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (int i = 0; i < 5; i++) {
      final double x = 200.0 + (i * 90);
      final double y = 180.0 + (i * 45);
      canvas.drawLine(Offset(x - 10, y - 5), Offset(x + 10, y + 5), scarPaint);
      canvas.drawLine(Offset(x - 5, y - 10), Offset(x + 5, y + 10), scarPaint);
    }
  }

  Offset _mapCoordinatesToCanvas(double lat, double lng) {
    final double normX = ((lng - 91.5) / 3.0).clamp(0.05, 0.95);
    final double normY = (1.0 - ((lat - 25.0) / 3.0)).clamp(0.05, 0.95);
    return Offset(normX * 800, normY * 600);
  }

  @override
  bool shouldRepaint(covariant _TopographicTerrainPainter oldDelegate) => true;
}
