import 'dart:async';
import 'package:medical_rep/core/services/connectivity_service.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/hive_adapters/pending_feedback_hive_model.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/visit_local_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/remote/visit_remote_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';

class SyncService {
  final VisitLocalDataSource _local;
  final VisitRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  StreamSubscription? _sub;

  SyncService({
    required VisitLocalDataSource local,
    required VisitRemoteDataSource remote,
    required ConnectivityService connectivity,
  })  : _local = local,
        _remote = remote,
        _connectivity = connectivity;

  /// استدعيه مرة واحدة في main.dart أو في AppBloc
  void startListening() {
    _sub = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) syncPending();
    });
  }

  Future<void> syncPending() async {
    final pending = await _local.getPendingFeedbacks();
    if (pending.isEmpty) return;

    for (final item in pending) {
      try {
        final model = _toModel(item);
        await _remote.submitFeedback(model);
        await _local.markAsSynced(item.visitId);
      } catch (_) {
        // فشل في رفع record معين → نكمل باقي الـ records
        continue;
      }
    }
    // بعد ما خلصنا نمسح اللي اترفع
    await _local.deleteSynced();
  }

  VisitFeedbackModel _toModel(PendingFeedbackHiveModel h) => VisitFeedbackModel(
    visitId: h.visitId,
    interestLevel: DoctorInterestLevel.values.byName(h.interestLevel),
    sampleGiven: h.sampleGiven,
    followUpRequired: h.followUpRequired,
    notes: h.notes,
    attachmentPaths: h.attachmentPaths,
    submittedAt: h.submittedAt,
  );

  void dispose() => _sub?.cancel();
}