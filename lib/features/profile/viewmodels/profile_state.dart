import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';

sealed class ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final ProfileUser user;

  ProfileLoaded(this.user);
}

final class ProfilePhotoUploading extends ProfileState {
  final ProfileUser user;

  ProfilePhotoUploading(this.user);
}

final class ProfileError extends ProfileState {
  final AppFailure failure;

  ProfileError(this.failure);
}
