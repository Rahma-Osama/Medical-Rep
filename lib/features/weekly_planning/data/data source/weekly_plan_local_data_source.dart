import 'package:hive/hive.dart';
import '../model/visit_model.dart';

abstract class WeeklyPlanLocalDataSource {
  // ✅ التعديل: أصبح يستقبل قائمة موديلات لليوم الواحد
  Future<void> saveDayVisitsLocally(int dayIndex, List<VisitModel> visits);
  
  // ✅ التعديل: أصبح يرجع Map تحتوي على Lists
  Map<int, List<VisitModel>> getCachedVisits();
}

class WeeklyPlanLocalDataSourceImpl implements WeeklyPlanLocalDataSource {
  final String boxName = 'weekly_plan_box';

  @override
  Future<void> saveDayVisitsLocally(int dayIndex, List<VisitModel> visits) async {
    // التعديل: فتح الـ box بنوع dynamic أو List لأننا سنخزن قوائم
    final box = Hive.box(boxName); 
    await box.put(dayIndex, visits);
  }

  @override
  Map<int, List<VisitModel>> getCachedVisits() {
    final box = Hive.box(boxName);
    final Map<int, List<VisitModel>> cachedPlan = {};

    for (var key in box.keys) {
      if (key is int) {
        final List? rawList = box.get(key);
        if (rawList != null) {
          // تحويل القائمة المسترجعة من Hive إلى قائمة من نوع VisitModel
          cachedPlan[key] = List<VisitModel>.from(rawList);
        }
      }
    }
    return cachedPlan;
  }
}