import 'package:medical_rep/features/visit_flow/models/visit_task_model.dart';


enum LocationStatus { idle, verifying, verified, failed }

class ActiveVisitState {
  final Duration elapsed;
  final LocationStatus locationStatus;
  final List<VisitTaskModel> tasks;
  final bool sampleGiven;
  final String notes;
  final bool isEndingVisit;

  const ActiveVisitState({
    this.elapsed = Duration.zero,
    this.locationStatus = LocationStatus.idle,
    this.tasks = const [],
    this.sampleGiven = false,
    this.notes = '',
    this.isEndingVisit = false,
  });

  ActiveVisitState copyWith({
    Duration? elapsed,
    LocationStatus? locationStatus,
    List<VisitTaskModel>? tasks,
    bool? sampleGiven,
    String? notes,
    bool? isEndingVisit,
  }) {
    return ActiveVisitState(
      elapsed: elapsed ?? this.elapsed,
      locationStatus: locationStatus ?? this.locationStatus,
      tasks: tasks ?? this.tasks,
      sampleGiven: sampleGiven ?? this.sampleGiven,
      notes: notes ?? this.notes,
      isEndingVisit: isEndingVisit ?? this.isEndingVisit,
    );
  }

  int get completedTasks => tasks.where((t) => t!.isDone).length;
  double get taskProgress => tasks.isEmpty ? 0 : completedTasks / tasks.length;
}