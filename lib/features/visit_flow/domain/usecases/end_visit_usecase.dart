import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/visit_flow/domain/reposetries/visit_repo.dart';

class EndVisitUseCase {
  final VisitRepository _repository;

  const EndVisitUseCase(this._repository);

  Future<Result<void>> call(String visitId, DateTime endTime) =>
      _repository.endVisit(visitId, endTime);
}