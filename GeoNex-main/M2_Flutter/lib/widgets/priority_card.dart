import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/models/priority_item.dart';
import 'risk_badge.dart';

class PriorityCard extends StatelessWidget {
  final PriorityItem item;
  final VoidCallback? onViewAction;
  final VoidCallback? onSelectLocation;

  const PriorityCard({
    super.key,
    required this.item,
    this.onViewAction,
    this.onSelectLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isTopRank = item.rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTopRank ? AppColors.riskHighPastel.withAlpha(120) : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTopRank ? AppColors.riskHighBorder : AppColors.border,
          width: isTopRank ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rank + Location + Risk Score
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.rank == 1
                      ? AppColors.riskHigh
                      : (item.rank == 2 ? AppColors.riskModerate : AppColors.primaryLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${item.rank}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.locationName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${item.district}, ${item.state}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RiskBadge(
                    riskLevel: item.riskLevel,
                    score: item.riskScore,
                    isCompact: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PRIORITY ${item.priorityScore.toInt()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Threat Summary in Pastel Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.primaryThreat,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          // Multi-Factor Mini Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _factorPill('Risk: ${item.riskScore.toInt()}', AppColors.riskHigh, AppColors.riskHighPastel),
              _factorPill('Exposure: ${item.exposureScore.toInt()}', AppColors.riskModerate, AppColors.riskModeratePastel),
              _factorPill('Connectivity: ${item.connectivityScore.toInt()}', AppColors.primary, AppColors.primaryPastel),
              _factorPill('Conf: ${(item.confidence * 100).toInt()}%', AppColors.teal, AppColors.tealPastel),
            ],
          ),

          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSelectLocation,
                  icon: const Icon(Icons.map_outlined, size: 14),
                  label: const Text('View on Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onViewAction,
                  icon: const Icon(Icons.playlist_add_check, size: 14),
                  label: const Text('View Action', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _factorPill(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
