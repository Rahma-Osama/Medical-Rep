import 'package:hive/hive.dart';
import 'package:medical_rep/core/utils/work_week_dates.dart';
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
        final dayName = WorkWeekDates.planDayNames[entry.key];
        
        // Convert entities to models (including date normalization and local caching)
        final List<VisitModel> modelsList = entry.value.map((entity) {
          final visitDate = WorkWeekDates.normalizedVisitDate(
            dayName: entity.dayName ?? dayName,
            visitDate: entity.date,
          );
          return VisitModel(
            visitId: entity.visitId, // Preserved from dev2
            brick: entity.brick,
            doctor: entity.doctor,
            shift: entity.shift,
            type: entity.type,
            date: visitDate, // Normalized from home_profile_updates
            dayName: entity.dayName ?? dayName,
            status: 'pending',
          );
        }).toList();
        
        // 1. حفظ محلي في Hive (From home_profile_updates)
        await localDS.saveDayVisitsLocally(entry.key, modelsList);

        // 2. Prepare payload map for remote database (Merging both logics)
        for (var entity in entry.value) {
          final String? existingId = entity.visitId; 
          final visitDate = WorkWeekDates.normalizedVisitDate(
            dayName: entity.dayName ?? dayName,
            visitDate: entity.date,
          );

          final Map<String, dynamic> visitMap = {
            'user_id': userId,
            'brick': entity.brick,
            'doctor_name': entity.doctor,
            'shift': entity.shift,
            'visit_type': entity.type,
            'visit_date': visitDate,
            'day_name': entity.dayName ?? dayName,
            'status': 'pending',
            'admin_feedback': null,
          };

          // If the visit has a valid ID (from dev2 structure), attach it to trigger Update
          if (existingId != null && existingId.length > 10) {
            visitMap['id'] = existingId;
          }

          allVisitsToUpload.add(visitMap);
        }
      }

      // 3. Clean up older misdated pending fields (From home_profile_updates)
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

      // 4. Upsert the corrected plan using fallback keys to protect indices
      if (allVisitsToUpload.isNotEmpty) {
        await Supabase.instance.client.from('visits').upsert(
              allVisitsToUpload,
              onConflict: 'id', // Prioritized ID-based upserts from dev2
            );
        print("✅ Plan synced with Supabase via ID Upsert");
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
                visitId: model.visitId, // Combined: keeps local cache trackable
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
      await remoteDS.uploadPlan(allVisitsToUpload); 
    } else {
      throw Exception("لا توجد بيانات محفوظة لرفعها");
    }
  }

  @override
  Stream<List<VisitModel>> getVisitsWithCache() {
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    
    return Supabase.instance.client
        .from('visits')
        .stream(primaryKey: ['id']) 
        .eq('user_id', userId ?? '')
        .order('visit_date')
        .map((data) {
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