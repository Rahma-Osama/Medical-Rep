import 'package:hive/hive.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/hive_adapters/pending_feedback_hive_model.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';

abstract class VisitLocalDataSource {
  Future<void> savePendingFeedback(
      VisitFeedbackModel feedback, {
        required String doctorName,
        required String clinicName,
      });

  Future<List<PendingFeedbackHiveModel>> getPendingFeedbacks();

  Future<void> markAsSynced(String visitId);

  Future<void> deleteSynced();
}

class VisitLocalDataSourceImpl implements VisitLocalDataSource {
  static const _boxName = 'pending_feedbacks';

  Future<Box<PendingFeedbackHiveModel>> get _box async =>
      Hive.openBox<PendingFeedbackHiveModel>(_boxName);

  @override
  Future<void> savePendingFeedback(
      VisitFeedbackModel feedback, {
        required String doctorName,
        required String clinicName,
      }) async {
    final box = await _box;
    final hiveModel = PendingFeedbackHiveModel(
      visitId: feedback.visitId,
      interestLevel: feedback.interestLevel.name,
      sampleGiven: feedback.sampleGiven,
      followUpRequired: feedback.followUpRequired,
      notes: feedback.notes,
      attachmentPaths: feedback.attachmentPaths,
      submittedAt: feedback.submittedAt,
      doctorName: doctorName,
      clinicName: clinicName,
    );
    // key = visitId عشان نتجنب التكرار
    await box.put(feedback.visitId, hiveModel);
  }

  @override
  Future<List<PendingFeedbackHiveModel>> getPendingFeedbacks() async {
    final box = await _box;
    return box.values.where((e) => !e.isSynced).toList();
  }

  @override
  Future<void> markAsSynced(String visitId) async {
    final box = await _box;
    final entry = box.get(visitId);
    if (entry != null) {
      entry.isSynced = true;
      await entry.save(); // HiveObject.save() يحدث نفسه
    }
  }

  @override
  Future<void> deleteSynced() async {
    final box = await _box;
    final syncedKeys = box.keys
        .where((k) => box.get(k)?.isSynced == true)
        .toList();
    await box.deleteAll(syncedKeys);
  }
}