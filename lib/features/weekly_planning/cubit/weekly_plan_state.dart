import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';

abstract class WeeklyPlanState {}

class WeeklyPlanInitial extends WeeklyPlanState {}

class WeeklyPlanLoading extends WeeklyPlanState {}

class WeeklyPlanUpdated extends WeeklyPlanState {
  // التعديل: الخريطة الآن تحتوي على قائمة زيارات لكل يوم
  final Map<int, List<VisitEntity>> weeklyData;
  final int selectedDayIndex;
  final double completionRate;
  final VisitEntity tempVisit; // لعرض الاختيارات الحالية في الـ Dropdowns

  WeeklyPlanUpdated({
    required this.weeklyData,
    required this.selectedDayIndex,
    required this.completionRate,
    required this.tempVisit,
  });
}

class WeeklyPlanSuccess extends WeeklyPlanState {}

class WeeklyPlanError extends WeeklyPlanState {
  final String message;
  WeeklyPlanError(this.message);
}