import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onViewRisk;
  final VoidCallback? onTakeAction;

  const AlertCard({
    super.key,
    required this.alert,
    this.onViewRisk,
    this.onTakeAction,
  });

  Color _severityColor(SeverityLevel sev) {
    switch (sev) {
      case SeverityLevel.critical:
        return AppColors.riskCritical;
      case SeverityLevel.high:
        return AppColors.riskHigh;
      case SeverityLevel.medium:
        return AppColors.riskModerate;
      case SeverityLevel.low:
        return AppColors.riskLow;
    }
  }

  Color _severityPastelBg(SeverityLevel sev) {
    switch (sev) {
      case SeverityLevel.critical:
        return AppColors.riskCriticalPastel;
      case SeverityLevel.high:
        return AppColors.riskHighPastel;
      case SeverityLevel.medium:
        return AppColors.riskModeratePastel;
      case SeverityLevel.low:
        return AppColors.riskLowPastel;
    }
  }

  Color _severityBorder(SeverityLevel sev) {
    switch (sev) {
      case SeverityLevel.critical:
        return AppColors.riskCriticalBorder;
      case SeverityLevel.high:
        return AppColors.riskHighBorder;
      case SeverityLevel.medium:
        return AppColors.riskModerateBorder;
      case SeverityLevel.low:
        return AppColors.riskLowBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(alert.severity);
    final pastelBg = _severityPastelBg(alert.severity);
    final border = _severityBorder(alert.severity);
    final timeStr = DateFormat('dd MMM • HH:mm').format(alert.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: alert.status == AlertStatus.active ? pastelBg.withAlpha(140) : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alert.status == AlertStatus.active ? border : AppColors.border,
          width: alert.status == AlertStatus.active ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Severity Tag + Region + Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    '${alert.severity.displayName.toUpperCase()} RISK ALERT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                timeStr,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Location Header
          Text(
            alert.locationName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),
          // Message
          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),
          // Causes & Recommendation in Pastel Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, size: 13, color: AppColors.riskModerate),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Causes: ${alert.cause}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined, size: 13, color: AppColors.teal),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Recommended: ${alert.recommendedAction}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          // Notification Channels Icons
          Row(
            children: [
              const Text(
                'Channels: ',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700),
              ),
              ...alert.deliveryChannels.map((c) => _channelIcon(c)),
              const Spacer(),
              if (onViewRisk != null)
                TextButton(
                  onPressed: onViewRisk,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('View Risk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              if (onTakeAction != null)
                ElevatedButton(
                  onPressed: onTakeAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Take Action', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _channelIcon(DeliveryChannel channel) {
    IconData icon;
    switch (channel) {
      case DeliveryChannel.push:
        icon = Icons.notifications_active_outlined;
        break;
      case DeliveryChannel.sms:
        icon = Icons.sms_outlined;
        break;
      case DeliveryChannel.email:
        icon = Icons.mail_outline;
        break;
      case DeliveryChannel.broadcastSiren:
        icon = Icons.campaign_outlined;
        break;
      case DeliveryChannel.capIntegration:
        icon = Icons.hub_outlined;
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Tooltip(
        message: channel.name.toUpperCase(),
        child: Icon(icon, size: 14, color: AppColors.primary),
      ),
    );
  }
}
