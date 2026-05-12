import 'package:medical_rep/core/utils/app_failure.dart';
import 'package:medical_rep/core/utils/result.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/domain/reposetries/visit_repo.dart';

// ── 1. Verify location ──────────────────────────────────────
class VerifyVisitLocationUseCase {
  final VisitRepository _repository;
  const VerifyVisitLocationUseCase(this._repository);

  Future<Result<bool, AppFailure>> call(String location) =>
      _repository.verifyVisitLocation(location);
}

// ── 2. End visit ────────────────────────────────────────────
class EndVisitUseCase {
  final VisitRepository _repository;
  const EndVisitUseCase(this._repository);

  Future<Result<void, AppFailure>> call(String visitId, DateTime endTime) =>
      _repository.endVisit(visitId, endTime);
}

// ── 3. Submit feedback ──────────────────────────────────────
class SubmitVisitFeedbackUseCase {
  final VisitRepository _repository;
  const SubmitVisitFeedbackUseCase(this._repository);

  Future<Result<void, AppFailure>> call(VisitFeedbackEntity feedback) =>
      _repository.submitVisitFeedback(feedback);
}