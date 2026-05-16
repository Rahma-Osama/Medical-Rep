import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/pending_feedback_entity.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';

abstract class VisitRepository {
  Future<Result<bool>> verifyVisitLocation(String location);

  Future<Result<void>> endVisit(String visitId, DateTime endTime);

  Future<Result<void>> submitVisitFeedback(
      VisitFeedbackEntity feedback, {
        required String doctorName,
        required String clinicName,
        required String targetProduct
      });

  Future<Result<List<PendingFeedbackEntity>>> getPendingFeedbacks();
}