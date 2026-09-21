import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/exposure_asset.dart';
import '../../state/app_state.dart';
import '../../widgets/risk_factor_bar.dart';

class RiskDetailsScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onBack;
  final Function(String routeName, {Object? arguments})? onNavigateNamed;

  const RiskDetailsScreen({
    super.key,
    required this.appState,
    this.onBack,
    this.onNavigateNamed,
  });

  @override
  State<RiskDetailsScreen> createState() => _RiskDetailsScreenState();
}

class _RiskDetailsScreenState extends State<RiskDetailsScreen> {
  bool _showExposureDetails = false;

  @override
  Widget build(BuildContext context) {
    final location = widget.appState.selectedLocation;
    final riskResult = location?.calculatedResult;
    final assets = widget.appState.selectedLocationAssets;

    if (location == null || riskResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Risk Assessment')),
        body: const Center(child: Text('No location data selected.')),
      );
    }

    final double rainVal = riskResult.factorContributions['Rainfall (IMD)'] ?? 35.0;
    final double soilVal = riskResult.factorContributions['Soil Moisture (SMAP)'] ?? 25.0;
    final double slopeVal = riskResult.factorContributions['Slope & Topography'] ?? 20.0;
    final double historyVal = riskResult.factorContributions['Historical Landslides'] ?? 10.0;
    final double seismicVal = riskResult.factorContributions['Seismic Activity'] ?? 5.0;
    final double reportsVal = riskResult.factorContributions['Field Reports (App)'] ?? 5.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: const Text('Risk Assessment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.alt_route),
            tooltip: 'Safe Route',
            onPressed: () => widget.onNavigateNamed?.call('risk_aware_routing'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Location Header
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${location.name}, ${location.district}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Huge Score Card matching wireframe in Soft Pastel Coral
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.riskHighPastel.withAlpha(160),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.riskHighBorder, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${riskResult.label} RISK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: riskResult.color,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${riskResult.riskScore.toInt()}',
                        style: const TextStyle(
                          fontSize: 58,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.teal.withAlpha(80)),
                    ),
                    child: Text(
                      'Confidence: ${(riskResult.confidence * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Risk Factors Breakdown Section
            const Text(
              'Risk Factors Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Susceptibility (45%) + Dynamic Environmental Triggers (55%)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
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
                  RiskFactorBar(
                    label: 'Rainfall Intensity (IMD API)',
                    value: rainVal,
                    displayValue: '${location.dynamicConditions.rainfallMm.toInt()} mm',
                    icon: Icons.water_drop_outlined,
                    barColor: AppColors.primary,
                  ),
                  RiskFactorBar(
                    label: 'Soil Moisture Index (SMAP)',
                    value: soilVal,
                    displayValue: '${(location.dynamicConditions.soilMoistureIndex * 100).toInt()}% Saturation',
                    icon: Icons.grass_outlined,
                    barColor: AppColors.riskModerate,
                  ),
                  RiskFactorBar(
                    label: 'Slope & Relief Angle',
                    value: slopeVal,
                    displayValue: '${location.susceptibility.slopeAngleDegrees.toInt()}° Escarpment',
                    icon: Icons.landscape_outlined,
                    barColor: AppColors.riskHigh,
                  ),
                  RiskFactorBar(
                    label: 'Lithology & DEM Susceptibility',
                    value: 65.0,
                    displayValue: location.susceptibility.lithology,
                    icon: Icons.terrain_outlined,
                    barColor: AppColors.purple,
                  ),
                  RiskFactorBar(
                    label: 'Seismic Feed (USGS/ISC)',
                    value: seismicVal,
                    displayValue: 'Mag ${location.dynamicConditions.seismicActivityMag}',
                    icon: Icons.show_chart,
                    barColor: AppColors.teal,
                  ),
                  RiskFactorBar(
                    label: 'Historical Landslide Records (GSI)',
                    value: historyVal,
                    displayValue: '${location.susceptibility.historicalLandslidesCount} Past Incidents',
                    icon: Icons.history_edu,
                    barColor: AppColors.statusPending,
                  ),
                  RiskFactorBar(
                    label: 'Verified Citizen & Field Reports',
                    value: reportsVal,
                    displayValue: '${location.dynamicConditions.verifiedFieldReportsCount} Verified',
                    icon: Icons.verified_outlined,
                    barColor: AppColors.riskCritical,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Interactive Simulation Tool
            ExpansionTile(
              backgroundColor: AppColors.surfaceCard,
              collapsedBackgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.tune, color: AppColors.primary),
              title: const Text(
                'Simulate Weather & Sensor Shifts',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Test dynamic Risk Engine recalculation',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('24h Rainfall: ${location.dynamicConditions.rainfallMm.toInt()} mm', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Slider(
                        value: location.dynamicConditions.rainfallMm,
                        min: 0,
                        max: 250,
                        divisions: 25,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          widget.appState.simulateDynamicChange(
                            locationId: location.id,
                            rainfallMm: val,
                            soilMoistureIndex: location.dynamicConditions.soilMoistureIndex,
                          );
                        },
                      ),
                      Text('Soil Moisture: ${(location.dynamicConditions.soilMoistureIndex * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Slider(
                        value: location.dynamicConditions.soilMoistureIndex,
                        min: 0.1,
                        max: 1.0,
                        divisions: 18,
                        activeColor: AppColors.riskModerate,
                        onChanged: (val) {
                          widget.appState.simulateDynamicChange(
                            locationId: location.id,
                            rainfallMm: location.dynamicConditions.rainfallMm,
                            soilMoistureIndex: val,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 5. Exposure Analysis Toggle / Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showExposureDetails = !_showExposureDetails;
                  });
                },
                icon: Icon(_showExposureDetails ? Icons.expand_less : Icons.expand_more),
                label: Text(_showExposureDetails ? 'Hide Exposure Analysis' : 'View Exposure Analysis (${assets.length} Assets)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceElevated,
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),

            if (_showExposureDetails) ...[
              const SizedBox(height: 16),
              const Text(
                'Exposed Infrastructure & Population',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...assets.map((asset) => _buildAssetItem(asset)),
            ],

            const SizedBox(height: 24),

            // Direct Navigation to Action Engine
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => widget.onNavigateNamed?.call('action_engine'),
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Proceed to Action Engine'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(ExposureAsset asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: asset.isBlocked ? AppColors.riskHighPastel.withAlpha(120) : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: asset.isBlocked ? AppColors.riskHighBorder : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: asset.isBlocked ? AppColors.riskHighPastel : AppColors.primaryPastel,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(asset.type.icon, size: 18, color: asset.isBlocked ? AppColors.riskHigh : AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  '${asset.type.displayName} • ${asset.estimatedPopulationAtRisk} pop. at risk',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Exp: ${asset.exposureLevel.toInt()}%',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.riskModerate),
              ),
              Text(
                'Conn: ${asset.connectivityImpact.toInt()}%',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
