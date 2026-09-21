import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/models/action_item.dart';

class ActionCard extends StatelessWidget {
  final ActionItem action;
  final Function(ActionStatus newStatus)? onStatusChanged;

  const ActionCard({
    super.key,
    required this.action,
    this.onStatusChanged,
  });

  Color _statusColor(ActionStatus status) {
    switch (status) {
      case ActionStatus.pending:
        return AppColors.statusPending;
      case ActionStatus.assigned:
        return AppColors.statusAssigned;
      case ActionStatus.inProgress:
        return AppColors.statusInProgress;
      case ActionStatus.completed:
        return AppColors.statusCompleted;
    }
  }

  Color _statusPastelBg(ActionStatus status) {
    switch (status) {
      case ActionStatus.pending:
        return AppColors.riskModeratePastel;
      case ActionStatus.assigned:
        return AppColors.primaryPastel;
      case ActionStatus.inProgress:
        return AppColors.purplePastel;
      case ActionStatus.completed:
        return AppColors.riskLowPastel;
    }
  }

  Color _typeColor(ActionType type) {
    switch (type) {
      case ActionType.monitor:
        return AppColors.teal;
      case ActionType.inspect:
        return AppColors.primary;
      case ActionType.prepare:
        return AppColors.riskModerate;
      case ActionType.restrict:
        return AppColors.riskHigh;
      case ActionType.escalate:
        return AppColors.riskCritical;
    }
  }

  Color _typePastelBg(ActionType type) {
    switch (type) {
      case ActionType.monitor:
        return AppColors.tealPastel;
      case ActionType.inspect:
        return AppColors.primaryPastel;
      case ActionType.prepare:
        return AppColors.riskModeratePastel;
      case ActionType.restrict:
        return AppColors.riskHighPastel;
      case ActionType.escalate:
        return AppColors.riskCriticalPastel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueStr = DateFormat('dd MMM • HH:mm').format(action.dueTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: action.status == ActionStatus.completed
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
          // Header: Type Tag + Status Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _typePastelBg(action.actionType),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _typeColor(action.actionType).withAlpha(80)),
                ),
                child: Text(
                  action.actionType.displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _typeColor(action.actionType),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _buildStatusDropdown(context),
            ],
          ),

          const SizedBox(height: 10),
          // Title
          Text(
            action.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),
          // Rationale
          Text(
            action.rationale,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),

          if (action.executionNotes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Notes: ${action.executionNotes!}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Footer: Assigned Authority & Due Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    action.assignedAuthority,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Due: $dueStr',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _statusPastelBg(action.status),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _statusColor(action.status).withAlpha(90)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ActionStatus>(
          value: action.status,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: _statusColor(action.status)),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _statusColor(action.status),
          ),
          dropdownColor: Colors.white,
          items: ActionStatus.values.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(
                s.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _statusColor(s),
                ),
              ),
            );
          }).toList(),
          onChanged: (newStatus) {
            if (newStatus != null) {
              onStatusChanged?.call(newStatus);
            }
          },
        ),
      ),
    );
  }
}
