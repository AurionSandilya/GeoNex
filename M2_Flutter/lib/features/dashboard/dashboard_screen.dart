import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/exposure_asset.dart';
import '../../state/app_state.dart';
import '../../widgets/chart_widgets.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/priority_card.dart';
import '../../widgets/risk_badge.dart';

class DashboardScreen extends StatelessWidget {
  final AppState appState;
  final Function(int tabIndex)? onNavigateTab;
  final Function(String routeName, {Object? arguments})? onNavigateNamed;

  const DashboardScreen({
    super.key,
    required this.appState,
    this.onNavigateTab,
    this.onNavigateNamed,
  });

  @override
  Widget build(BuildContext context) {
    if (appState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final selectedLoc = appState.selectedLocation;
    final riskResult = selectedLoc?.calculatedResult;
    final priorityItems = appState.priorityQueue;
    final activeAlerts = appState.alerts.where((a) => a.status == AlertStatus.active).toList();

    // Summary counters
    final highRiskCount = appState.locations.where((l) => (l.calculatedResult?.riskScore ?? 0) >= 65).length;
    final blockedRoadsCount = appState.assets.where((a) => a.type == AssetType.road && a.isBlocked).length;
    final totalPopulationAtRisk = appState.assets.fold(0, (sum, a) => sum + a.estimatedPopulationAtRisk);

    final String lastUpdatedStr = DateFormat('dd MMM yyyy, HH:mm a').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Terra Sense'),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${activeAlerts.length}'),
              backgroundColor: AppColors.riskHigh,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => onNavigateTab?.call(3), // Alerts tab
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Pipeline',
            onPressed: () => appState.loadAllData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.loadAllData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Risk Overview Header Bar matching wireframe
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Risk Overview',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${selectedLoc?.name ?? "Papum Pare"}, ${selectedLoc?.state ?? "Arunachal Pradesh"}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last Updated: $lastUpdatedStr',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: appState.selectedLocationId,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                          items: appState.locations.map((loc) {
                            return DropdownMenuItem(
                              value: loc.id,
                              child: Text(loc.name),
                            );
                          }).toList(),
                          onChanged: (newLocId) {
                            if (newLocId != null) {
                              appState.selectLocation(newLocId);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Four Key Dashboard Metric Cards (Pastel Tints)
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.45,
                children: [
                  MetricCard(
                    title: 'High Risk Zones',
                    value: '$highRiskCount',
                    subtitle: 'Locations requiring watch',
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.riskHigh,
                    backgroundColor: AppColors.riskHighPastel.withAlpha(100),
                    onTap: () => onNavigateTab?.call(1), // Map tab
                  ),
                  MetricCard(
                    title: 'Active Alerts',
                    value: '${activeAlerts.length}',
                    subtitle: '${activeAlerts.where((a) => a.severity == SeverityLevel.critical).length} Critical level',
                    icon: Icons.crisis_alert,
                    iconColor: AppColors.riskCritical,
                    backgroundColor: AppColors.riskCriticalPastel.withAlpha(100),
                    onTap: () => onNavigateTab?.call(3), // Alerts tab
                  ),
                  MetricCard(
                    title: 'Exposed Population',
                    value: NumberFormat.compact().format(totalPopulationAtRisk),
                    subtitle: 'Along vulnerable corridors',
                    icon: Icons.groups_outlined,
                    iconColor: AppColors.riskModerate,
                    backgroundColor: AppColors.riskModeratePastel.withAlpha(100),
                    onTap: () => onNavigateNamed?.call('risk_details'),
                  ),
                  MetricCard(
                    title: 'Blocked Roads',
                    value: '$blockedRoadsCount',
                    subtitle: 'NH-415 Arterial Alert',
                    icon: Icons.no_transfer,
                    iconColor: AppColors.primary,
                    backgroundColor: AppColors.primaryPastel.withAlpha(120),
                    onTap: () => onNavigateNamed?.call('risk_routing'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3. Regional Risk Status Pastel Card with Sparkline matching wireframe
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.riskHighPastel.withAlpha(160),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.riskHighBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Regional Risk Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        RiskBadge(
                          riskLevel: riskResult?.riskLevel ?? RiskLevel.high,
                          isCompact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${riskResult?.riskScore.toInt() ?? 86}',
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            color: AppColors.riskHigh,
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.teal.withAlpha(80)),
                              ),
                              child: Text(
                                'Confidence: ${((riskResult?.confidence ?? 0.93) * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Risk trend',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: AppColors.riskHigh,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Sparkline Trend
                    const RiskTrendSparkline(
                      values: [28, 32, 45, 68, 74, 86],
                      lineColor: AppColors.riskHigh,
                      height: 48,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => onNavigateNamed?.call('risk_details'),
                          icon: const Icon(Icons.analytics_outlined, size: 14),
                          label: const Text('View Risk Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => onNavigateNamed?.call('risk_routing'),
                          icon: const Icon(Icons.alt_route, size: 14),
                          label: const Text('Get Safe Route', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Priority Locations Ranked Section matching wireframe
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Priority Locations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateNamed?.call('priority_queue'),
                    child: const Text('View All Queue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Top 3 Priority Items
              ...priorityItems.take(3).map((item) {
                return PriorityCard(
                  item: item,
                  onSelectLocation: () {
                    appState.selectLocation(item.locationId);
                    onNavigateTab?.call(1); // Map tab
                  },
                  onViewAction: () {
                    appState.selectLocation(item.locationId);
                    onNavigateNamed?.call('action_engine');
                  },
                );
              }),

              const SizedBox(height: 16),

              // 5. Quick Workflow Launcher Strip
              const Text(
                'Rapid Action Workflows',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _quickActionChip(
                      icon: Icons.camera_alt_outlined,
                      label: 'Report Incident',
                      color: AppColors.accent,
                      bgColor: AppColors.accentPastel,
                      onTap: () => onNavigateNamed?.call('citizen_reporting'),
                    ),
                    const SizedBox(width: 8),
                    _quickActionChip(
                      icon: Icons.verified_user_outlined,
                      label: 'Field Verification',
                      color: AppColors.teal,
                      bgColor: AppColors.tealPastel,
                      onTap: () => onNavigateNamed?.call('field_verification'),
                    ),
                    const SizedBox(width: 8),
                    _quickActionChip(
                      icon: Icons.playlist_add_check,
                      label: 'Action Engine',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryPastel,
                      onTap: () => onNavigateNamed?.call('action_engine'),
                    ),
                    const SizedBox(width: 8),
                    _quickActionChip(
                      icon: Icons.bar_chart_outlined,
                      label: 'Regional Analytics',
                      color: AppColors.riskModerate,
                      bgColor: AppColors.riskModeratePastel,
                      onTap: () => onNavigateNamed?.call('region_analytics'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
