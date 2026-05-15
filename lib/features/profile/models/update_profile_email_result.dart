import 'package:medical_rep/features/profile/models/profile_user.dart';

class UpdateProfileEmailResult {
  const UpdateProfileEmailResult({
    required this.user,
    this.emailChangePendingConfirmation = false,
  });

  final ProfileUser user;
  final bool emailChangePendingConfirmation;
}
