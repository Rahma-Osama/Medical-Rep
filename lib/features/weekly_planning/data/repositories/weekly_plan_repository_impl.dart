import 'package:hive/hive.dart';
import 'package:medical_rep/core/utils/work_week_dates.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // سوبا بيز
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
      // نستخدم اسم الجدول "doctors" كما هو في الصورة
      final response = await Supabase.instance.client
          .from('doctors')
          .select('area_name'); // تأكدي إن الحروف كلها Small في قاعدة البيانات

      final List data = response as List;

      // جربي تطبعي الداتا الخام اللي راجعة عشان تشوفي شكلها
      print("Raw response: $data");

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
    // استخراج أسماء الدكاترة (name)
    return data.map((e) => e['name'] as String).toList();
  }

  // --- جزء الحفظ والرفع (لم يتم تغييره) ---

// في ملف WeeklyPlanRepositoryImpl
  @override
  @override
// استبدلي دالة saveWeeklyPlan في الـ Repository بهذا الكود:
@override
Future<void> saveWeeklyPlan(Map<int, List<VisitEntity>> weeklyData) async {
  try {
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in!");

    final List<Map<String, dynamic>> allVisitsToUpload = [];

    for (var entry in weeklyData.entries) {
      final dayName = WorkWeekDates.planDayNames[entry.key];
      final List<VisitModel> modelsList = entry.value.map((entity) {
        final visitDate = WorkWeekDates.normalizedVisitDate(
          dayName: entity.dayName ?? dayName,
          visitDate: entity.date,
        );
        return VisitModel(
          brick: entity.brick,
          doctor: entity.doctor,
          shift: entity.shift,
          type: entity.type,
          date: visitDate,
          dayName: entity.dayName ?? dayName,
          status: 'pending',
        );
      }).toList();
      
      // 1. حفظ محلي في Hive
      await localDS.saveDayVisitsLocally(entry.key, modelsList);

      // 2. تجهيز البيانات للرفع
      for (var model in modelsList) {
        allVisitsToUpload.add({
          'user_id': userId,
          'brick': model.brick,
          'doctor_name': model.doctor,
          'shift': model.shift,
          'visit_type': model.type,
          'visit_date': model.date,
          'day_name': model.dayName,
          'status': 'pending',
        });
      }
    }

    // 3. Remove stale / mis-dated pending rows before upload.
    final today = WorkWeekDates.isoDate(DateTime.now());
    await Supabase.instance.client
        .from('visits')
        .delete()
        .eq('user_id', userId)
        .eq('visit_date', today)
        .eq('status', 'pending')
        .inFilter('day_name', WorkWeekDates.planDayNames);

    final weekRange = WorkWeekDates.plannedWeekRange();
    await Supabase.instance.client
        .from('visits')
        .delete()
        .eq('user_id', userId)
        .gte('visit_date', weekRange.$1)
        .lte('visit_date', weekRange.$2)
        .eq('status', 'pending');

    // 4. Upsert the corrected plan.
    if (allVisitsToUpload.isNotEmpty) {
      await Supabase.instance.client.from('visits').upsert(
            allVisitsToUpload,
            onConflict: 'user_id, visit_date, doctor_name',
          );
      print("✅ Plan synced with Supabase (Upserted)");
    }
  } catch (e) {
    print("❌ Repository Error: $e");
    rethrow;
  }
}

  @override
  Map<int, List<VisitEntity>> getLocalPlan() {
    final cachedModelsMap = localDS.getCachedVisits();
    return cachedModelsMap.map((key, modelsList) {
      final dayName = WorkWeekDates.planDayNames[key];
      return MapEntry(
        key,
        modelsList
            .map(
              (model) => VisitEntity(
                brick: model.brick,
                doctor: model.doctor,
                shift: model.shift,
                type: model.type,
                notes: model.notes,
                date: WorkWeekDates.normalizedVisitDate(
                  dayName: model.dayName ?? dayName,
                  visitDate: model.date,
                ),
                dayName: model.dayName ?? dayName,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<void> submitFullPlan() async {
    final Map<int, List<VisitModel>> visitsMap = localDS.getCachedVisits();
    if (visitsMap.isNotEmpty) {
      List<VisitModel> allVisitsToUpload = [];
      for (var dayVisits in visitsMap.values) {
        allVisitsToUpload.addAll(dayVisits);
      }
      await remoteDS
          .uploadPlan(allVisitsToUpload); // يرفع للـ visits في سوبا بيز
    } else {
      throw Exception("لا توجد بيانات محفوظة لرفعها");
    }
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

      // 🔹 تعديل هنا: استخدمي بوكس 'weekly_visits_box' الموحد
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

      // إعادة حفظ الحالات المحدثة لو حصل تغيير
      if (isAnyVisitUpdated) {
        await box.clear();
        await box.addAll(cachedVisits);
        print("🔄 تم تحديث حالات الخطة في الكاش الموحد بنجاح");
      }
    } catch (e) {
      print("❌ خطأ أثناء المزامنة: $e");
    }
  }
}
