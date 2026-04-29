abstract class WeeklyPlanState {}

class WeeklyPlanInitial extends WeeklyPlanState {}

// حالة التحديث اللحظي للبيانات
class WeeklyPlanUpdated extends WeeklyPlanState {
  final Map<int, Map<String, dynamic>> weeklyData;
  final int selectedDayIndex;
  final double completionRate;

  WeeklyPlanUpdated({
    required this.weeklyData, 
    required this.selectedDayIndex,
    required this.completionRate,
  });
}

class WeeklyPlanLoading extends WeeklyPlanState {}
class WeeklyPlanSuccess extends WeeklyPlanState {}
class WeeklyPlanError extends WeeklyPlanState {
  final String message;
  WeeklyPlanError(this.message);
}