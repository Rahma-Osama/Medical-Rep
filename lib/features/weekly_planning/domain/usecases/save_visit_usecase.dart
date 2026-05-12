import 'package:medical_rep/features/weekly_planning/domain/repositories/weekly_plan_repository.dart';
import '../entities/visit_entity.dart';

class SaveVisitUseCase {
  final WeeklyPlanRepository repository;

  SaveVisitUseCase(this.repository);

  Future<void> call(Map<int, List<VisitEntity>> weeklyData) async {
    // استدعاء الاسم الجديد الموحد
    return await repository.saveWeeklyPlan(weeklyData);
  }
}