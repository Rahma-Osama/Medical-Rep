import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';

abstract class WeeklyPlanRepository {
  // ✅ التعديل هنا: غيرنا Model لـ Entity في الـ Return والـ Parameters
  Future<void> saveLocalPlan(Map<int, VisitEntity> weeklyData);
  
  Map<int, VisitEntity> getLocalPlan(); 
  
  Future<void> submitFullPlan();
}