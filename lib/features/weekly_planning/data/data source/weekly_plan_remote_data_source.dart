import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/visit_model.dart';

abstract class WeeklyPlanRemoteDataSource {
  Future<void> uploadPlan(List<VisitModel> visits);
  Stream<List<VisitModel>> getVisitsWithCache(); // بنضيفها هنا في الـ Interface
  Stream<List<VisitModel>> getVisitsStream();
}

class WeeklyPlanRemoteDataSourceImpl implements WeeklyPlanRemoteDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<void> uploadPlan(List<VisitModel> visits) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User must be logged in to upload a plan.");
      }

      final List<Map<String, dynamic>> dataToUpload = visits.map((visit) {
        final map = visit.toJson();
        map['user_id'] = user.id;
        return map;
      }).toList();

      await supabase.from('visits').insert(dataToUpload);
      print("✅ All visits uploaded successfully!");

    } on PostgrestException catch (error) {
      print("❌ Supabase Error: ${error.message}");
      throw Exception("Database error: ${error.message}");
    } catch (e) {
      print("❌ Unexpected Error: $e");
      throw Exception("An unexpected error occurred.");
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

  Future<void> _saveVisitsToCache(List<VisitModel> visits) async {
    var box = Hive.box<VisitModel>('weekly_visits_box');
    var settingsBox = Hive.box('settings');

    await box.clear();
    await box.addAll(visits);

    await settingsBox.put('last_sync_date', DateTime.now().millisecondsSinceEpoch);
    print("💾 Cache Updated & 5-Day Timer Started!");
  }


  Stream<List<VisitModel>> getVisitsWithCache() {
    final user = supabase.auth.currentUser;

    return supabase
        .from('visits')
        .stream(primaryKey: ['id'])
        .eq('user_id', user?.id ?? '')
        .asyncMap((data) async {
      try {
        List<VisitModel> visits = data.map((json) => VisitModel.fromJson(json)).toList();

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
              final docInfo = doctorsData.cast<Map<String, dynamic>?>().firstWhere(
                    (d) => d?['name'] == visit.doctor,
                orElse: () => null,
              );

              if (docInfo != null) {

                visit.lat = double.tryParse(docInfo['latitude'].toString());
                visit.long = double.tryParse(docInfo['longitude'].toString());

                debugPrint("Linked: ${visit.doctor} at (${visit.lat}, ${visit.long})");
              }
            }
          } catch (e) {
            debugPrint("Error during doctors join: $e");
          }
        }

        // 4. تحديث الكاش بالبيانات الكاملة
        await _saveVisitsToCache(visits);

        return visits;
      } catch (e) {
        print("❌ Critical Error: $e");
        return [];
      }
    });
  }}