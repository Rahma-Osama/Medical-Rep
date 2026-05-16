import 'package:bloc/bloc.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/features/profile/domain/usecases/update_profile_email_usecase.dart';
import 'package:medical_rep/features/profile/viewmodels/edit_profile_email_state.dart';

class EditProfileEmailCubit extends Cubit<EditProfileEmailState> {
  EditProfileEmailCubit(this._updateEmail) : super(const EditProfileEmailReady());

  final UpdateProfileEmailUseCase _updateEmail;

  Future<void> submit(String email) async {
    emit(const EditProfileEmailSubmitting());
    final result = await _updateEmail(email);
    result.when(
      success: (result) => emit(
          EditProfileEmailSuccess(
            email: result.user.email,
            pendingConfirmation: result.emailChangePendingConfirmation,
          ),
        ),
      onFailure: (AppFailure failure) =>
          emit(EditProfileEmailReady(failure: failure)),
    );
  }
}
