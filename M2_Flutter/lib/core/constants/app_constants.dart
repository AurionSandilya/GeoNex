enum UserRole {
  authority,
  fieldOfficer,
  citizen,
}

enum RiskLevel {
  low,
  moderate,
  high,
  critical,
}

extension RiskLevelExt on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'LOW';
      case RiskLevel.moderate:
        return 'MODERATE';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.critical:
        return 'CRITICAL';
    }
  }
}

enum IncidentType {
  landslide,
  crack,
  rockfall,
  roadBlockage,
  slopeMovement,
  debrisFlow,
  other,
}

extension IncidentTypeExt on IncidentType {
  String get displayName {
    switch (this) {
      case IncidentType.landslide:
        return 'Landslide';
      case IncidentType.crack:
        return 'Ground Crack';
      case IncidentType.rockfall:
        return 'Rockfall';
      case IncidentType.roadBlockage:
        return 'Road Blockage';
      case IncidentType.slopeMovement:
        return 'Slope Movement';
      case IncidentType.debrisFlow:
        return 'Debris Flow';
      case IncidentType.other:
        return 'Other Anomaly';
    }
  }

  /// The exact wire string M3's `ReportType` enum expects
  /// (`app/models/field_report.py`). Previously M2 sent
  /// `incidentType.name.toUpperCase()`, which only worked by coincidence
  /// for LANDSLIDE/CRACK/ROCKFALL/OTHER - three of the seven values had no
  /// match at all (see the integration audit, §3.9, cause 3) and would
  /// have failed M3's schema validation on submit.
  ///
  /// `slopeMovement` has no equivalent value in M3's enum. Mapping it to
  /// `OTHER` (rather than adding a new value to M3's enum) was the smaller,
  /// localized fix - M3's schema is shared with M1/M5 and widening it was
  /// out of scope for this pass. If slope-movement reports turn out to be
  /// common in the field, add a dedicated `SLOPE_MOVEMENT` value to M3's
  /// `ReportType` enum (and its DB migration) instead of leaving it folded
  /// into OTHER indefinitely.
  String get m3WireValue {
    switch (this) {
      case IncidentType.landslide:
        return 'LANDSLIDE';
      case IncidentType.crack:
        return 'CRACK';
      case IncidentType.rockfall:
        return 'ROCKFALL';
      case IncidentType.roadBlockage:
        return 'ROAD_DAMAGE';
      case IncidentType.slopeMovement:
        return 'OTHER';
      case IncidentType.debrisFlow:
        return 'DEBRIS';
      case IncidentType.other:
        return 'OTHER';
    }
  }
}

enum SeverityLevel {
  low,
  medium,
  high,
  critical,
}

extension SeverityLevelExt on SeverityLevel {
  String get displayName {
    switch (this) {
      case SeverityLevel.low:
        return 'Low';
      case SeverityLevel.medium:
        return 'Medium';
      case SeverityLevel.high:
        return 'High';
      case SeverityLevel.critical:
        return 'Critical';
    }
  }
}

enum ActionType {
  monitor,
  inspect,
  prepare,
  restrict,
  escalate,
}

extension ActionTypeExt on ActionType {
  String get displayName {
    switch (this) {
      case ActionType.monitor:
        return 'Monitor';
      case ActionType.inspect:
        return 'Inspect';
      case ActionType.prepare:
        return 'Prepare';
      case ActionType.restrict:
        return 'Restrict';
      case ActionType.escalate:
        return 'Escalate';
    }
  }
}

enum ActionStatus {
  pending,
  assigned,
  inProgress,
  completed,
}

extension ActionStatusExt on ActionStatus {
  String get displayName {
    switch (this) {
      case ActionStatus.pending:
        return 'Pending';
      case ActionStatus.assigned:
        return 'Assigned';
      case ActionStatus.inProgress:
        return 'In Progress';
      case ActionStatus.completed:
        return 'Completed';
    }
  }
}

enum ReportVerificationStatus {
  draft,
  pendingUpload,
  uploaded,
  verified,
  rejected,
  escalated,
}

enum AlertStatus {
  active,
  resolved,
  expired,
}

enum DeliveryChannel {
  push,
  sms,
  email,
  broadcastSiren,
  capIntegration,
}
