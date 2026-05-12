import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/visit_flow/domain/repositories/visit_repository.dart';

class VerifyVisitLocationUseCase {
  final VisitRepository _repository;

  const VerifyVisitLocationUseCase(this._repository);

  Future<Result<bool>> call(String clinicLocation) =>
      _repository.verifyLocation(clinicLocation);
}
