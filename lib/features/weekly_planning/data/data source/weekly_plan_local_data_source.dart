import 'package:hive/hive.dart';
import '../model/visit_model.dart';

abstract class WeeklyPlanLocalDataSource {
  Future<void> saveVisitLocally(int dayIndex, VisitModel visit);
  Map<int, VisitModel> getCachedVisits();
}

class WeeklyPlanLocalDataSourceImpl implements WeeklyPlanLocalDataSource {
  final String boxName = 'weekly_plan_box'; // نفس اللي في الـ main

  @override
  Future<void> saveVisitLocally(int dayIndex, VisitModel visit) async {
    final box = Hive.box<VisitModel>(boxName);
    await box.put(dayIndex, visit);
  }

  @override
  Map<int, VisitModel> getCachedVisits() {
    final box = Hive.box<VisitModel>(boxName);
    return box.toMap().cast<int, VisitModel>();
  }
}