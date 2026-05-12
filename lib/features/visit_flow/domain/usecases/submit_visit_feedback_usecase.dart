import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/visit_flow/domain/repositories/visit_repository.dart';
import 'package:medical_rep/features/visit_flow/models/visit_feedback_model.dart';

class SubmitVisitFeedbackUseCase {
  final VisitRepository _repository;

  const SubmitVisitFeedbackUseCase(this._repository);

  Future<Result<void>> call(VisitFeedbackModel feedback) =>
      _repository.submitFeedback(feedback);
}
