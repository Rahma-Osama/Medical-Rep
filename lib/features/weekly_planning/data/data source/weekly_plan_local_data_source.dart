import 'package:hive/hive.dart';
import '../model/visit_model.dart';

abstract class WeeklyPlanLocalDataSource {
  Future<void> saveDayVisitsLocally(int dayIndex, List<VisitModel> visits);
  Map<int, List<VisitModel>> getCachedVisits();
}

class WeeklyPlanLocalDataSourceImpl implements WeeklyPlanLocalDataSource {
  // 1. بنمرر الـ Box هنا عشان يتبني بيه علطول وميعملش سرعة وسباق
  final Box weeklyBox;
  WeeklyPlanLocalDataSourceImpl({required this.weeklyBox});

  @override
  Future<void> saveDayVisitsLocally(int dayIndex, List<VisitModel> visits) async {
    // 2. بنستخدم الـ weeklyBox الجاهز علطول من غير Hive.box('boxName')
    await weeklyBox.put(dayIndex, visits); 
    print("✅ Saved ${visits.length} visits to Hive for day: $dayIndex");
  }

  @override

  Map<int, List<VisitModel>> getCachedVisits() {
    final Map<int, List<VisitModel>> cachedPlan = {};

    for (var key in weeklyBox.keys) {
      if (key is int) {
        final dynamic rawData = weeklyBox.get(key);
        
        if (rawData != null) {
          // ✅ الطريقة السليمة والمضمونة لتحويل الـ List القادمة من الـ Hive بدون أي تضارب types
          final List<VisitModel> modelsList = (rawData as List)
              .map((item) => item as VisitModel)
              .toList();
              
          cachedPlan[key] = modelsList;
        }
      }
    }
    return cachedPlan;
  }
}