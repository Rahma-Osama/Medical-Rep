import 'package:bloc/bloc.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:medical_rep/features/profile/viewmodels/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;

  ProfileCubit(this._getProfile) : super(ProfileLoading());

  Future<void> load() async {
    emit(ProfileLoading());
    final result = await _getProfile();
    result.when(
      success: (user) => emit(ProfileLoaded(user)),
      onFailure: (AppFailure f) => emit(ProfileError('${f.title}: ${f.message}')),
    );
  }
  
}
