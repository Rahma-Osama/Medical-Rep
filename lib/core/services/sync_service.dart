import 'package:medical_rep/core/services/connectivity_service.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/visit_local_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/remote/visit_remote_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';

class SyncService {
  final VisitLocalDataSource local;
  final VisitRemoteDataSource remote;
  final ConnectivityService connectivity;

  SyncService({required this.local, required this.remote, required this.connectivity});

  Future<void> syncPendingVisits() async {
    if (!await connectivity.isConnected) return;

    final pending = await local.getPendingFeedbacks();

    for (var item in pending) {
      try {
        // 1. رفع بيانات الـ Feedback
        final feedbackModel = VisitFeedbackModel(
          visitId: item.visitId,
          interestLevel: DoctorInterestLevel.values.firstWhere((e) => e.name == item.interestLevel),
          sampleGiven: item.sampleGiven,
          followUpRequired: item.followUpRequired,
          notes: item.notes,
          submittedAt: item.submittedAt, targetProduct: item.targetProduct??"Product",
        );

        await remote.submitFeedback(feedbackModel);

        // 2. رفع وقت النهاية إذا كان مخزناً في Hive
        if (item.endTime != null) {
          await remote.endVisit(item.visitId, item.endTime!);
        }

        // 3. مسح من Hive بعد النجاح
        await local.markAsSynced(item.visitId);
      } catch (e) {
        print("Failed to sync visit ${item.visitId}: $e");
      }
    }
    await local.deleteSynced();
  }
}