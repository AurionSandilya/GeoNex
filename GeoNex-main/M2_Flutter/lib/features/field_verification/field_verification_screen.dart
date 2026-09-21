import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/citizen_report.dart';
import '../../state/app_state.dart';
import '../../widgets/camera_viewfinder_widget.dart';

class FieldVerificationScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onBack;

  const FieldVerificationScreen({
    super.key,
    required this.appState,
    this.onBack,
  });

  @override
  State<FieldVerificationScreen> createState() => _FieldVerificationScreenState();
}

class _FieldVerificationScreenState extends State<FieldVerificationScreen> {
  final TextEditingController _verificationNotesController = TextEditingController();
  CitizenReport? _selectedReport;

  @override
  void initState() {
    super.initState();
    final pending = widget.appState.reports.where((r) => r.verificationStatus == ReportVerificationStatus.uploaded).toList();
    if (pending.isNotEmpty) {
      _selectedReport = pending.first;
    } else if (widget.appState.reports.isNotEmpty) {
      _selectedReport = widget.appState.reports.first;
    }
  }

  @override
  void dispose() {
    _verificationNotesController.dispose();
    super.dispose();
  }

  Future<void> _handleVerificationAction(ReportVerificationStatus status) async {
    if (_selectedReport == null) return;

    final notes = _verificationNotesController.text.trim();
    await widget.appState.verifyFieldReport(
      _selectedReport!.reportId,
      status,
      notes: notes.isNotEmpty ? notes : 'Ground check completed by Field Inspector.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == ReportVerificationStatus.verified
                ? 'Report #${_selectedReport!.reportId} VERIFIED! Risk Engine recalculated & priority queue updated!'
                : 'Report #${_selectedReport!.reportId} status updated to: ${status.name.toUpperCase()}',
          ),
          backgroundColor: status == ReportVerificationStatus.verified ? AppColors.teal : AppColors.riskModerate,
          duration: const Duration(seconds: 4),
        ),
      );
      _verificationNotesController.clear();
      setState(() {
        final pending = widget.appState.reports.where((r) => r.verificationStatus == ReportVerificationStatus.uploaded).toList();
        _selectedReport = pending.isNotEmpty ? pending.first : widget.appState.reports.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingReports = widget.appState.reports.where((r) => r.verificationStatus == ReportVerificationStatus.uploaded).toList();
    final allReports = widget.appState.reports;

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Field Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top feedback loop indicator banner in Pastel Teal
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tealPastel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.autorenew, color: AppColors.teal, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Feedback Loop Active: Verifying an incident dynamically increases localized susceptibility factors and triggers automatic priority recalculations.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedReport != null) ...[
              // Active Report Inspection Card matching wireframe
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Report #${_selectedReport!.reportId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.riskModeratePastel,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.riskModerateBorder),
                          ),
                          child: Text(
                            _selectedReport!.verificationStatus.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.riskModerate,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type: ${_selectedReport!.incidentType.displayName} • Location: ${_selectedReport!.locationName}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Severity: ${_selectedReport!.severity.displayName.toUpperCase()}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.riskHigh),
                    ),
                    const SizedBox(height: 12),

                    // Visual Evidence Camera Preview Frame
                    CameraViewfinderWidget(
                      latitude: _selectedReport!.latitude,
                      longitude: _selectedReport!.longitude,
                      locationName: _selectedReport!.locationName,
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Citizen Notes: "${_selectedReport!.notes}"',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field Officer Notes Input
                    TextField(
                      controller: _verificationNotesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Field Officer Assessment Notes',
                        hintText: 'Confirm soil displacement, road blockage extent, or heavy machinery requirement...',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Verification Action Buttons matching wireframe (`Verify`, `Reject`, `Escalate`)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleVerificationAction(ReportVerificationStatus.rejected),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.riskHigh,
                              side: const BorderSide(color: AppColors.riskHighBorder),
                            ),
                            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleVerificationAction(ReportVerificationStatus.escalated),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.riskModerate,
                              side: const BorderSide(color: AppColors.riskModerateBorder),
                            ),
                            child: const Text('Escalate', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleVerificationAction(ReportVerificationStatus.verified),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                            child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Assigned / Pending Reports Queue
            Text(
              'Pending Verification Queue (${pendingReports.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            ...allReports.map((r) {
              final isSelected = r.reportId == _selectedReport?.reportId;
              return GestureDetector(
                onTap: () => setState(() => _selectedReport = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryPastel : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        r.verificationStatus == ReportVerificationStatus.verified
                            ? Icons.verified
                            : Icons.pending_actions,
                        color: r.verificationStatus == ReportVerificationStatus.verified
                            ? AppColors.teal
                            : AppColors.statusPending,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${r.reportId} • ${r.incidentType.displayName}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(r.locationName, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        r.verificationStatus.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: r.verificationStatus == ReportVerificationStatus.verified
                              ? AppColors.teal
                              : AppColors.statusPending,
                        ),
                      ),
                    ],
                  ),
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
