import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/priority_item.dart';
import '../../state/app_state.dart';
import '../../widgets/priority_card.dart';

class PriorityQueueScreen extends StatefulWidget {
  final AppState appState;
  final Function(String routeName, {Object? arguments})? onNavigateNamed;
  final VoidCallback? onBack;

  const PriorityQueueScreen({
    super.key,
    required this.appState,
    this.onNavigateNamed,
    this.onBack,
  });

  @override
  State<PriorityQueueScreen> createState() => _PriorityQueueScreenState();
}

class _PriorityQueueScreenState extends State<PriorityQueueScreen> {
  String _activeFilter = 'All';

  List<PriorityItem> _getFilteredItems() {
    final list = widget.appState.priorityQueue;
    if (_activeFilter == 'Critical') {
      return list.where((i) => i.riskLevel == RiskLevel.critical).toList();
    } else if (_activeFilter == 'High') {
      return list.where((i) => i.riskLevel == RiskLevel.high).toList();
    } else if (_activeFilter == 'Medium') {
      return list.where((i) => i.riskLevel == RiskLevel.moderate).toList();
    } else if (_activeFilter == 'Low') {
      return list.where((i) => i.riskLevel == RiskLevel.low).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text('Priority Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Scoring Formula',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Formula: (Risk * 0.35) + (Exposure * 0.30) + (Connectivity * 0.20) + (Confidence * 0.15)'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Filter Tabs Bar matching wireframe (`All`, `Critical`, `High`, `Medium`, `Low`)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', widget.appState.priorityQueue.length),
                  const SizedBox(width: 8),
                  _filterChip('Critical', widget.appState.priorityQueue.where((i) => i.riskLevel == RiskLevel.critical).length),
                  const SizedBox(width: 8),
                  _filterChip('High', widget.appState.priorityQueue.where((i) => i.riskLevel == RiskLevel.high).length),
                  const SizedBox(width: 8),
                  _filterChip('Medium', widget.appState.priorityQueue.where((i) => i.riskLevel == RiskLevel.moderate).length),
                  const SizedBox(width: 8),
                  _filterChip('Low', widget.appState.priorityQueue.where((i) => i.riskLevel == RiskLevel.low).length),
                ],
              ),
            ),
          ),

          // 2. Ranked List of Priority Items
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.task_alt, size: 48, color: AppColors.teal),
                        const SizedBox(height: 12),
                        Text(
                          'No $_activeFilter priority locations at this time.',
                          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return PriorityCard(
                        item: item,
                        onSelectLocation: () {
                          widget.appState.selectLocation(item.locationId);
                          widget.onNavigateNamed?.call('risk_details');
                        },
                        onViewAction: () {
                          widget.appState.selectLocation(item.locationId);
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

  Widget _filterChip(String label, int count) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
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
