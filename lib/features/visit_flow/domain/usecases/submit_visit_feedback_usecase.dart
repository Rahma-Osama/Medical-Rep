
import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/domain/reposetries/visit_repo.dart';

class SubmitVisitFeedbackUseCase {
  final VisitRepository _repository;
  const SubmitVisitFeedbackUseCase(this._repository);

  Future<Result<void>> call(
      VisitFeedbackEntity feedback, {
        required String doctorName,
        required String clinicName,
      }) =>
      _repository.submitVisitFeedback(
        feedback,
        doctorName: doctorName,
        clinicName: clinicName,
      );
}