import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';


abstract class WeeklyPlanState {}

class WeeklyPlanInitial extends WeeklyPlanState {}

class WeeklyPlanLoading extends WeeklyPlanState {}

class WeeklyPlanUpdated extends WeeklyPlanState {
  final Map<int, VisitEntity> weeklyData;
  final int selectedDayIndex;
  final double completionRate;

  WeeklyPlanUpdated({
    required this.weeklyData,
    required this.selectedDayIndex,
    required this.completionRate,
  });
}

class WeeklyPlanSuccess extends WeeklyPlanState {}

class WeeklyPlanError extends WeeklyPlanState {
  final String message;
  WeeklyPlanError(this.message);
}