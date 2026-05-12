import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';

abstract class WeeklyPlanState {
  final Map<int, List<VisitEntity>> weeklyData;
  final int selectedDayIndex;
  final VisitEntity tempVisit;
  final double completionRate; // أضفنا نسبة الإنجاز
  final String? error;        // أضفنا رسالة الخطأ

  const WeeklyPlanState({
    required this.weeklyData,
    required this.selectedDayIndex,
    required this.tempVisit,
    this.completionRate = 0.0,
    this.error,
  });
}

// 1. الحالة الابتدائية
class WeeklyPlanInitial extends WeeklyPlanState {
  WeeklyPlanInitial()
      : super(
          weeklyData: {0: [], 1: [], 2: [], 3: [], 4: []},
          selectedDayIndex: 0,
          tempVisit:  VisitEntity(shift: "AM", type: "Single"),
          completionRate: 0.0,
        );
}

// 2. حالة التحديث (العادية أثناء الكتابة)
class WeeklyPlanUpdated extends WeeklyPlanState {
  const WeeklyPlanUpdated({
    required super.weeklyData,
    required super.selectedDayIndex,
    required super.tempVisit,
    super.completionRate,
    super.error,
  });
}

// 3. حالة الرفع (Loading)
class WeeklyPlanLoading extends WeeklyPlanState {
  const WeeklyPlanLoading({
    required super.weeklyData,
    required super.selectedDayIndex,
    required super.tempVisit,
    super.completionRate,
  });
}

// 4. حالة النجاح (Success)
class WeeklyPlanSuccess extends WeeklyPlanState {
  const WeeklyPlanSuccess({
    required super.weeklyData,
    required super.selectedDayIndex,
    required super.tempVisit,
    super.completionRate,
  });
}

// 5. حالة الخطأ (Error)
class WeeklyPlanError extends WeeklyPlanState {
  final String message;
  const WeeklyPlanError(
    this.message, {
    required super.weeklyData,
    required super.selectedDayIndex,
    required super.tempVisit,
    super.completionRate,
  }) : super(error: message);
}