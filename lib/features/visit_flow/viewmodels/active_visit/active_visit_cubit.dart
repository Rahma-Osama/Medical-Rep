import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:medical_rep/core/data/repositeries/visit_repository.dart';
import 'package:medical_rep/features/visit_flow/models/visit_task_model.dart';
import 'package:medical_rep/features/visit_flow/viewmodels/active_visit/active_visit_state.dart';
import '../../models/visit_model.dart';


class ActiveVisitCubit extends Cubit<ActiveVisitState> {
  final VisitRepository _repository;
  final VisitModel visit;

  Timer? _timer;
  final notesController = TextEditingController();

  ActiveVisitCubit({
    required VisitRepository repository,
    required this.visit,
  })  : _repository = repository,
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
    final isVerified = await _repository.verifyLocation(visit.location);
    emit(state.copyWith(
      locationStatus: isVerified ? LocationStatus.verified : LocationStatus.failed,
    ));
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
    await _repository.endVisit(visit.visitId, DateTime.now());
    emit(state.copyWith(isEndingVisit: false));
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