import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';

abstract class ProfileRepository {
  Future<Result<ProfileUser>> getCurrentProfile();
}
