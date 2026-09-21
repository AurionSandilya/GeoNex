import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/action_item.dart';
import '../../state/app_state.dart';
import '../../widgets/action_card.dart';
import '../../widgets/risk_badge.dart';

class ActionEngineScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onBack;

  const ActionEngineScreen({
    super.key,
    required this.appState,
    this.onBack,
  });

  @override
  State<ActionEngineScreen> createState() => _ActionEngineScreenState();
}

class _ActionEngineScreenState extends State<ActionEngineScreen> {
  void _addNewActionDialog() {
    final titleCtrl = TextEditingController();
    final rationaleCtrl = TextEditingController();
    ActionType selectedType = ActionType.inspect;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Dispatch Recommended Action', style: TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<ActionType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Action Type'),
                      dropdownColor: Colors.white,
                      items: ActionType.values.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.displayName, style: const TextStyle(fontWeight: FontWeight.w600)));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Action Title / Directives'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rationaleCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Operational Rationale'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty) {
                      final newAction = ActionItem(
                        actionId: 'act_${DateTime.now().millisecondsSinceEpoch}',
                        locationId: widget.appState.selectedLocationId,
                        locationName: widget.appState.selectedLocation?.name ?? 'Papum Pare',
                        actionType: selectedType,
                        title: titleCtrl.text,
                        rationale: rationaleCtrl.text.isNotEmpty ? rationaleCtrl.text : 'Dispatched by Authority command.',
                        status: ActionStatus.assigned,
                        assignedAuthority: widget.appState.currentUser.name,
                        createdAt: DateTime.now(),
                        dueTime: DateTime.now().add(const Duration(hours: 3)),
                      );
                      widget.appState.repository.addAction(newAction).then((_) {
                        widget.appState.loadAllData();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Dispatch'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.appState.selectedLocation;
    final riskResult = location?.calculatedResult;
    final actions = widget.appState.actions;

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Action Engine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Dispatch Action',
            onPressed: _addNewActionDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Header Banner matching wireframe (Papum Pare, Location, Risk: HIGH)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recommended Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            location?.name ?? "Papum Pare",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (riskResult != null)
                    RiskBadge(
                      riskLevel: riskResult.riskLevel,
                      score: riskResult.riskScore,
                      isCompact: true,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Action Protocol Workflow',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Update task status as field operations progress on the ground.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // Actions List
            if (actions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No active actions in queue.'),
                ),
              )
            else
              ...actions.map((act) {
                return ActionCard(
                  action: act,
                  onStatusChanged: (newStatus) {
                    widget.appState.updateActionStatus(act.actionId, newStatus);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Action status updated to: ${newStatus.displayName}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              }),

            const SizedBox(height: 16),

            // Mark Action Complete / Dispatch Action Button matching wireframe
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (actions.isNotEmpty) {
                    widget.appState.updateActionStatus(actions.first.actionId, ActionStatus.completed);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Top action marked as Completed!'),
                        backgroundColor: AppColors.teal,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark Action Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
