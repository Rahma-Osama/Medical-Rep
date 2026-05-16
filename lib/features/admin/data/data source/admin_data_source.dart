// admin_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRemoteDataSource {
  final supabase = Supabase.instance.client;

  // 1️⃣ جلب كل الخطط لكل المناديب
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    try {
      final response = await supabase
          .from('visits')
          .select() 
          .order('visit_date', ascending: true);
          
      // تحويل آمن للـ List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error fetching all plans: $e");
      return [];
    }
  }

  // 2️⃣ تحديث حالة الزيارة مع إضافة ملاحظات الإدمن (مؤمنة بالكامل)
  Future<void> updatePlanStatusWithNotes({
    required String visitId, 
    required String newStatus,
    required String adminNotes,
  }) async {
    try {
      // تحديث البيانات في جدول 'visits' بناءً على الـ 'id' بتاع الزيارة
      final response = await supabase
          .from('visits') 
          .update({
            'status': newStatus, 
            'admin_feedback': adminNotes, 
          })
          .eq('id', visitId) 
          .select();

      if (response == null || (response as List).isEmpty) {
        throw Exception("Visit ID ($visitId) not found in Database.");
      }
      print("✅ Plan Status Updated Successfully for Visit ID: $visitId");
    } catch (e) {
      print("❌ Update Error: $e");
      rethrow;
    }
  }

  // 3️⃣ جلب خطة مندوب معين بناءً على الـ userId (مؤمنة ضد الـ Empty Rows)
  Future<List<Map<String, dynamic>>> getRepresentativePlan(String userId) async {
    try {
      final response = await supabase
          .from('visits')
          .select()
          .eq('user_id', userId)
          .order('visit_date', ascending: true);
          
      // لو الـ Response رجع فاضي (0 rows)، الكود هنا هيرجع لستة فاضية بأمان ومستحيل يضرب كراش
      if (response == null) return [];
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error fetching single rep plan for user ($userId): $e");
      return [];
    }
  }
}