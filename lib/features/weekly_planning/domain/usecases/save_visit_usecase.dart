import 'package:medical_rep/features/weekly_planning/domain/repositories/weekly_plan_repository.dart';

import '../entities/visit_entity.dart';


class SaveVisitUseCase {
  final WeeklyPlanRepository repository;

  SaveVisitUseCase(this.repository);

  // التعديل: بدل ما بنبعت يوم واحد، بنبعت الـ Map كاملة للـ Repo
  Future<void> call(Map<int, VisitEntity> weeklyData) async {
    return await repository.saveLocalPlan(weeklyData);
  }
}