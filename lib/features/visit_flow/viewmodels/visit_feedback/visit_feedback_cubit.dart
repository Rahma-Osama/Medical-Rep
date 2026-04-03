import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:medical_rep/core/data/repositeries/visit_repository.dart';
import 'package:medical_rep/features/visit_flow/models/visit_feedback_model.dart';
import 'package:medical_rep/features/visit_flow/viewmodels/visit_feedback/visit_feedback_states.dart';


class VisitFeedbackCubit extends Cubit<VisitFeedbackState> {
  final VisitRepository _repository;
  final String visitId;
  final bool prefillSampleGiven;

  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  VisitFeedbackCubit({
    required VisitRepository repository,
    required this.visitId,
    required this.prefillSampleGiven,
  })  : _repository = repository,
        super(VisitFeedbackInitial(sampleGiven: prefillSampleGiven));

  VisitFeedbackInitial get _current => state as VisitFeedbackInitial;

  void setInterestLevel(DoctorInterestLevel level) {
    emit(_current.copyWith(interestLevel: level));
  }

  void toggleSample() {
    emit(_current.copyWith(sampleGiven: !_current.sampleGiven));
  }

  void toggleFollowUp() {
    emit(_current.copyWith(followUpRequired: !_current.followUpRequired));
  }

  void addAttachment(String path) {
    final updated = List<String>.from(_current.attachmentPaths)..add(path);
    emit(_current.copyWith(attachmentPaths: updated));
  }

  void removeAttachment(int index) {
    final updated = List<String>.from(_current.attachmentPaths)..removeAt(index);
    emit(_current.copyWith(attachmentPaths: updated));
  }

  Future<void> submitFeedback() async {
    if (!formKey.currentState!.validate()) return;

    final current = _current;
    emit(VisitFeedbackLoading());

    try {
      final feedback = VisitFeedbackModel(
        visitId: visitId,
        interestLevel: current.interestLevel,
        sampleGiven: current.sampleGiven,
        followUpRequired: current.followUpRequired,
        notes: notesController.text.trim(),
        attachmentPaths: current.attachmentPaths,
        submittedAt: DateTime.now(),
      );
      await _repository.submitFeedback(feedback);
      emit(VisitFeedbackSuccess());
    } catch (e) {
      emit(VisitFeedbackFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    notesController.dispose();
    return super.close();
  }
}