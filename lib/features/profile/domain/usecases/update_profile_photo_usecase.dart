import 'dart:io';

import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/profile/domain/repositories/profile_repository.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';

class UpdateProfilePhotoUseCase {
  const UpdateProfilePhotoUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<ProfileUser>> call(File imageFile) =>
      _repository.updateProfilePhoto(imageFile);
}
