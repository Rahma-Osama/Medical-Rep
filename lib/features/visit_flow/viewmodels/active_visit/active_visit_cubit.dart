import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/end_visit_usecase.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/verify_visit_location_usecase.dart';
import 'package:medical_rep/features/visit_flow/viewmodels/active_visit/active_visit_state.dart';
import '../../models/visit_model.dart';


class ActiveVisitCubit extends Cubit<ActiveVisitState> {
  final VerifyVisitLocationUseCase _verifyVisitLocation;
  final EndVisitUseCase _endVisit;
  final VisitModel visit;

  Timer? _timer;
  final notesController = TextEditingController();

  ActiveVisitCubit({
    required VerifyVisitLocationUseCase verifyVisitLocation,
    required EndVisitUseCase endVisit,
    required this.visit,
  })  : _verifyVisitLocation = verifyVisitLocation,
        _endVisit = endVisit,
        super(ActiveVisitState(tasks: VisitModel.defaultTasks)) {
    _startTimer();
    verifyLocation();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1)));
    });
  }

  Future<void> verifyLocation() async {
    emit(state.copyWith(locationStatus: LocationStatus.verifying));
    final result = await _verifyVisitLocation(visit.location);
    result.when(
      success: (isVerified) {
        emit(state.copyWith(
          locationStatus: isVerified ? LocationStatus.verified : LocationStatus.failed,
        ));
      },
      onFailure: (AppFailure f) {
        emit(state.copyWith(locationStatus: LocationStatus.failed));
        _handleFailureSideEffects(f);
      },
    );
  }

  void toggleTask(String taskId) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == taskId) return task.copyWith(isDone: !task.isDone);
      return task;
    }).toList();
    emit(state.copyWith(tasks: updatedTasks));
  }

  void toggleSample() {
    emit(state.copyWith(sampleGiven: !state.sampleGiven));
  }

  void updateNotes(String value) {
    emit(state.copyWith(notes: value));
  }

  Future<void> endVisit() async {
    emit(state.copyWith(isEndingVisit: true));
    final result = await _endVisit(visit.visitId, DateTime.now());
    emit(state.copyWith(isEndingVisit: false));
    result.when(
      success: (_) {},
      onFailure: _handleFailureSideEffects,
    );
  }

  void _handleFailureSideEffects(AppFailure failure) {
    // Intentionally minimal: keep cubit pure-ish.
    // If requiresReAuth, you can emit a dedicated state to trigger navigation.
    // For now, do nothing.
  }

  String get formattedTime {
    final h = state.elapsed.inHours.toString().padLeft(2, '0');
    final m = (state.elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (state.elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    notesController.dispose();
    return super.close();
  }
}