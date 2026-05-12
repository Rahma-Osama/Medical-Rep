import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_local_data_source.dart';
import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_remote_data_source.dart';
import 'package:medical_rep/features/weekly_planning/data/model/visit_model.dart';
import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';
import 'package:medical_rep/features/weekly_planning/domain/repositories/weekly_plan_repository.dart';

class WeeklyPlanRepositoryImpl implements WeeklyPlanRepository {
  final WeeklyPlanLocalDataSource localDS;
  final WeeklyPlanRemoteDataSource remoteDS;

  WeeklyPlanRepositoryImpl({required this.localDS, required this.remoteDS});

  @override
  Future<void> saveWeeklyPlan(Map<int, List<VisitEntity>> weeklyData) async {
    for (var entry in weeklyData.entries) {
      final List<VisitModel> modelsList = entry.value.map((entity) {
        return VisitModel(
          brick: entity.brick,
          doctor: entity.doctor,
          shift: entity.shift,
          type: entity.type,
          notes: entity.notes,
          date: entity.date,
          dayName: entity.dayName,
        );
      }).toList();

      // تأكدي أن localDS لديه دالة تتعامل مع القائمة
      await localDS.saveDayVisitsLocally(entry.key, modelsList);
    }
  }

  @override
  Map<int, List<VisitEntity>> getLocalPlan() {
    final cachedModelsMap = localDS.getCachedVisits();
    return cachedModelsMap.map((key, modelsList) => MapEntry(
          key,
          modelsList.map((model) => VisitEntity(
                brick: model.brick,
                doctor: model.doctor,
                shift: model.shift,
                type: model.type,
                notes: model.notes,
                date: model.date,
                dayName: model.dayName,
              )).toList(),
        ));
  }

  @override
  Future<void> submitFullPlan() async {
    final Map<int, List<VisitModel>> visitsMap = localDS.getCachedVisits();
    if (visitsMap.isNotEmpty) {
      List<VisitModel> allVisitsToUpload = [];
      for (var dayVisits in visitsMap.values) {
        allVisitsToUpload.addAll(dayVisits);
      }
      await remoteDS.uploadPlan(allVisitsToUpload); //
    } else {
      throw Exception("لا توجد بيانات محفوظة لرفعها");
    }
  }
}