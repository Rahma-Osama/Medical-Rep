import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_local_data_source.dart';
import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_remote_data_source.dart';
import 'package:medical_rep/features/weekly_planning/domain/repositories/weekly_plan_repository.dart';


import '../../domain/entities/visit_entity.dart';

import '../model/visit_model.dart';

class WeeklyPlanRepositoryImpl implements WeeklyPlanRepository {
  final WeeklyPlanLocalDataSource localDS;
  final WeeklyPlanRemoteDataSource remoteDS;

  WeeklyPlanRepositoryImpl({required this.localDS, required this.remoteDS});

  @override
  Future<void> saveLocalPlan(Map<int, VisitEntity> weeklyData) async {
    // بناخد البيانات من الـ UI ونحولها لـ Model عشان نسيفها في Hive
    for (var entry in weeklyData.entries) {
      final model = VisitModel(
        brick: entry.value.brick,
        doctor: entry.value.doctor,
        shift: entry.value.shift,
        type: entry.value.type,
        notes: entry.value.notes,
      );
      await localDS.saveVisitLocally(entry.key, model);
    }
  }

  @override
  Map<int, VisitEntity> getLocalPlan() {
    // بنجيب اللي متسيف في Hive ونحوله لـ Entities عشان الـ UI يعرضه
    final cachedModels = localDS.getCachedVisits();
    return cachedModels.map((key, model) => MapEntry(
      key,
      VisitEntity(
        brick: model.brick,
        doctor: model.doctor,
        shift: model.shift,
        type: model.type,
        notes: model.notes,
      ),
    ));
  }

  @override
  Future<void> submitFullPlan() async {
    // 1. نجيب الداتا المتسيفة في Hive
    final visitsMap = localDS.getCachedVisits();
    
    // 2. نحولها لـ List ونبعتها للـ Remote DataSource عشان تترفع لسوبابيز
    if (visitsMap.isNotEmpty) {
      await remoteDS.uploadPlan(visitsMap.values.toList());
    } else {
      throw Exception("لا توجد بيانات محفوظة لرفعها");
    }
  }
}