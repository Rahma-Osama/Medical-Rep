import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/profile/domain/repositories/profile_repository.dart';
import 'package:medical_rep/features/profile/models/update_profile_email_result.dart';

class UpdateProfileEmailUseCase {
  const UpdateProfileEmailUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<UpdateProfileEmailResult>> call(String email) =>
      _repository.updateEmail(email);
}
