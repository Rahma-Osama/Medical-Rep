import 'package:medical_rep/features/visit_flow/domain/entities/pending_feedback_entity.dart';

abstract class PendingVisitsState {
  const PendingVisitsState();
}

class PendingVisitsInitial extends PendingVisitsState {
  const PendingVisitsInitial();
}

class PendingVisitsLoading extends PendingVisitsState {
  const PendingVisitsLoading();
}

class PendingVisitsSyncing extends PendingVisitsState {
  const PendingVisitsSyncing();
}

class PendingVisitsLoaded extends PendingVisitsState {
  final List<PendingFeedbackEntity> items;
  const PendingVisitsLoaded(this.items);
}

class PendingVisitsError extends PendingVisitsState {
  final String message;
  const PendingVisitsError(this.message);
}