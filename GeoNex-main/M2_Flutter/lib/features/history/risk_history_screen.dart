import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../state/app_state.dart';
import '../../widgets/risk_badge.dart';

class RiskHistoryScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback? onBack;

  const RiskHistoryScreen({
    super.key,
    required this.appState,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final history = appState.regionHistory;
    final selectedLoc = appState.selectedLocation;

    return Scaffold(
      appBar: AppBar(
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
        title: const Text('Risk History'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header matching wireframe (Timeline)
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Historical risk shifts for ${selectedLoc?.name ?? "Papum Pare"}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Timeline Items matching wireframe
            ...history.map((entry) {
              final dateStr = DateFormat('dd MMM yyyy').format(entry.date);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
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
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        RiskBadge(riskLevel: entry.riskLevel, score: entry.riskScore, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Rainfall: ${entry.rainfallMm.toInt()} mm', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Text('Incidents: ${entry.incidentCount}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.notes,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
