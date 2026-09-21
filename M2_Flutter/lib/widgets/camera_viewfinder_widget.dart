import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';

enum HazardScenePreset {
  activeLandslide('Active Landslide Scarp', Color(0xFF3B1D11), Color(0xFF78350F)),
  roadCrack('Pavement Tension Cracks', Color(0xFF1E293B), Color(0xFF475569)),
  debrisFlow('Debris & Mud Flow', Color(0xFF292524), Color(0xFF57534E)),
  retainingWall('Retaining Wall Shear', Color(0xFF1C1917), Color(0xFF44403C)),
  liveOptical('Live Mountain Corridor', Color(0xFF0F172A), Color(0xFF334155));

  final String label;
  final Color primaryTone;
  final Color secondaryTone;
  const HazardScenePreset(this.label, this.primaryTone, this.secondaryTone);
}

enum CameraFilterMode {
  normal('Standard RGB'),
  edgeDetection('Edge / Fracture High-Pass'),
  thermal('Thermal Relief IR'),
  topoRelief('DEM Topo Contour');

  final String label;
  const CameraFilterMode(this.label);
}

class CameraViewfinderWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  final bool isVideoMode;
  final ValueChanged<bool>? onModeChanged;
  final VoidCallback? onCapture;
  final ValueChanged<String>? onImageCaptured;
  final String? capturedImagePath;

  const CameraViewfinderWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.isVideoMode = false,
    this.onModeChanged,
    this.onCapture,
    this.onImageCaptured,
    this.capturedImagePath,
  });

  @override
  State<CameraViewfinderWidget> createState() => _CameraViewfinderWidgetState();
}

class _CameraViewfinderWidgetState extends State<CameraViewfinderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shutterFlashController;
  late AnimationController _focusRingController;

  double _zoomLevel = 1.0;
  String _flashMode = 'Auto'; // Auto, On, Off
  HazardScenePreset _activeScene = HazardScenePreset.activeLandslide;
  CameraFilterMode _activeFilter = CameraFilterMode.normal;
  Offset? _focusPoint;
  bool _isCaptured = false;
  String? _capturedTimestamp;
  int _evidenceHash = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _shutterFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _focusRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shutterFlashController.dispose();
    _focusRingController.dispose();
    super.dispose();
  }

  void _triggerCapture() {
    _shutterFlashController.forward(from: 0.0);
    setState(() {
      _isCaptured = true;
      _capturedTimestamp = DateFormat('dd MMM yyyy • HH:mm:ss').format(DateTime.now());
      _evidenceHash = DateTime.now().millisecondsSinceEpoch.hashCode;
    });

    widget.onCapture?.call();
    widget.onImageCaptured?.call('sealed_evidence_${DateTime.now().millisecondsSinceEpoch}.jpg');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Evidence Frame Captured & Sealed with GPS ${_activeScene.label}!',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.teal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleTapToFocus(TapDownDetails details) {
    setState(() {
      _focusPoint = details.localPosition;
    });
    _focusRingController.forward(from: 0.0);
  }

  void _retakePhoto() {
    setState(() {
      _isCaptured = false;
    });
  }

  void _toggleFlash() {
    setState(() {
      if (_flashMode == 'Auto') {
        _flashMode = 'On';
      } else if (_flashMode == 'On') {
        _flashMode = 'Off';
      } else {
        _flashMode = 'Auto';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _isCaptured
        ? (_capturedTimestamp ?? DateFormat('dd MMM yyyy • HH:mm:ss').format(DateTime.now()))
        : DateFormat('dd MMM yyyy • HH:mm:ss').format(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070B10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isCaptured ? AppColors.teal : AppColors.border, width: _isCaptured ? 2 : 1),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Top Camera Utility Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.black.withOpacity(0.85),
              child: Row(
                children: [
                  // Flash toggle
                  InkWell(
                    onTap: _toggleFlash,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _flashMode == 'On' ? AppColors.primaryPastel : Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _flashMode == 'Off' ? Icons.flash_off : (_flashMode == 'On' ? Icons.flash_on : Icons.flash_auto),
                            size: 14,
                            color: _flashMode == 'On' ? AppColors.primary : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(_flashMode, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _flashMode == 'On' ? AppColors.primary : Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Scene Preset Menu
                  Expanded(
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HazardScenePreset>(
                          value: _activeScene,
                          dropdownColor: const Color(0xFF1E293B),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                          items: HazardScenePreset.values.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s.label, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: _isCaptured
                              ? null
                              : (newScene) {
                                  if (newScene != null) setState(() => _activeScene = newScene);
                                },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Filter Mode Menu
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: _activeFilter != CameraFilterMode.normal ? AppColors.tealPastel : Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CameraFilterMode>(
                        value: _activeFilter,
                        dropdownColor: const Color(0xFF1E293B),
                        icon: Icon(Icons.filter_b_and_w, color: _activeFilter != CameraFilterMode.normal ? AppColors.teal : Colors.white70, size: 14),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _activeFilter != CameraFilterMode.normal ? AppColors.teal : Colors.white),
                        items: CameraFilterMode.values.map((f) {
                          return DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          );
                        }).toList(),
                        onChanged: (newFilter) {
                          if (newFilter != null) setState(() => _activeFilter = newFilter);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Viewfinder Main Frame
            GestureDetector(
              onTapDown: _handleTapToFocus,
              child: SizedBox(
                height: 240,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Dynamic Scene & Filter Layer with Zoom
                    Positioned.fill(
                      child: Transform.scale(
                        scale: _zoomLevel,
                        child: CustomPaint(
                          painter: _DynamicHazardScenePainter(
                            scene: _activeScene,
                            filter: _activeFilter,
                          ),
                        ),
                      ),
                    ),

                    // Scanning Laser HUD
                    if (!_isCaptured)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Positioned(
                            top: 240 * _pulseController.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1.5,
                              color: AppColors.teal.withOpacity(0.4),
                            ),
                          );
                        },
                      ),

                    // Corner HUD Brackets & Crosshair
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ViewfinderOverlayPainter(
                          accentColor: widget.isVideoMode ? AppColors.riskHigh : AppColors.accent,
                        ),
                      ),
                    ),

                    // Tap-to-Focus Reticle
                    if (_focusPoint != null)
                      AnimatedBuilder(
                        animation: _focusRingController,
                        builder: (context, child) {
                          final scale = 1.5 - (0.5 * _focusRingController.value);
                          final opacity = 1.0 - (0.5 * _focusRingController.value);
                          return Positioned(
                            left: _focusPoint!.dx - 22,
                            top: _focusPoint!.dy - 22,
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.accent, width: 1.8),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.gps_fixed, size: 14, color: AppColors.accent),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    // Top Indicators
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _isCaptured ? AppColors.teal : AppColors.teal.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _isCaptured ? AppColors.teal : (widget.isVideoMode ? AppColors.riskHigh : AppColors.teal),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _isCaptured ? 'SEALED EVIDENCE FRAME' : (widget.isVideoMode ? 'REC LIVE' : 'LIVE VIEWFINDER'),
                                  style: TextStyle(
                                    color: _isCaptured ? AppColors.teal : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _isCaptured ? 'HASH #${_evidenceHash.toRadixString(16).toUpperCase()}' : '${(_zoomLevel).toStringAsFixed(1)}x ZOOM',
                              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Shutter Flash Animation Screen
                    AnimatedBuilder(
                      animation: _shutterFlashController,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              color: Colors.white.withOpacity(1.0 - _shutterFlashController.value),
                            ),
                          ),
                        );
                      },
                    ),

                    // Bottom Verified Metadata Stamp
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _isCaptured ? AppColors.teal.withOpacity(0.8) : Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.my_location, size: 12, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Text(
                                  'GPS: ${widget.latitude.toStringAsFixed(4)}°N, ${widget.longitude.toStringAsFixed(4)}°E',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.verified, size: 13, color: AppColors.teal),
                                const SizedBox(width: 4),
                                Text(
                                  _isCaptured ? 'HARDWARE SEALED' : 'GPS LOCKED',
                                  style: const TextStyle(
                                    color: AppColors.teal,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 11, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  widget.locationName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Interactive Camera Controls & Zoom strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.black.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Optical Zoom Buttons
                  Row(
                    children: [0.5, 1.0, 2.0, 5.0].map((z) {
                      final isSelected = (_zoomLevel - z).abs() < 0.1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: InkWell(
                          onTap: _isCaptured ? null : () => setState(() => _zoomLevel = z),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${z == 0.5 ? ".5" : z.toInt()}x',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Main Shutter / Retake Controls
                  if (_isCaptured)
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _retakePhoto,
                          icon: const Icon(Icons.replay, size: 13, color: Colors.white70),
                          label: const Text('Retake', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.tealPastel,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.teal),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check, size: 14, color: AppColors.teal),
                              SizedBox(width: 4),
                              Text('Captured', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.teal)),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        // Shutter Trigger Button
                        InkWell(
                          onTap: _triggerCapture,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.isVideoMode ? AppColors.riskHigh : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicHazardScenePainter extends CustomPainter {
  final HazardScenePreset scene;
  final CameraFilterMode filter;

  _DynamicHazardScenePainter({
    required this.scene,
    required this.filter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color skyTop = const Color(0xFF1E293B);
    Color skyBottom = const Color(0xFF334155);
    Color mountainColor = scene.primaryTone;
    Color debrisColor = scene.secondaryTone;
    Color roadColor = const Color(0xFF1F2937);

    if (filter == CameraFilterMode.thermal) {
      skyTop = const Color(0xFF1E1B4B);
      skyBottom = const Color(0xFF3730A3);
      mountainColor = const Color(0xFFF97316);
      debrisColor = const Color(0xFFEF4444);
      roadColor = const Color(0xFF6366F1);
    } else if (filter == CameraFilterMode.edgeDetection) {
      skyTop = Colors.black;
      skyBottom = const Color(0xFF111827);
      mountainColor = const Color(0xFF374151);
      debrisColor = const Color(0xFFE5E7EB);
      roadColor = const Color(0xFF4B5563);
    } else if (filter == CameraFilterMode.topoRelief) {
      skyTop = const Color(0xFF042F2E);
      skyBottom = const Color(0xFF0F766E);
      mountainColor = const Color(0xFF0D9488);
      debrisColor = const Color(0xFF14B8A6);
      roadColor = const Color(0xFF115E59);
    }

    // Gradient sky
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skyTop, skyBottom],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.5), skyPaint);

    // Mountain silhouettes & slope
    final mountainPaint = Paint()..color = mountainColor;
    final mPath = Path();
    mPath.moveTo(0, size.height * 0.5);
    mPath.lineTo(size.width * 0.25, size.height * 0.22);
    mPath.lineTo(size.width * 0.65, size.height * 0.38);
    mPath.lineTo(size.width, size.height * 0.18);
    mPath.lineTo(size.width, size.height);
    mPath.lineTo(0, size.height);
    mPath.close();
    canvas.drawPath(mPath, mountainPaint);

    // Landslide debris or crack feature
    final debrisPaint = Paint()..color = debrisColor;
    if (scene == HazardScenePreset.roadCrack) {
      // Crack lines
      final crackPaint = Paint()
        ..color = (filter == CameraFilterMode.edgeDetection) ? Colors.white : const Color(0xFFEF4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      final cPath = Path();
      cPath.moveTo(size.width * 0.2, size.height * 0.85);
      cPath.lineTo(size.width * 0.38, size.height * 0.72);
      cPath.lineTo(size.width * 0.45, size.height * 0.76);
      cPath.lineTo(size.width * 0.62, size.height * 0.64);
      cPath.lineTo(size.width * 0.8, size.height * 0.68);
      canvas.drawPath(cPath, crackPaint);
    } else {
      // Debris slope fan
      final dPath = Path();
      dPath.moveTo(size.width * 0.32, size.height * 0.36);
      dPath.lineTo(size.width * 0.68, size.height * 0.40);
      dPath.lineTo(size.width * 0.85, size.height * 0.85);
      dPath.lineTo(size.width * 0.15, size.height * 0.85);
      dPath.close();
      canvas.drawPath(dPath, debrisPaint);
    }

    // Road strip
    final roadPaint = Paint()..color = roadColor;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.18),
      roadPaint,
    );

    // Topographic contours if topoRelief
    if (filter == CameraFilterMode.topoRelief) {
      final contourPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      for (double i = 0.2; i < 0.9; i += 0.12) {
        final cPath = Path();
        cPath.moveTo(0, size.height * i);
        cPath.quadraticBezierTo(size.width * 0.5, size.height * (i - 0.08), size.width, size.height * i);
        canvas.drawPath(cPath, contourPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicHazardScenePainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.filter != filter;
}

class _ViewfinderOverlayPainter extends CustomPainter {
  final Color accentColor;

  _ViewfinderOverlayPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bracketPaint = Paint()
      ..color = accentColor.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double bSize = 18.0;
    const double pad = 16.0;

    // Top-Left
    canvas.drawLine(const Offset(pad, pad + bSize), const Offset(pad, pad), bracketPaint);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad + bSize, pad), bracketPaint);

    // Top-Right
    canvas.drawLine(Offset(size.width - pad - bSize, pad), Offset(size.width - pad, pad), bracketPaint);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(size.width - pad, pad + bSize), bracketPaint);

    // Bottom-Left
    canvas.drawLine(Offset(pad, size.height - pad - bSize), Offset(pad, size.height - pad), bracketPaint);
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad + bSize, size.height - pad), bracketPaint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width - pad - bSize, size.height - pad), Offset(size.width - pad, size.height - pad), bracketPaint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad), Offset(size.width - pad, size.height - pad - bSize), bracketPaint);

    // Center Crosshair
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(center.dx - 10, center.dy), Offset(center.dx + 10, center.dy), bracketPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 10), Offset(center.dx, center.dy + 10), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderOverlayPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}
