import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/visit_model.dart';


abstract class WeeklyPlanRemoteDataSource {
  Future<void> uploadPlan(List<VisitModel> visits);
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

      await supabase
          .from('visits')
          .insert(dataToUpload);

      print(" All visits uploaded successfully!");
      
    } on PostgrestException catch (error) {
      print(" Supabase Error: ${error.message}");
      throw Exception("Database error: ${error.message}");
    } catch (e) {
      print(" Unexpected Error: $e");
      throw Exception("An unexpected error occurred.");
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