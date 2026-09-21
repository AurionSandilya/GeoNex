import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../state/app_state.dart';

class OfflineQueueScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onBack;

  const OfflineQueueScreen({
    super.key,
    required this.appState,
    this.onBack,
  });

  @override
  State<OfflineQueueScreen> createState() => _OfflineQueueScreenState();
}

class _OfflineQueueScreenState extends State<OfflineQueueScreen> {
  bool _isSyncing = false;

  Future<void> _triggerSync() async {
    setState(() => _isSyncing = true);
    final synced = await widget.appState.offlineService.syncAllPending();
    await widget.appState.loadAllData();
    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully synced $synced pending reports with disaster servers!'),
          backgroundColor: AppColors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final offlineService = widget.appState.offlineService;
    final isOnline = offlineService.isOnline;
    final queue = offlineService.offlineQueue;

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Report Sync'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Network Connectivity Simulation Banner matching wireframe
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOnline ? AppColors.tealPastel : AppColors.riskModeratePastel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isOnline ? AppColors.teal.withAlpha(80) : AppColors.riskModerate.withAlpha(80),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 26,
                    color: isOnline ? AppColors.teal : AppColors.riskModerate,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Network status: ${isOnline ? "ONLINE" : "OFFLINE"}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isOnline ? AppColors.teal : AppColors.riskModerate,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOnline
                              ? 'Connected to Disaster Intelligence Server.'
                              : 'Waiting for network to synchronize local reports.',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isOnline,
                    activeColor: AppColors.teal,
                    onChanged: (val) {
                      offlineService.setOnlineStatus(val);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Pending Report Cards matching wireframe
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Local Report Queue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPastel,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${queue.length} Queued',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (queue.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 40, color: AppColors.teal),
                    SizedBox(height: 8),
                    Text(
                      'All local reports are synced!',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No pending uploads in the offline buffer.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...queue.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
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
                          Text(
                            item.locationName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.riskModeratePastel,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Waiting for network',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.riskModerate),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Type: ${item.incidentType.displayName} • Severity: ${item.severity.displayName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          _tag('Photo attached'),
                          _tag('GPS attached'),
                          _tag('Timestamp attached'),
                        ],
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 16),

            // 3. Sync Now Button matching wireframe
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (isOnline && queue.isNotEmpty && !_isSyncing) ? _triggerSync : null,
                icon: _isSyncing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync),
                label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4. Lifecycle Progression Timeline matching wireframe
            const Text(
              'Sync Lifecycle Timeline',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _timelineStep('1. Queued', 'Saved to local SQLite encrypted database on device.', isDone: true),
                  _timelineStep('2. Uploading', 'Transmitting multipart photo/video payload when online.', isDone: isOnline && queue.isEmpty),
                  _timelineStep('3. Uploaded', 'Received by central Supabase / REST dispatch API.', isDone: queue.isEmpty),
                  _timelineStep('4. Verified when network is available', 'Field Officer confirms ground truth.', isDone: false, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '✔ $text',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _timelineStep(String title, String desc, {bool isDone = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isDone ? AppColors.teal : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? AppColors.teal : AppColors.textMuted, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: isDone ? AppColors.teal.withAlpha(80) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDone ? AppColors.teal : AppColors.textPrimary,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              if (!isLast) const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
