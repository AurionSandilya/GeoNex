import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;
  final double? score;
  final bool isCompact;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.score,
    this.isCompact = false,
  });

  Color get _badgeColor {
    switch (riskLevel) {
      case RiskLevel.low:
        return AppColors.riskLow;
      case RiskLevel.moderate:
        return AppColors.riskModerate;
      case RiskLevel.high:
        return AppColors.riskHigh;
      case RiskLevel.critical:
        return AppColors.riskCritical;
    }
  }

  Color get _badgePastelBg {
    switch (riskLevel) {
      case RiskLevel.low:
        return AppColors.riskLowPastel;
      case RiskLevel.moderate:
        return AppColors.riskModeratePastel;
      case RiskLevel.high:
        return AppColors.riskHighPastel;
      case RiskLevel.critical:
        return AppColors.riskCriticalPastel;
    }
  }

  Color get _badgeBorder {
    switch (riskLevel) {
      case RiskLevel.low:
        return AppColors.riskLowBorder;
      case RiskLevel.moderate:
        return AppColors.riskModerateBorder;
      case RiskLevel.high:
        return AppColors.riskHighBorder;
      case RiskLevel.critical:
        return AppColors.riskCriticalBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _badgePastelBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _badgeBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _badgeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              riskLevel.displayName,
              style: TextStyle(
                color: _badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            if (score != null) ...[
              const SizedBox(width: 4),
              Text(
                '${score!.toInt()}',
                style: TextStyle(
                  color: _badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ]
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _badgePastelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _badgeBorder, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            riskLevel == RiskLevel.critical || riskLevel == RiskLevel.high
                ? Icons.warning_amber_rounded
                : Icons.shield_outlined,
            color: _badgeColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${riskLevel.displayName} RISK',
            style: TextStyle(
              color: _badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          if (score != null) ...[
            const SizedBox(width: 6),
            Container(
              width: 1,
              height: 12,
              color: _badgeColor.withAlpha(80),
            ),
            const SizedBox(width: 6),
            Text(
              '${score!.toInt()} / 100',
              style: TextStyle(
                color: _badgeColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
