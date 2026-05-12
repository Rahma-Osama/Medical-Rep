import 'package:medical_rep/core/utils/app_failure.dart';
import 'package:medical_rep/core/utils/result.dart'; // your Result/Either wrapper
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';

abstract class VisitRepository {
  /// Returns true if the device is within accepted range of [location].
  Future<Result<bool, AppFailure>> verifyVisitLocation(String location);

  /// Marks the visit as ended in the backend.
  Future<Result<void, AppFailure>> endVisit(String visitId, DateTime endTime);

  /// Persists the feedback report.
  Future<Result<void, AppFailure>> submitVisitFeedback(VisitFeedbackEntity feedback);
}