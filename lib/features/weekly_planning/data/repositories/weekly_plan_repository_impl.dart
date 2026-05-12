import 'package:hive/hive.dart';
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
Future<void> saveWeeklyPlan(Map<int, List<VisitEntity>> weeklyData) async {
  try {
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in!");

    final List<Map<String, dynamic>> allVisitsToUpload = [];

    // --- الجزء الجديد: الحفظ في الكاش (Hive) ---
    weeklyData.forEach((dayIndex, visits) async {
      // تحويل الـ Entities لـ Models عشان Hive بيفهم الموديل
      final List<VisitModel> modelsList = visits.map((entity) => VisitModel(
        brick: entity.brick,
        doctor: entity.doctor,
        shift: entity.shift,
        type: entity.type,
        notes: entity.notes,
        date: entity.date,
        dayName: entity.dayName,
      )).toList();

      // حفظ كل يوم في الـ Hive Box الخاص به
      await localDS.saveDayVisitsLocally(dayIndex, modelsList);
    });
    // ----------------------------------------

    // تكملة كود الرفع للسيرفر (زي ما هو عندك)
    weeklyData.forEach((dayIndex, visits) {
      for (var visit in visits) {
        allVisitsToUpload.add({
          'user_id': userId,
          'brick': visit.brick,
          'doctor_name': visit.doctor,
          'shift': visit.shift,
          'visit_type': visit.type,
          'visit_date': visit.date,
          'day_name': visit.dayName,
          'status': 'pending', 
        });
      }
    });

    if (allVisitsToUpload.isNotEmpty) {
      await Supabase.instance.client.from('visits').insert(allVisitsToUpload);
    }
    
    print("✅ Plan Saved Locally to Hive and Uploaded to Supabase!");
  } catch (e) {
    print("Repository Error: $e");
    rethrow;
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
      await remoteDS.uploadPlan(allVisitsToUpload); // يرفع للـ visits في سوبا بيز
    } else {
      throw Exception("لا توجد بيانات محفوظة لرفعها");
    }
  }
@override
Future<void> syncPlanStatusWithServer() async {
  try {
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // 1. جلب البيانات من سوبا بيز
    final response = await Supabase.instance.client
        .from('visits')
        .select('visit_date, status, doctor_name')
        .eq('user_id', userId);

    final List dataFromServer = response as List;

    // 2. الوصول لـ Hive
    final box = Hive.box('weekly_plan_box');
    
    // بنلف على كل المفاتيح (الأيام) الموجودة في الهيف
    for (var key in box.keys) {
      if (key is int) {
        // 🔹 هنا بنعرف rawList جوه اللوب عشان نستخدمه
        final dynamic dataFromHive = box.get(key);

        if (dataFromHive is List) {
          // تحويل البيانات لـ List من VisitModel بشكل آمن
          List<VisitModel> dayVisits = List<VisitModel>.from(dataFromHive);
          
          bool isAnyVisitUpdated = false;

          for (var visit in dayVisits) {
            // البحث عن الزيارة المطابقة في البيانات اللي جاية من السيرفر
            final match = dataFromServer.firstWhere(
              (serverRow) => 
                serverRow['visit_date'] == visit.date && 
                serverRow['doctor_name'] == visit.doctor,
              orElse: () => null,
            );
            
            if (match != null) {
              // تحديث الحالة في الموديل المحلي
              visit.status = match['status'];
              isAnyVisitUpdated = true;
            }
          }

          // 3. حفظ القائمة المحدثة في Hive فقط لو حصل تغيير
          if (isAnyVisitUpdated) {
            await box.put(key, dayVisits);
          }
        }
      }
    }
    print(" تم تحديث حالات الخطة في الكاش بنجاح");
  } catch (e) {
    print(" خطأ أثناء المزامنة: $e");
  }
}

}