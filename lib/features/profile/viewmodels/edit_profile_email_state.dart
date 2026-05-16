import 'package:medical_rep/core/error/app_failure.dart';

sealed class EditProfileEmailState {
  const EditProfileEmailState();
}

final class EditProfileEmailReady extends EditProfileEmailState {
  const EditProfileEmailReady({this.failure});

  final AppFailure? failure;
}

final class EditProfileEmailSubmitting extends EditProfileEmailState {
  const EditProfileEmailSubmitting();
}

final class EditProfileEmailSuccess extends EditProfileEmailState {
  const EditProfileEmailSuccess({
    required this.email,
    this.pendingConfirmation = false,
  });

  final String email;
  final bool pendingConfirmation;
}
