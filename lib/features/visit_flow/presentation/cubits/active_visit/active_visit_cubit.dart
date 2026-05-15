import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/visit_usecases.dart';
import 'active_visit_state.dart';

class ActiveVisitCubit extends Cubit<ActiveVisitState> {
  final VerifyVisitLocationUseCase _verifyVisitLocation;
  final EndVisitUseCase _endVisit;
  final VisitEntity visit;

  Timer? _timer;

  DateTime _lastActiveTime = DateTime.now();

  ActiveVisitCubit({
    required VerifyVisitLocationUseCase verifyVisitLocation,
    required EndVisitUseCase endVisit,
    required this.visit,
  })  : _verifyVisitLocation = verifyVisitLocation,
        _endVisit = endVisit,
        super(const ActiveVisitState()) {
    _startTimer();
    verifyLocation();

    _lastActiveTime = visit.startTime;
  }

  // ── TIMER ──
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(tick: state.tick + 1));
    });
  }

  // ── ELAPSED TIME ──
  Duration get elapsed {
    return DateTime.now().difference(_lastActiveTime);
  }

  String get formattedTime {
    final d = elapsed;
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── LOCATION ──
  Future<void> verifyLocation() async {
    emit(state.copyWith(locationStatus: LocationStatus.verifying));

    final result = await _verifyVisitLocation(visit.location);

    result.when(
      success: (isVerified) {
        emit(state.copyWith(
          locationStatus:
          isVerified ? LocationStatus.verified : LocationStatus.failed,
        ));
      },
      // تم حذف الـ Explicit Type (AppFailure) ليتوافق مع الـ Result<T>
      onFailure: (f) {
        emit(state.copyWith(
          locationStatus: LocationStatus.failed,
        ));
      },
    );
  }

  void toggleSample() {
    emit(state.copyWith(sampleGiven: !state.sampleGiven));
  }

  void updateNotes(String value) {
    emit(state.copyWith(notes: value));
  }

  // ── END VISIT ──
  Future<void> endVisit() async {
    emit(state.copyWith(isEndingVisit: true));

    final result = await _endVisit(visit.visitId, DateTime.now());

    result.when(
      success: (_) {
        emit(state.copyWith(isEndingVisit: false, visitEndedSuccessfully: true));
      },
      onFailure: (f) {
        emit(state.copyWith(isEndingVisit: false));
      },
    );
  }

  // ── SAVE SESSION ──
  void saveSession() {
    _lastActiveTime = DateTime.now();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}