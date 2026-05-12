import 'package:medical_rep/core/utils/app_failure.dart';
import 'package:medical_rep/core/utils/result.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/remote/visit_remote_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/domain/reposetries/visit_repo.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource _remote;

  const VisitRepositoryImpl(this._remote);

  @override
  Future<Result<bool, AppFailure>> verifyVisitLocation(String location) async {
    try {
      final isVerified = await _remote.verifyLocation(location);
      return Result.success(isVerified);
    } catch (e) {
      return Result.failure(
        AppFailure(title: 'Location Error', message: e.toString()),
      );
    }
  }

  @override
  Future<Result<void, AppFailure>> endVisit(
      String visitId, DateTime endTime) async {
    try {
      await _remote.endVisit(visitId, endTime);
      return  Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(title: 'End Visit Error', message: e.toString()),
      );
    }
  }

  @override
  Future<Result<void, AppFailure>> submitVisitFeedback(
      VisitFeedbackEntity feedback) async {
    try {
      // Map entity → model before sending to datasource
      final model = VisitFeedbackModel.fromEntity(feedback);
      await _remote.submitFeedback(model);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(title: 'Submit Feedback Error', message: e.toString()),
      );
    }
  }
}