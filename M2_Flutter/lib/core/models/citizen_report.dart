import '../constants/app_constants.dart';

class CitizenReport {
  final String reportId;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final String mediaPath; // simulated photo/video path or identifier
  final IncidentType incidentType;
  final SeverityLevel severity;
  final String notes;
  final ReportVerificationStatus verificationStatus;
  final String submittedBy;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final bool isOfflineQueued;

  const CitizenReport({
    required this.reportId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.mediaPath,
    required this.incidentType,
    required this.severity,
    required this.notes,
    required this.verificationStatus,
    required this.submittedBy,
    this.verifiedBy,
    this.verifiedAt,
    this.verificationNotes,
    this.isOfflineQueued = false,
  });

  CitizenReport copyWith({
    String? reportId,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? capturedAt,
    String? mediaPath,
    IncidentType? incidentType,
    SeverityLevel? severity,
    String? notes,
    ReportVerificationStatus? verificationStatus,
    String? submittedBy,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? verificationNotes,
    bool? isOfflineQueued,
  }) {
    return CitizenReport(
      reportId: reportId ?? this.reportId,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedAt: capturedAt ?? this.capturedAt,
      mediaPath: mediaPath ?? this.mediaPath,
      incidentType: incidentType ?? this.incidentType,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      submittedBy: submittedBy ?? this.submittedBy,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      isOfflineQueued: isOfflineQueued ?? this.isOfflineQueued,
    );
  }
}
