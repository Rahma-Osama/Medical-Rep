import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/core/services/sync_service.dart';
import 'package:medical_rep/features/visit_flow/domain/reposetries/visit_repo.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/pending_visits/pending_visits_states.dart';

class PendingVisitsCubit extends Cubit<PendingVisitsState> {
  final VisitRepository _repository;
  final SyncService _syncService;

  PendingVisitsCubit({
    required VisitRepository repository,
    required SyncService syncService,
  })  : _repository = repository,
        _syncService = syncService,
        super(const PendingVisitsInitial()) {
    loadPending();
  }

  Future<void> loadPending() async {
    emit(const PendingVisitsLoading());

    final result = await _repository.getPendingFeedbacks();

    result.when(
      success: (items) => emit(PendingVisitsLoaded(items)),
      onFailure: (AppFailure failure)=>emit(PendingVisitsError(failure.message)),
    );
  }

  Future<void> syncNow() async {
    emit(const PendingVisitsSyncing());

    try {
      await _syncService.syncPendingVisits();
      await loadPending();
    } catch (e) {
      emit(PendingVisitsError(e.toString()));
    }
  }
}