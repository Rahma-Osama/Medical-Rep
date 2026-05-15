import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/core/services/connectivity_service.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/visit_local_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/remote/visit_remote_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/pending_feedback_entity.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/domain/reposetries/visit_repo.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource _remote;
  final VisitLocalDataSource _local;
  final ConnectivityService _connectivity;

  // مخزن مؤقت لوقت النهاية في حال حدوث Offline في شاشة الـ Active Visit
  static DateTime? _cachedOfflineEndTime;

  VisitRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  Future<Result<void>> endVisit(String visitId, DateTime endTime) async {
    final isOnline = await _connectivity.isConnected;

    // دائماً نخزن الوقت محلياً تحسباً لأي انقطاع مفاجئ أثناء الـ Feedback
    _cachedOfflineEndTime = endTime;

    if (isOnline) {
      try {
        await _remote.endVisit(visitId, endTime);
        return const Success(null);
      } catch (e) {
        return const Success(null); // نعتبرها نجاح للمستخدم ليكمل الفلو
      }
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> submitVisitFeedback(
      VisitFeedbackEntity feedback, {
        required String doctorName,
        required String clinicName,
        required String targetProduct
      }) async {
    final model = VisitFeedbackModel.fromEntity(feedback);
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        // 1. رفع الـ Feedback
        await _remote.submitFeedback(model);

        // 2. رفع وقت النهاية إذا كان مخزناً ولم يرفع بعد
        if (_cachedOfflineEndTime != null) {
          await _remote.endVisit(feedback.visitId, _cachedOfflineEndTime!);
          _cachedOfflineEndTime = null;
        }
        return const Success(null);
      } catch (e) {
        // لو فشل الرفع رغم وجود نت، نحفظ في Hive
        await _local.savePendingFeedback(
          model,
          doctorName: doctorName,
          clinicName: clinicName,
          offlineEndTime: _cachedOfflineEndTime, targetProduct: targetProduct,
        );
        _cachedOfflineEndTime = null;
        return const Failure(NoInternetFailure());
      }
    } else {
      // أوفلاين صريح -> حفظ في Hive
      await _local.savePendingFeedback(
        model,
        doctorName: doctorName,
        clinicName: clinicName,
        offlineEndTime: _cachedOfflineEndTime, targetProduct: targetProduct,
      );
      _cachedOfflineEndTime = null;
      return const Failure(NoInternetFailure());
    }
  }

  @override
  Future<Result<List<PendingFeedbackEntity>>> getPendingFeedbacks() async {
    try {
      final items = await _local.getPendingFeedbacks();
      return Success(items.map((e) => PendingFeedbackEntity(
        visitId: e.visitId,
        doctorName: e.doctorName,
        clinicName: e.clinicName,
        submittedAt: e.submittedAt,
      )).toList());
    } catch (e) {
      return Failure(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> verifyVisitLocation(String location) {
    // TODO: implement verifyVisitLocation
    throw UnimplementedError();
  }
}