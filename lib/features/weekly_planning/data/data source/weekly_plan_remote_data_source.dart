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

      // تحويل كل الـ Models لـ Maps للرفع الجماعي (Bulk Insert)
      final List<Map<String, dynamic>> dataToUpload = visits.map((visit) {
        final map = visit.toJson();
        map['user_id'] = user.id; 
        return map;
      }).toList();

      await supabase
          .from('visits')
          .insert(dataToUpload);

      print("✅ All visits uploaded successfully!");
      
    } on PostgrestException catch (error) {
      print("❌ Supabase Error: ${error.message}");
      throw Exception("Database error: ${error.message}");
    } catch (e) {
      print("❌ Unexpected Error: $e");
      throw Exception("An unexpected error occurred.");
    }
  }
}