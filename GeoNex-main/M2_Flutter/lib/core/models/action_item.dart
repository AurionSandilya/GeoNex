import '../constants/app_constants.dart';

class ActionItem {
  final String actionId;
  final String locationId;
  final String locationName;
  final String? priorityId;
  final ActionType actionType;
  final String title;
  final String rationale;
  final ActionStatus status;
  final String assignedAuthority;
  final DateTime createdAt;
  final DateTime dueTime;
  final String? executionNotes;

  const ActionItem({
    required this.actionId,
    required this.locationId,
    required this.locationName,
    this.priorityId,
    required this.actionType,
    required this.title,
    required this.rationale,
    required this.status,
    required this.assignedAuthority,
    required this.createdAt,
    required this.dueTime,
    this.executionNotes,
  });

  ActionItem copyWith({
    String? actionId,
    String? locationId,
    String? locationName,
    String? priorityId,
    ActionType? actionType,
    String? title,
    String? rationale,
    ActionStatus? status,
    String? assignedAuthority,
    DateTime? createdAt,
    DateTime? dueTime,
    String? executionNotes,
  }) {
    return ActionItem(
      actionId: actionId ?? this.actionId,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      priorityId: priorityId ?? this.priorityId,
      actionType: actionType ?? this.actionType,
      title: title ?? this.title,
      rationale: rationale ?? this.rationale,
      status: status ?? this.status,
      assignedAuthority: assignedAuthority ?? this.assignedAuthority,
      createdAt: createdAt ?? this.createdAt,
      dueTime: dueTime ?? this.dueTime,
      executionNotes: executionNotes ?? this.executionNotes,
    );
  }
}
