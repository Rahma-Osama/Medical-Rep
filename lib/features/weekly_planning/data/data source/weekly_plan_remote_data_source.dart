import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/visit_model.dart';

abstract class WeeklyPlanRemoteDataSource {
  Future<void> uploadPlan(List<VisitModel> visits);
  Stream<List<VisitModel>> getVisitsWithCache();
  Stream<List<VisitModel>> getVisitsStream();
}

class WeeklyPlanRemoteDataSourceImpl implements WeeklyPlanRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<void> uploadPlan(List<VisitModel> visits) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User must be logged in");

      final List<Map<String, dynamic>> dataToUpload = visits.map((visit) {
        final map = visit.toJson();
        map.remove('id'); // بنشيل الـ ID عشان السيرفر هو اللي يكريته
        map['user_id'] = user.id;
        return map;
      }).toList();

      await supabase.from('visits').insert(dataToUpload);
      debugPrint("Uploaded with Server-side UUIDs");
    } catch (e) {
      debugPrint("Error in uploadPlan: $e");
      rethrow;
    }
  }

  @override
  Stream<List<VisitModel>> getVisitsStream() {
    final user = supabase.auth.currentUser;
    return supabase
        .from('visits')
        .stream(primaryKey: ['id'])
        .eq('user_id', user?.id ?? '')
        .map((data) {
      return data.map((json) => VisitModel.fromJson(json)).toList();
    });
  }

  @override
  Stream<List<VisitModel>> getVisitsWithCache() {
    final user = supabase.auth.currentUser;

    return supabase
        .from('visits')
        .stream(primaryKey: ['id'])
        .eq('user_id', user?.id ?? '')
        .asyncMap((data) async {
      try {
        // 1. تحويل الـ JSON لموديلز
        List<VisitModel> visits = data.map((json) => VisitModel.fromJson(json)).toList();

        // 2. جلب إحداثيات الدكاترة (Join Logic)
        final List<String> doctorNames = visits
            .map((e) => e.doctor ?? "")
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList();

        if (doctorNames.isNotEmpty) {
          try {
            final List<dynamic> doctorsData = await supabase
                .from('doctors')
                .select('name, latitude, longitude')
                .filter('name', 'in', doctorNames);

            for (var visit in visits) {
              // بنجيب أول عنصر يحقق الشرط، ولو مفيش بيرجع null تلقائياً من غير مشاكل Types
              final docInfo = doctorsData.cast<Map<String, dynamic>>().firstWhere(
                    (d) => d['name'] == visit.doctor,
                orElse: () => <String, dynamic>{}, // نرجع Map فاضية بدل Null
              );

              if (docInfo.isNotEmpty) {
                visit.lat = double.tryParse(docInfo['latitude'].toString());
                visit.long = double.tryParse(docInfo['longitude'].toString());
                debugPrint("Linked: ${visit.doctor} at (${visit.lat}, ${visit.long})");
              }
            }
          } catch (e) {
            debugPrint("Error fetching doctors coordinates: $e");
          }
        }

        // 3. تحديث الكاش بالبيانات الكاملة (بما فيها اللوكيشن)
        await _saveVisitsToCache(visits);

        return visits;
      } catch (e) {
        debugPrint("❌ Critical Error in getVisitsWithCache: $e");
        return [];
      }
    });
  }

  // ميثود الكاش خليتها Private ومنظمة أكتر
  Future<void> _saveVisitsToCache(List<VisitModel> visits) async {
    try {
      var box = Hive.box<VisitModel>('weekly_visits_box');
      var settingsBox = Hive.box('settings');

      await box.clear();
      await box.addAll(visits);

      await settingsBox.put('last_sync_date', DateTime.now().millisecondsSinceEpoch);
      debugPrint("💾 Cache Updated & 5-Day Timer Started!");
    } catch (e) {
      debugPrint("Error saving to Hive: $e");
    }
  }
}