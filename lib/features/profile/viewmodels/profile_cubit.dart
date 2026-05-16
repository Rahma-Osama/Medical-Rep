import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:medical_rep/features/profile/domain/usecases/update_profile_photo_usecase.dart';
import 'package:medical_rep/features/profile/viewmodels/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getProfile, [
    UpdateProfilePhotoUseCase? updateProfilePhoto,
  ])  : _updateProfilePhoto = updateProfilePhoto,
        super(ProfileLoading());

  final GetProfileUseCase _getProfile;
  final UpdateProfilePhotoUseCase? _updateProfilePhoto;

  Future<void> load() async {
    emit(ProfileLoading());
    final result = await _getProfile();
    result.when(
      success: (user) => emit(ProfileLoaded(user)),
      onFailure: (f) => emit(ProfileError(f)),
    );
  }

  /// Uploads a new profile photo. Returns a failure to show in UI, or null on success.
  Future<AppFailure?> uploadPhoto(File imageFile) async {
    final updatePhoto = _updateProfilePhoto;
    final current = state;
    if (updatePhoto == null || current is! ProfileLoaded) return null;

    emit(ProfilePhotoUploading(current.user));
    final result = await updatePhoto(imageFile);
    return result.when(
      success: (user) {
        emit(ProfileLoaded(user));
        return null;
      },
      onFailure: (failure) {
        emit(ProfileLoaded(current.user));
        return failure;
      },
    );
  }
}
