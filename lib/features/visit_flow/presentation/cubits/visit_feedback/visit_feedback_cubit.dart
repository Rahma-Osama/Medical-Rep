import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/core/error/result.dart'; // تأكدي من صحة المسار
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/visit_usecases.dart'; // تأكدي من المسار الموحد للـ usecases
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_states.dart';

class VisitFeedbackCubit extends Cubit<VisitFeedbackState> {
  final SubmitVisitFeedbackUseCase _submitVisitFeedback;
  final String visitId;
  final String targetProduct;
  final String doctorName;
  final String clinicName;

  VisitFeedbackCubit({
    required SubmitVisitFeedbackUseCase submitVisitFeedback,
    required this.visitId,
    required bool prefillSampleGiven,
    required this.doctorName,
    required this.clinicName,
    required this.targetProduct
  })  : _submitVisitFeedback = submitVisitFeedback,
        super(VisitFeedbackState(sampleGiven: prefillSampleGiven));

  void setInterestLevel(DoctorInterestLevel level) {
    emit(state.copyWith(interestLevel: level));
  }

  void toggleSample() {
    emit(state.copyWith(sampleGiven: !state.sampleGiven));
  }

  void toggleFollowUp() {
    emit(state.copyWith(followUpRequired: !state.followUpRequired));
  }

  void addAttachment(String path) {
    final newList = List<String>.from(state.attachmentPaths)..add(path);
    emit(state.copyWith(attachmentPaths: newList));
  }

  void removeAttachment(int index) {
    final newList = List<String>.from(state.attachmentPaths)..removeAt(index);
    emit(state.copyWith(attachmentPaths: newList));
  }

  Future<void> submitFeedback(String notes) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final feedback = VisitFeedbackModel(
      visitId: visitId,
      interestLevel: state.interestLevel,
      sampleGiven: state.sampleGiven,
      followUpRequired: state.followUpRequired,
      notes: notes.trim(),
      submittedAt: DateTime.now(), targetProduct: targetProduct,
    );

    final result = await _submitVisitFeedback(
      feedback,
      doctorName: doctorName,
      clinicName: clinicName,
      targetProduct: targetProduct
    );

    result.when(
      success: (_) => emit(state.copyWith(isSuccess: true, isLoading: false)),
      onFailure: (f) {
        if (f is NoInternetFailure) {
          emit(state.copyWith(isSuccess: true, isLoading: false));
        } else {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: _toUiMessage(f),
          ));
        }},
    );
  }

  String _toUiMessage(AppFailure failure) => '${failure.title}: ${failure.message}';
}