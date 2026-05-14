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

  const VisitRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  Future<Result<bool>> verifyVisitLocation(String location) async {
    try {
      final isVerified = await _remote.verifyLocation(location);
      return Success(isVerified);
    } catch (e) {
      return Failure(
        GeneralFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> endVisit(
      String visitId, DateTime endTime) async {
    try {
      await _remote.endVisit(visitId, endTime);
      return const Success(null);
    } catch (e) {
      return Failure(
        GeneralFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> submitVisitFeedback(
      VisitFeedbackEntity feedback, {
        required String doctorName,
        required String clinicName,
      }) async {
    final model = VisitFeedbackModel.fromEntity(feedback);
    final isOnline = await _connectivity.isConnected;

    if (isOnline) {
      try {
        await _remote.submitFeedback(model);
        return const Success(null);
      } catch (e) {
        await _local.savePendingFeedback(
          model,
          doctorName: doctorName,
          clinicName: clinicName,
        );
        // بنرجع NoInternetFailure كـ Failure Object
        return const Failure(NoInternetFailure());
      }
    } else {
      await _local.savePendingFeedback(
        model,
        doctorName: doctorName,
        clinicName: clinicName,
      );
      return const Failure(NoInternetFailure());
    }
  }

  @override
  Future<Result<List<PendingFeedbackEntity>>> getPendingFeedbacks() async {
    try {
      final items = await _local.getPendingFeedbacks();
      final list = items
          .map((e) => PendingFeedbackEntity(
        visitId: e.visitId,
        doctorName: e.doctorName,
        clinicName: e.clinicName,
        submittedAt: e.submittedAt,
      ))
          .toList();
      return Success(list);
    } catch (e) {
      return Failure(
        LocalDbFailure(
            title: 'Local DB Error',
            message: e.toString()
        ),
      );
    }
  }
}