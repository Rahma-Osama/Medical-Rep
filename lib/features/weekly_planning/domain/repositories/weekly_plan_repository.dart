import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';

abstract class WeeklyPlanRepository {
  // توحيد الاسم لـ saveWeeklyPlan
  Future<void> saveWeeklyPlan(Map<int, List<VisitEntity>> weeklyData);
  
  Map<int, List<VisitEntity>> getLocalPlan(); 
  
  Future<void> submitFullPlan();
}