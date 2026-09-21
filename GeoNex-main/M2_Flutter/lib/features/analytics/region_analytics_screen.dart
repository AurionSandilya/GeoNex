import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../state/app_state.dart';
import '../../widgets/chart_widgets.dart';
import '../../widgets/risk_badge.dart';

class RegionAnalyticsScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onBack;

  const RegionAnalyticsScreen({
    super.key,
    required this.appState,
    this.onBack,
  });

  @override
  State<RegionAnalyticsScreen> createState() => _RegionAnalyticsScreenState();
}

class _RegionAnalyticsScreenState extends State<RegionAnalyticsScreen> {
  String _selectedState = 'Arunachal Pradesh';

  @override
  Widget build(BuildContext context) {
    final summaries = widget.appState.districtSummaries;

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Regional Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Region Selector Dropdown matching wireframe (`Region: Arunachal Pradesh ▾`)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Region:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedState,
                      dropdownColor: Colors.white,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      items: const [
                        DropdownMenuItem(value: 'Arunachal Pradesh', child: Text('Arunachal Pradesh')),
                        DropdownMenuItem(value: 'Assam', child: Text('Assam')),
                        DropdownMenuItem(value: 'Meghalaya', child: Text('Meghalaya')),
                        DropdownMenuItem(value: 'Sikkim', child: Text('Sikkim')),
                        DropdownMenuItem(value: 'Nagaland', child: Text('Nagaland')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedState = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 1. Dual Trend Charts matching wireframe (Risk trend & Rainfall trend)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 4),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Risk trend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            Icon(Icons.trending_up, size: 14, color: AppColors.riskHigh),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Peak: 86 (High)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.riskHigh)),
                        SizedBox(height: 10),
                        RiskTrendSparkline(values: [28, 32, 45, 68, 74, 86], height: 50),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 4),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rainfall trend (mm)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Cumulative: 142mm', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        SizedBox(height: 10),
                        MiniBarChart(
                          values: [12, 28, 64, 92, 142],
                          labels: ['D1', 'D2', 'D3', 'D4', 'D5'],
                          height: 50,
                          barColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Incident Activity & Active Alerts Charts matching wireframe
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 4),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Landslide incidents', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('4 Verified Ground Events', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.riskModerate)),
                        SizedBox(height: 10),
                        RiskTrendSparkline(values: [0, 0, 1, 2, 4], lineColor: AppColors.riskModerate, height: 40),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 4),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Response time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('38 Minutes Dispatch', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.teal)),
                        SizedBox(height: 10),
                        RiskTrendSparkline(values: [60, 52, 45, 40, 38], lineColor: AppColors.teal, height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. State / District risk comparison matching wireframe
            const Text(
              'State / District risk comparison',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            ...summaries.map((dist) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x04000000), blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dist.districtName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${dist.stateName} • ${dist.highRiskZonesCount} High Zones • ${dist.activeAlertsCount} Alerts',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    RiskBadge(riskLevel: dist.riskLevel, score: dist.riskScore, isCompact: true),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
