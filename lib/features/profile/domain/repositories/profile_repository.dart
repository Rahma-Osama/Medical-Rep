import 'dart:io';

import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';
import 'package:medical_rep/features/profile/models/update_profile_email_result.dart';

abstract class ProfileRepository {
  Future<Result<ProfileUser>> getCurrentProfile();

  Future<Result<UpdateProfileEmailResult>> updateEmail(String email);

  Future<Result<ProfileUser>> updateProfilePhoto(File imageFile);
}
