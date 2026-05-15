import 'package:hive/hive.dart';
import '../model/visit_model.dart';

abstract class WeeklyPlanLocalDataSource {
  Future<void> saveDayVisitsLocally(int dayIndex, List<VisitModel> visits);
  Map<int, List<VisitModel>> getCachedVisits();
}

class WeeklyPlanLocalDataSourceImpl implements WeeklyPlanLocalDataSource {
  final String boxName = 'weekly_plan_box';
  @override
  Future<void> saveDayVisitsLocally(
      int dayIndex, List<VisitModel> visits) async {

    final box = Hive.box(boxName);

    await box.put(dayIndex, visits);
    print(" Saved ${visits.length} visits to Hive for day: $dayIndex");
  }

  @override
  Map<int, List<VisitModel>> getCachedVisits() {

    final box = Hive.box(boxName);
    final Map<int, List<VisitModel>> cachedPlan = {};

    for (var key in box.keys) {
      if (key is int) {
        final dynamic rawData = box.get(key);

        if (rawData != null && rawData is List) {

          cachedPlan[key] = List<VisitModel>.from(rawData);
        }
      }
    }
    return cachedPlan;
  }
}
