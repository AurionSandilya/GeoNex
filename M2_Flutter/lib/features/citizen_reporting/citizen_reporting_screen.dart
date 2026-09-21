import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/citizen_report.dart';
import '../../core/utils/uuid.dart';
import '../../state/app_state.dart';
import '../../widgets/camera_viewfinder_widget.dart';

class CitizenReportingScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onBack;
  final Function(String routeName, {Object? arguments})? onNavigateNamed;

  const CitizenReportingScreen({
    super.key,
    required this.appState,
    this.onBack,
    this.onNavigateNamed,
  });

  @override
  State<CitizenReportingScreen> createState() => _CitizenReportingScreenState();
}

class _CitizenReportingScreenState extends State<CitizenReportingScreen> {
  final TextEditingController _notesController = TextEditingController();
  IncidentType _selectedType = IncidentType.landslide;
  SeverityLevel _selectedSeverity = SeverityLevel.high;
  bool _isVideoMode = false;
  bool _isCaptured = false;
  bool _isSubmitting = false;

  // Auto-captured GPS coordinates (simulated live device lock)
  double _lat = 27.1485;
  double _lng = 93.6982;

  @override
  void initState() {
    super.initState();
    final loc = widget.appState.selectedLocation;
    if (loc != null) {
      _lat = loc.latitude;
      _lng = loc.longitude;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add descriptive notes regarding the hazard.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final report = CitizenReport(
      reportId: generateUuidV4(),
      locationName: '${widget.appState.selectedLocation?.name ?? "Papum Pare"} Corridor',
      latitude: _lat,
      longitude: _lng,
      capturedAt: DateTime.now(),
      mediaPath: 'assets/reports/capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
      incidentType: _selectedType,
      severity: _selectedSeverity,
      notes: _notesController.text.trim(),
      verificationStatus: widget.appState.offlineService.isOnline
          ? ReportVerificationStatus.uploaded
          : ReportVerificationStatus.pendingUpload,
      submittedBy: widget.appState.currentUser.name,
      isOfflineQueued: !widget.appState.offlineService.isOnline,
    );

    await widget.appState.submitCitizenReport(report);

    setState(() => _isSubmitting = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.verified_outlined, color: AppColors.teal),
              SizedBox(width: 8),
              Text('Report Submitted'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.appState.offlineService.isOnline
                    ? 'Report #${report.reportId} successfully uploaded to central disaster dispatch.'
                    : 'Report #${report.reportId} saved locally to Offline Sync Queue (Network Offline).',
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              const Text(
                'Next Step: A Field Officer will verify the attached GPS & visual evidence to update the Risk Engine.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            if (!widget.appState.offlineService.isOnline)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNavigateNamed?.call('offline_queue');
                },
                child: const Text('View Offline Queue'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (widget.onBack != null) widget.onBack!();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Verified Citizen Reporting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_outlined),
            tooltip: 'Offline Queue',
            onPressed: () => widget.onNavigateNamed?.call('offline_queue'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. In-App Camera Viewfinder Simulator matching wireframe
            CameraViewfinderWidget(
              latitude: _lat,
              longitude: _lng,
              locationName: widget.appState.selectedLocation?.name ?? 'Papum Pare',
              isVideoMode: _isVideoMode,
              onModeChanged: (isVid) => setState(() => _isVideoMode = isVid),
              onCapture: () => setState(() => _isCaptured = true),
            ),
            const SizedBox(height: 14),

            // Mode Selector & Capture Trigger
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _isVideoMode = !_isVideoMode),
                  icon: Icon(_isVideoMode ? Icons.photo_camera : Icons.videocam, size: 16),
                  label: Text(_isVideoMode ? 'Switch to Photo' : 'Switch to Video', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isCaptured = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Visual evidence captured & sealed with hardware GPS/timestamp!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_enhance, size: 16),
                  label: const Text('Capture Photo / Video', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Incident Classification matching wireframe
            const Text(
              'Incident Classification',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Incident Type Dropdown
            DropdownButtonFormField<IncidentType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Incident Type',
                prefixIcon: Icon(Icons.category_outlined, size: 18),
              ),
              dropdownColor: Colors.white,
              items: IncidentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                );
              }).toList(),
              onChanged: (newType) {
                if (newType != null) setState(() => _selectedType = newType);
              },
            ),
            const SizedBox(height: 14),

            // Severity Level Dropdown
            DropdownButtonFormField<SeverityLevel>(
              value: _selectedSeverity,
              decoration: const InputDecoration(
                labelText: 'Severity',
                prefixIcon: Icon(Icons.warning_amber_rounded, size: 18),
              ),
              dropdownColor: Colors.white,
              items: SeverityLevel.values.map((sev) {
                return DropdownMenuItem(
                  value: sev,
                  child: Text(sev.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                );
              }).toList(),
              onChanged: (newSev) {
                if (newSev != null) setState(() => _selectedSeverity = newSev);
              },
            ),
            const SizedBox(height: 14),

            // Detailed Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Describe slope movement, cracked pavement, blocked lanes, or exposed structures...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),

            // 3. Auto-attached metadata tags matching wireframe (`✔ GPS Attached`, `✔ Timestamp Attached`, `✔ Verified Capture`)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tealPastel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto-attached metadata',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _metadataPill('✔ GPS Attached (${_lat.toStringAsFixed(3)}°N, ${_lng.toStringAsFixed(3)}°E)'),
                        _metadataPill('✔ Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}'),
                        _metadataPill('✔ Timestamp: ${DateFormat('HH:mm:ss').format(DateTime.now())}'),
                        _metadataPill(_isCaptured ? '✔ Evidence Image Captured (#SEALED)' : '✔ Verified In-App Capture'),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Submit Report Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: _isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _metadataPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.teal.withAlpha(60)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.teal,
        ),
      ),
    );
  }
}
