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
  @override
  Future<void> uploadPlan(List<VisitModel> visits) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User must be logged in");

     
      final List<Map<String, dynamic>> dataToUpload = visits.map((visit) {
        final map = visit.toJson();
        map.remove('id');
        map['user_id'] = user.id;
        return map;
      }).toList();

      await supabase.from('visits').insert(dataToUpload);
      print("Uploaded with Server-side UUIDs");
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }

Stream<List<VisitModel>> getVisitsStream() {
  final user = Supabase.instance.client.auth.currentUser;
  
  return Supabase.instance.client
      .from('visits')
      .stream(primaryKey: ['id'])
      .eq('user_id', user?.id ?? '')
      .map((data) {
        return data.map((json) => VisitModel.fromJson(json)).toList();
      });
}

Future<void> saveVisitsToCache(List<VisitModel> visits) async {
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
        .map((data) {
          List<VisitModel> visits = data.map((json) => VisitModel.fromJson(json)).toList();
          
     
          saveVisitsToCache(visits);
          
          return visits;
        });
  }
}
