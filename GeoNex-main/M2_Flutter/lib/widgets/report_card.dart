import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/models/citizen_report.dart';

class ReportCard extends StatelessWidget {
  final CitizenReport report;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;
  final VoidCallback? onEscalate;
  final bool showFieldOfficerActions;

  const ReportCard({
    super.key,
    required this.report,
    this.onVerify,
    this.onReject,
    this.onEscalate,
    this.showFieldOfficerActions = false,
  });

  Color _statusColor(ReportVerificationStatus status) {
    switch (status) {
      case ReportVerificationStatus.draft:
      case ReportVerificationStatus.pendingUpload:
        return AppColors.textMuted;
      case ReportVerificationStatus.uploaded:
        return AppColors.statusPending;
      case ReportVerificationStatus.verified:
        return AppColors.teal;
      case ReportVerificationStatus.rejected:
        return AppColors.statusRejected;
      case ReportVerificationStatus.escalated:
        return AppColors.riskCritical;
    }
  }

  Color _statusPastelBg(ReportVerificationStatus status) {
    switch (status) {
      case ReportVerificationStatus.draft:
      case ReportVerificationStatus.pendingUpload:
        return AppColors.surfaceElevated;
      case ReportVerificationStatus.uploaded:
        return AppColors.riskModeratePastel;
      case ReportVerificationStatus.verified:
        return AppColors.tealPastel;
      case ReportVerificationStatus.rejected:
        return const Color(0xFFF1F5F9);
      case ReportVerificationStatus.escalated:
        return AppColors.riskCriticalPastel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('dd MMM yyyy • HH:mm').format(report.capturedAt);
    final statusColor = _statusColor(report.verificationStatus);
    final statusBg = _statusPastelBg(report.verificationStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: report.verificationStatus == ReportVerificationStatus.verified
              ? AppColors.riskLowBorder
              : AppColors.border,
          width: 1.2,
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
          // Header: Report ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPastel,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primary.withAlpha(60)),
                    ),
                    child: Text(
                      '#${report.reportId}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    report.incidentType.displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withAlpha(80)),
                ),
                child: Text(
                  report.verificationStatus.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Location & GPS
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report.locationName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'GPS: ${report.latitude.toStringAsFixed(4)}°N, ${report.longitude.toStringAsFixed(4)}°E • $timeStr',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),

          const SizedBox(height: 8),
          // Notes
          Text(
            report.notes,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),

          if (report.verificationNotes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.tealPastel,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.riskLowBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, size: 13, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Officer Notes: ${report.verificationNotes!}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (showFieldOfficerActions && report.verificationStatus == ReportVerificationStatus.uploaded) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.riskHigh,
                      side: const BorderSide(color: AppColors.riskHighBorder),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEscalate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.riskModerate,
                      side: const BorderSide(color: AppColors.riskModerateBorder),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Escalate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Verify', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
