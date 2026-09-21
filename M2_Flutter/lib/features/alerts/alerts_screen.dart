import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/alert_model.dart';
import '../../state/app_state.dart';
import '../../widgets/alert_card.dart';

class AlertsScreen extends StatefulWidget {
  final AppState appState;
  final Function(String routeName, {Object? arguments})? onNavigateNamed;

  const AlertsScreen({
    super.key,
    required this.appState,
    this.onNavigateNamed,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _activeTab = 'All';

  List<AlertModel> _getFilteredAlerts() {
    final alerts = widget.appState.alerts;
    if (_activeTab == 'Critical') {
      return alerts.where((a) => a.severity == SeverityLevel.critical).toList();
    } else if (_activeTab == 'High') {
      return alerts.where((a) => a.severity == SeverityLevel.high).toList();
    } else if (_activeTab == 'Medium') {
      return alerts.where((a) => a.severity == SeverityLevel.medium).toList();
    }
    return alerts;
  }

  void _triggerSimulatedAlert() {
    final newAlert = AlertModel(
      alertId: 'alt_${DateTime.now().millisecondsSinceEpoch}',
      locationId: widget.appState.selectedLocationId,
      locationName: widget.appState.selectedLocation?.name ?? 'Papum Pare',
      region: '${widget.appState.selectedLocation?.district ?? "Papum Pare"}, Arunachal Pradesh',
      severity: SeverityLevel.critical,
      title: 'FLASH LANDSLIDE WARNING BROADCAST',
      message: 'Sudden high pore pressure spike detected. Catch-fence displacement reported.',
      cause: 'Heavy Rainfall (142mm), High Soil Moisture (88%)',
      recommendedAction: 'Immediate Field Inspection & Divert Traffic to Route B',
      createdAt: DateTime.now(),
      status: AlertStatus.active,
      deliveryChannels: const [
        DeliveryChannel.push,
        DeliveryChannel.sms,
        DeliveryChannel.email,
        DeliveryChannel.broadcastSiren,
        DeliveryChannel.capIntegration,
      ],
      previousRiskScore: 61,
      currentRiskScore: 86,
    );

    widget.appState.repository.createAlert(newAlert).then((_) {
      widget.appState.loadAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulated Emergency Alert broadcasted across all CAP channels!'),
            backgroundColor: AppColors.riskHigh,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _getFilteredAlerts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency_share_outlined),
            tooltip: 'Simulate Emergency Broadcast',
            onPressed: _triggerSimulatedAlert,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs matching wireframe (`All`, `Critical`, `High`, `Medium`)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                _filterChip('All', widget.appState.alerts.length),
                const SizedBox(width: 8),
                _filterChip('Critical', widget.appState.alerts.where((a) => a.severity == SeverityLevel.critical).length),
                const SizedBox(width: 8),
                _filterChip('High', widget.appState.alerts.where((a) => a.severity == SeverityLevel.high).length),
                const SizedBox(width: 8),
                _filterChip('Medium', widget.appState.alerts.where((a) => a.severity == SeverityLevel.medium).length),
              ],
            ),
          ),

          // Notification Channels summary bar matching wireframe (`Push`, `SMS`, `Email`, `Broadcast`)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceElevated,
            child: Row(
              children: [
                const Text('Notification channels: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                _channelBadge('Push', Icons.notifications_active_outlined),
                _channelBadge('SMS', Icons.sms_outlined),
                _channelBadge('Email', Icons.mail_outline),
                _channelBadge('Broadcast', Icons.campaign_outlined),
              ],
            ),
          ),

          // Alerts List
          Expanded(
            child: alerts.isEmpty
                ? const Center(
                    child: Text('No active alerts in this category.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return AlertCard(
                        alert: alert,
                        onViewRisk: () {
                          widget.appState.selectLocation(alert.locationId);
                          widget.onNavigateNamed?.call('risk_details');
                        },
                        onTakeAction: () {
                          widget.appState.selectLocation(alert.locationId);
                          widget.onNavigateNamed?.call('action_engine');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _channelBadge(String name, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int count) {
    final isSelected = _activeTab == label;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPastel : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
