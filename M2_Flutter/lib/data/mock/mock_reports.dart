import '../../core/constants/app_constants.dart';
import '../../core/models/citizen_report.dart';

class MockReportsData {
  static List<CitizenReport> getInitialReports() {
    return [
      CitizenReport(
        reportId: 'NER-1042',
        locationName: 'Papum Pare (NH-415 Ch 14+200)',
        latitude: 27.1485,
        longitude: 93.6982,
        capturedAt: DateTime.now().subtract(const Duration(minutes: 35)),
        mediaPath: 'assets/reports/landslide_nh415.jpg',
        incidentType: IncidentType.slopeMovement,
        severity: SeverityLevel.high,
        notes: 'Significant tension crack observed on upper cut-slope. Stones rolling down onto northbound lane.',
        verificationStatus: ReportVerificationStatus.uploaded,
        submittedBy: 'Citizen Reporter (Taba N.)',
      ),
      CitizenReport(
        reportId: 'NER-1041',
        locationName: 'Doimukh River Bank Road',
        latitude: 27.1430,
        longitude: 93.6935,
        capturedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        mediaPath: 'assets/reports/culvert_overflow.jpg',
        incidentType: IncidentType.roadBlockage,
        severity: SeverityLevel.critical,
        notes: 'Culvert clogged with mud and timber debris. Water overflowing across 50m of tarmac.',
        verificationStatus: ReportVerificationStatus.verified,
        submittedBy: 'Village Headman (K. Riba)',
        verifiedBy: 'Field Officer Inspector Tayeng',
        verifiedAt: DateTime.now().subtract(const Duration(hours: 1)),
        verificationNotes: 'Ground inspection confirmed full road cut blockage. JCB excavator dispatched.',
      ),
      CitizenReport(
        reportId: 'NER-1040',
        locationName: 'Tawang Sela Pass Approach',
        latitude: 27.5830,
        longitude: 91.8610,
        capturedAt: DateTime.now().subtract(const Duration(hours: 4)),
        mediaPath: 'assets/reports/scree_slide.jpg',
        incidentType: IncidentType.rockfall,
        severity: SeverityLevel.high,
        notes: 'Medium boulders fallen across protective catch-net. Single lane traffic moving slowly.',
        verificationStatus: ReportVerificationStatus.verified,
        submittedBy: 'Tourist Taxi Driver',
        verifiedBy: 'BRO Field Inspector Dorjee',
        verifiedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        verificationNotes: 'Debris confirmed. Warning signs erected.',
      ),
      CitizenReport(
        reportId: 'NER-1039',
        locationName: 'Mawkdok Bridge Pier Slope',
        latitude: 25.3480,
        longitude: 91.7480,
        capturedAt: DateTime.now().subtract(const Duration(hours: 6)),
        mediaPath: 'assets/reports/gorge_seepage.jpg',
        incidentType: IncidentType.crack,
        severity: SeverityLevel.medium,
        notes: 'Minor ground cracks near viewpoint railing.',
        verificationStatus: ReportVerificationStatus.uploaded,
        submittedBy: 'Local Tour Guide',
      ),
    ];
  }
}
