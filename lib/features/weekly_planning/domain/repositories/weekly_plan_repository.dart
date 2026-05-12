import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';

abstract class WeeklyPlanRepository {
  Future<void> saveWeeklyPlan(Map<int, List<VisitEntity>> weeklyData);
  Map<int, List<VisitEntity>> getLocalPlan(); 
  Future<void> submitFullPlan();
  
  // الدوال الجديدة اللي هنحتاجها للسوبا بيز
  Future<List<String>> getAreasFromSupabase();
  Future<List<String>> getDoctorsByArea(String areaName);
  Future<void> syncPlanStatusWithServer();
}