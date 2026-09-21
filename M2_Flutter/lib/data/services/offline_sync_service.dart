import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../core/models/citizen_report.dart';
import '../repositories/risk_repository.dart';

enum SyncStatus {
  idle,
  syncing,
  synced,
  offline,
}

class OfflineSyncService {
  final RiskRepository _repository;
  final List<CitizenReport> _offlineQueue = [];
  bool _isOnline = true;
  SyncStatus _syncStatus = SyncStatus.idle;

  final _statusController = StreamController<SyncStatus>.broadcast();
  final _queueController = StreamController<List<CitizenReport>>.broadcast();

  OfflineSyncService(this._repository);

  bool get isOnline => _isOnline;
  SyncStatus get syncStatus => _syncStatus;
  List<CitizenReport> get offlineQueue => List.unmodifiable(_offlineQueue);
  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<List<CitizenReport>> get queueStream => _queueController.stream;

  void setOnlineStatus(bool online) {
    _isOnline = online;
    if (!online) {
      _syncStatus = SyncStatus.offline;
    } else {
      _syncStatus = SyncStatus.idle;
    }
    _statusController.add(_syncStatus);
  }

  Future<void> enqueueReport(CitizenReport report) async {
    final queuedReport = report.copyWith(
      isOfflineQueued: true,
      verificationStatus: ReportVerificationStatus.pendingUpload,
    );
    _offlineQueue.add(queuedReport);
    _queueController.add(_offlineQueue);

    if (_isOnline) {
      await syncAllPending();
    }
  }

  Future<int> syncAllPending() async {
    if (!_isOnline || _offlineQueue.isEmpty) return 0;

    _syncStatus = SyncStatus.syncing;
    _statusController.add(_syncStatus);

    // Simulate network transmission delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final itemsToSync = List<CitizenReport>.from(_offlineQueue);
    int syncedCount = 0;

    for (final report in itemsToSync) {
      final uploadedReport = report.copyWith(
        isOfflineQueued: false,
        verificationStatus: ReportVerificationStatus.uploaded,
      );
      await _repository.submitReport(uploadedReport);
      _offlineQueue.remove(report);
      syncedCount++;
    }

    _syncStatus = SyncStatus.synced;
    _statusController.add(_syncStatus);
    _queueController.add(_offlineQueue);

    return syncedCount;
  }

  void dispose() {
    _statusController.close();
    _queueController.close();
  }
}
