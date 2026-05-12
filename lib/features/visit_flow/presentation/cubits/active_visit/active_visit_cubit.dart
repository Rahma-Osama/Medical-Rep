import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/utils/app_failure.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_task.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/visit_usecases.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_state.dart';

class ActiveVisitCubit extends Cubit<ActiveVisitState> {
  final VerifyVisitLocationUseCase _verifyVisitLocation;
  final EndVisitUseCase _endVisit;
  final VisitEntity visit;

  Timer? _timer;

  ActiveVisitCubit({
    required VerifyVisitLocationUseCase verifyVisitLocation,
    required EndVisitUseCase endVisit,
    required this.visit,
    required List<VisitTaskEntity> initialTasks,
  })  : _verifyVisitLocation = verifyVisitLocation,
        _endVisit = endVisit,
        super(ActiveVisitState()) {
    _startTimer();
    verifyLocation();
  }

  // ── Timer Logic ──────────────────────────────────────────────
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1)));
    });
  }

  String get formattedTime {
    final h = state.elapsed.inHours.toString().padLeft(2, '0');
    final m = (state.elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (state.elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Location Logic (Clean Architecture Way) ──────────────────
  Future<void> verifyLocation() async {
    emit(state.copyWith(locationStatus: LocationStatus.verifying));

    final result = await _verifyVisitLocation(visit.location);

    result.when(
      success: (isVerified) => emit(state.copyWith(
        locationStatus: isVerified ? LocationStatus.verified : LocationStatus.failed,
      )),
      failure: (AppFailure f) {
        emit(state.copyWith(
          locationStatus: LocationStatus.failed,
          errorMessage: f.message,
        ));
      },
    );
  }

  // ── Tasks & Notes Logic
  // void toggleTask(String taskId) {
  //   final updatedTasks = state.tasks.map((task) {
  //     if (task.id == taskId) return task.copyWith(isDone: !task.isDone);
  //     return task;
  //   }).toList();
  //   emit(state.copyWith(tasks: updatedTasks));
  // }

  void toggleSample() {
    emit(state.copyWith(sampleGiven: !state.sampleGiven));
  }

  void updateNotes(String value) {
    emit(state.copyWith(notes: value));
  }

  // ── End Visit Logic (Clean Architecture Way) ─────────────────
  Future<void> endVisit() async {
    emit(state.copyWith(isEndingVisit: true));

    final result = await _endVisit(visit.visitId, DateTime.now());

    result.when(
      success: (_) {
        emit(state.copyWith(
          isEndingVisit: false,
          visitEndedSuccessfully: true,
        ));
      },
      failure: (AppFailure f) {
        emit(state.copyWith(
          isEndingVisit: false,
          errorMessage: f.message,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}