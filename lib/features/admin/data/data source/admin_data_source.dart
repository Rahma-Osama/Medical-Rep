import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRemoteDataSource {
  final supabase = Supabase.instance.client;

  // 1️⃣ جلب كل الخطط (الزيارات) من جدول الـ visits الفعلي والموجود بالـ سوبابيز
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    try {
      final response = await supabase
          .from('visits')
          .select()
          .order('visit_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching all plans from visits table: $e");
      rethrow;
    }
  }

  // 2️⃣ جلب خطة مندوب محدد بناءً على الـ user_id الخاص به من جدول visits
  Future<List<Map<String, dynamic>>> getRepresentativePlan(String userId) async {
    try {
      final response = await supabase
          .from('visits')
          .select()
          .eq('user_id', userId)
          .order('visit_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching single rep plan for user ($userId): $e");
      return [];
    }
  }

  // 3️⃣ دالة تحديث حالة الخطة مع إضافة ملاحظات الإدمن المباشرة
  Future<void> updatePlanStatusWithNotes({
    required String visitId,
    required String newStatus,
    required String adminNotes,
  }) async {
    try {
      // استخدام اسم الجدول 'visits' والحقل 'id' لتحديث السطر بالملي
      final response = await supabase
          .from('visits')
          .update({
        'status': newStatus,          // حقل الحالة (مثلاً Approved أو Rejected)
        'admin_feedback': adminNotes,  // حقل الكومنت وملاحظات المدير
      })
          .eq('id', visitId)
          .select();

      if (response == null || (response as List).isEmpty) {
        throw Exception("Visit ID ($visitId) not found in Database.");
      }
    } catch (e) {
      print("Update Plan Error: $e");
      rethrow;
    }
  }
}