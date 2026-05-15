import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  Future<List<String>> getAreasFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('doctors')
          .select('area_name'); 

      final List data = response as List;
      final List<String> areas = data
          .map((e) => e['area_name']?.toString() ?? "")
          .where((element) => element.isNotEmpty)
          .toSet()
          .toList();

      return areas;
    } catch (e) {
      print("Supabase Error: $e");
      return [];
    }
  }

  @override
  Future<List<String>> getDoctorsByArea(String areaName) async {
    final response = await Supabase.instance.client
        .from('doctors')
        .select('name')
        .eq('area_name', areaName);

    final List data = response as List;
    return data.map((e) => e['name'] as String).toList();
  }

@override
Future<void> saveWeeklyPlan(Map<int, List<VisitEntity>> weeklyData) async {
  try {
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in!");

    final List<Map<String, dynamic>> allVisitsToUpload = [];

    for (var entry in weeklyData.entries) {
      for (var entity in entry.value) {
        // 🔹 بناخد الـ ID من الـ Entity لو موجود
        final String? existingId = entity.visitId; 

        final Map<String, dynamic> visitMap = {
          'user_id': userId,
          'brick': entity.brick,
          'doctor_name': entity.doctor,
          'shift': entity.shift,
          'visit_type': entity.type,
          'visit_date': entity.date,
          'day_name': entity.dayName,
          'status': 'pending',
          'admin_feedback': null,
        };

        // 🔹 لو الزيارة ليها ID (يعني كانت مرفوضة مثلاً)، بنحطه عشان يحصل Update
        if (existingId != null && existingId.length > 10) {
          visitMap['id'] = existingId;
        }

        allVisitsToUpload.add(visitMap);
      }
    }

    if (allVisitsToUpload.isNotEmpty) {
      // 🔹 الـ upsert مع الـ id هو اللي هيحل "unique_visit_idx"
      await Supabase.instance.client
          .from('visits')
          .upsert(allVisitsToUpload, onConflict: 'id');
      
      print("✅ Done! Rejected changed to Pending");
    }
  } catch (e) {
    print("❌ Repository Error: $e");
    rethrow;
  }
}
@override
Map<int, List<VisitEntity>> getLocalPlan() {
  final cachedModelsMap = localDS.getCachedVisits();
  return cachedModelsMap.map((key, modelsList) => MapEntry(
    key,
    modelsList.map((model) => VisitEntity(
      visitId: model.visitId, // 🔹 التعديل الثالث: لازم نرجع الـ ID من الكاش
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
      await remoteDS.uploadPlan(allVisitsToUpload); 
    } else {
      throw Exception("لا توجد بيانات محفوظة لرفعها");
    }
  }

  // 🔹 الميثود دي هي اللي بتخلي الشاشة تتحدث لوحدها (Realtime)
  @override
 @override
Stream<List<VisitModel>> getVisitsWithCache() {
  final String? userId = Supabase.instance.client.auth.currentUser?.id;
  
  return Supabase.instance.client
      .from('visits')
      .stream(primaryKey: ['id']) 
      .eq('user_id', userId ?? '')
      .order('visit_date')
      .map((data) {
        // هنا الداتا بترجع من سوبابيز وفيها كل الكولومز
        return data.map((json) => VisitModel.fromJson(json)).toList();
      });
}
  @override
  Future<void> syncPlanStatusWithServer() async {
    try {
      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('visits')
          .select('visit_date, status, doctor_name')
          .eq('user_id', userId);

      final List dataFromServer = response as List;
      final box = Hive.box<VisitModel>('weekly_visits_box');

      bool isAnyVisitUpdated = false;
      List<VisitModel> cachedVisits = box.values.toList();

      for (var visit in cachedVisits) {
        final match = dataFromServer.firstWhere(
          (serverRow) =>
              serverRow['visit_date'] == visit.date &&
              serverRow['doctor_name'] == visit.doctor,
          orElse: () => null,
        );

        if (match != null && visit.status != match['status']) {
          visit.status = match['status'];
          isAnyVisitUpdated = true;
        }
      }

      if (isAnyVisitUpdated) {
        await box.clear();
        await box.addAll(cachedVisits);
      }
    } catch (e) {
      print("❌ خطأ أثناء المزامنة: $e");
    }
  }
}