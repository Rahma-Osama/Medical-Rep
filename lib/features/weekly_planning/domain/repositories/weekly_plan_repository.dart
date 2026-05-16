import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';

abstract class WeeklyPlanRepository {
  Future<void> saveWeeklyPlan(Map<int, List<VisitEntity>> weeklyData);
// جوه ملف الـ Abstract Class (weekly_plan_repository.dart) عدلي السطر ده:
Future<Map<int, List<VisitEntity>>> getLocalPlan();
  Future<void> submitFullPlan();
  

  Future<List<String>> getAreasFromSupabase();
  Future<List<String>> getDoctorsByArea(String areaName);
  Future<void> syncPlanStatusWithServer();
}