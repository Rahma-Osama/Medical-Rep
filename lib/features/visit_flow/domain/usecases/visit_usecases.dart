import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/domain/reposetries/visit_repo.dart';

// ── 1. Verify location ──────────────────────────────────────
class VerifyVisitLocationUseCase {
  final VisitRepository _repository;
  const VerifyVisitLocationUseCase(this._repository);

  Future<Result<bool>> call(String location) =>
      _repository.verifyVisitLocation(location);
}

// ── 2. End visit ────────────────────────────────────────────
class EndVisitUseCase {
  final VisitRepository _repository;
  const EndVisitUseCase(this._repository);

  Future<Result<void>> call(String visitId, DateTime endTime) =>
      _repository.endVisit(visitId, endTime);
}

// ── 3. Submit feedback ──────────────────────────────────────
class SubmitVisitFeedbackUseCase {
  final VisitRepository _repository;
  const SubmitVisitFeedbackUseCase(this._repository);

  Future<Result<void>> call(
      VisitFeedbackEntity feedback, {
        required String doctorName,
        required String clinicName,
        required String targetProduct
      }) =>
      _repository.submitVisitFeedback(
        feedback,
        doctorName: doctorName,
        clinicName: clinicName,
        targetProduct: targetProduct
      );
}