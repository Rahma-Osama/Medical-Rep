import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:medical_rep/core/utils/app_failure.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/visit_usecases.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_states.dart';

class VisitFeedbackCubit extends Cubit<VisitFeedbackState> {
  final SubmitVisitFeedbackUseCase _submitVisitFeedback;
  final String visitId;

   DoctorInterestLevel interestLevel = DoctorInterestLevel.medium;
  bool sampleGiven;
  bool followUpRequired = false;
  List<String> attachmentPaths = [];

  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  VisitFeedbackCubit({
    required SubmitVisitFeedbackUseCase submitVisitFeedback,
    required this.visitId,
    required bool prefillSampleGiven,
  })  : _submitVisitFeedback = submitVisitFeedback,
        sampleGiven = prefillSampleGiven,
        super(VisitFeedbackInitial(sampleGiven: prefillSampleGiven));

  // 2. تحديث الحالات (States) مع الحفاظ على قيم الـ Fields
  void setInterestLevel(DoctorInterestLevel level) {
    interestLevel = level;
    _updateInitialState();
  }

  void toggleSample() {
    sampleGiven = !sampleGiven;
    _updateInitialState();
  }

  void toggleFollowUp() {
    followUpRequired = !followUpRequired;
    _updateInitialState();
  }

  void addAttachment(String path) {
    attachmentPaths = List<String>.from(attachmentPaths)..add(path);
    _updateInitialState();
  }

  void removeAttachment(int index) {
    attachmentPaths = List<String>.from(attachmentPaths)..removeAt(index);
    _updateInitialState();
  }

  // ميثود مساعدة لتحديث الـ State ببيانات الـ Fields الحالية
  void _updateInitialState() {
    emit(VisitFeedbackInitial(
      interestLevel: interestLevel,
      sampleGiven: sampleGiven,
      followUpRequired: followUpRequired,
      attachmentPaths: attachmentPaths,
    ));
  }

  Future<void> submitFeedback() async {
    if (!formKey.currentState!.validate()) return;

    // بنخزن البيانات الحالية قبل الانتقال لحالة الـ Loading
    emit(VisitFeedbackLoading());

    final feedback = VisitFeedbackModel(
      visitId: visitId,
      interestLevel: interestLevel,
      sampleGiven: sampleGiven,
      followUpRequired: followUpRequired,
      notes: notesController.text.trim(),
      attachmentPaths: attachmentPaths,
      submittedAt: DateTime.now(),
    );

    final result = await _submitVisitFeedback(feedback);

    result.when(
      success: (_) => emit(VisitFeedbackSuccess()),
      failure: (AppFailure f) => emit(VisitFeedbackFailure(_toUiMessage(f))),
    );
  }

  String _toUiMessage(AppFailure failure) {
    return '${failure.title}: ${failure.message}';
  }

  @override
  Future<void> close() {
    notesController.dispose();
    return super.close();
  }
}