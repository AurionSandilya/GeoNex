import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/exposure_asset.dart';
import '../../state/app_state.dart';
import '../../widgets/interactive_map_canvas.dart';
import '../../widgets/risk_badge.dart';

class RiskMapScreen extends StatefulWidget {
  final AppState appState;
  final Function(String routeName, {Object? arguments})? onNavigateNamed;

  const RiskMapScreen({
    super.key,
    required this.appState,
    this.onNavigateNamed,
  });

  @override
  State<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends State<RiskMapScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLayersBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Map Layers & Overlays',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  _layerSwitchTile('Risk Zones & Hazard Polygons', widget.appState.layerRiskZones, 'riskZones', setModalState),
                  _layerSwitchTile('Road Networks & Arteries', widget.appState.layerRoads, 'roads', setModalState),
                  _layerSwitchTile('Rainfall Heatmap (IMD)', widget.appState.layerRainfall, 'rainfall', setModalState),
                  _layerSwitchTile('Soil Moisture Index (SMAP)', widget.appState.layerSoilMoisture, 'soilMoisture', setModalState),
                  _layerSwitchTile('Historical Landslide Scars (GSI)', widget.appState.layerHistoricalLandslides, 'historicalLandslides', setModalState),
                  _layerSwitchTile('Critical Infrastructure & Hospitals', widget.appState.layerInfrastructure, 'infrastructure', setModalState),
                  _layerSwitchTile('Verified Citizen Reports', widget.appState.layerCitizenReports, 'citizenReports', setModalState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _layerSwitchTile(String title, bool val, String key, StateSetter setModalState) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      value: val,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: (_) {
        widget.appState.toggleLayer(key);
        setModalState(() {});
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLoc = widget.appState.selectedLocation;
    final riskResult = selectedLoc?.calculatedResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Risk Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Layer Toggles',
            onPressed: _showLayersBottomSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Full Screen Interactive Topographic Map
          Positioned.fill(
            child: InteractiveMapCanvas(
              locations: widget.appState.locations,
              assets: widget.appState.assets,
              reports: widget.appState.reports,
              selectedLocationId: widget.appState.selectedLocationId,
              showRiskZones: widget.appState.layerRiskZones,
              showRoads: widget.appState.layerRoads,
              showRainfallOverlay: widget.appState.layerRainfall,
              showSoilMoistureOverlay: widget.appState.layerSoilMoisture,
              showHistoricalLandslides: widget.appState.layerHistoricalLandslides,
              showInfrastructure: widget.appState.layerInfrastructure,
              showCitizenReports: widget.appState.layerCitizenReports,
              onSelectLocation: (locId) {
                widget.appState.selectLocation(locId);
                setState(() {});
              },
              onSelectAsset: (asset) {
                widget.appState.selectLocation(asset.locationId);
                _showAssetDialog(asset);
              },
              onSelectReport: (report) {
                _showReportDialog(report);
              },
            ),
          ),

          // 2. Floating Search Bar & Region Selector matching wireframe
          Positioned(
            top: 12,
            left: 12,
            right: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search location, road corridor, hospital...',
                        border: InputBorder.none,
                        isDense: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          final match = widget.appState.locations.firstWhere(
                            (l) => l.name.toLowerCase().contains(val.toLowerCase()),
                            orElse: () => widget.appState.locations.first,
                          );
                          widget.appState.selectLocation(match.id);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Location Details Floating Sheet matching wireframe
          if (selectedLoc != null)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x15000000), blurRadius: 14, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Header & Risk Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedLoc.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${selectedLoc.district}, ${selectedLoc.state}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        RiskBadge(
                          riskLevel: riskResult?.riskLevel ?? RiskLevel.high,
                          score: riskResult?.riskScore,
                          isCompact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Micro-metrics strip with pastel backgrounds
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoMetric('Rainfall', '${selectedLoc.dynamicConditions.rainfallMm.toInt()} mm', AppColors.primary, AppColors.primaryPastel),
                        _infoMetric('Soil Moisture', '${(selectedLoc.dynamicConditions.soilMoistureIndex * 100).toInt()}%', AppColors.riskModerate, AppColors.riskModeratePastel),
                        _infoMetric('Slope', '${selectedLoc.susceptibility.slopeAngleDegrees.toInt()}°', AppColors.riskHigh, AppColors.riskHighPastel),
                        _infoMetric('Confidence', '${((riskResult?.confidence ?? 0.93) * 100).toInt()}%', AppColors.teal, AppColors.tealPastel),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onNavigateNamed?.call('risk_details'),
                            icon: const Icon(Icons.assessment_outlined, size: 14),
                            label: const Text('View Risk Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => widget.onNavigateNamed?.call('risk_routing'),
                            icon: const Icon(Icons.alt_route, size: 14),
                            label: const Text('Get Safe Route', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
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
    );
  }

  Widget _infoMetric(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  void _showAssetDialog(ExposureAsset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(asset.type.icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                asset.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${asset.type.displayName}', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Exposure Level: ${asset.exposureLevel.toInt()}%', style: const TextStyle(color: AppColors.riskHigh, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Connectivity Impact: ${asset.connectivityImpact.toInt()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Population at Risk: ${asset.estimatedPopulationAtRisk}', style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Notes: ${asset.notes}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showReportDialog(dynamic report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Report #${report.reportId}'),
        content: Text('${report.notes}\n\nStatus: ${report.verificationStatus.name.toUpperCase()}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
