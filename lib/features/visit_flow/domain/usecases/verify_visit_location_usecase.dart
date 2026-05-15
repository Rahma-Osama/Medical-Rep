import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/visit_flow/domain/reposetries/visit_repo.dart';

class VerifyVisitLocationUseCase {
  final VisitRepository _repository;

  const VerifyVisitLocationUseCase(this._repository);

  Future<Result<bool>> call(String clinicLocation) =>
      _repository.verifyVisitLocation(clinicLocation);
}