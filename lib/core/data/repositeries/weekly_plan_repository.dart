import 'package:hive/hive.dart';
import 'package:medical_rep/features/weekly_planning/model/visit_model.dart';

class WeeklyPlanRepository {
  final _box = Hive.box<VisitModel>('weekly_plan_box');

  // حفظ الخطة كاملة
  Future<void> saveLocalPlan(Map<int, VisitModel> plan) async {
    // نمسح القديم ونخزن الجديد
    await _box.clear();
    await _box.putAll(plan);
    print("✅ Hive Success: Saved ${_box.length} days in the box.");
  }

  // جلب الخطة المخزنة
  Map<int, VisitModel> getLocalPlan() {
    final Map<int, VisitModel> plan = {};
    for (var key in _box.keys) {
      plan[key as int] = _box.get(key)!;
    }
    return plan;
  }
}