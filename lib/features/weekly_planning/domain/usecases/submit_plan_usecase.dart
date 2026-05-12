import 'package:medical_rep/features/weekly_planning/domain/repositories/weekly_plan_repository.dart';



class SubmitPlanUseCase {
  final WeeklyPlanRepository repository;
  SubmitPlanUseCase(this.repository);

  Future<void> call() async {
    return await repository.submitFullPlan();
  }
}