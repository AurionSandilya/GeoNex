import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RiskFactorBar extends StatelessWidget {
  final String label;
  final double value; // 0 to 100
  final String? displayValue;
  final Color? barColor;
  final IconData? icon;

  const RiskFactorBar({
    super.key,
    required this.label,
    required this.value,
    this.displayValue,
    this.barColor,
    this.icon,
  });

  Color _determineColor(double val) {
    if (barColor != null) return barColor!;
    if (val >= 75) return AppColors.riskHigh;
    if (val >= 45) return AppColors.riskModerate;
    return AppColors.riskLow;
  }

  @override
  Widget build(BuildContext context) {
    final color = _determineColor(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                displayValue ?? '${value.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (value / 100.0).clamp(0.02, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
