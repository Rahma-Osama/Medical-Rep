// admin_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRemoteDataSource {
  final supabase = Supabase.instance.client;

  // جلب كل الخطط (موجودة عندك بالفعل)
Future<List<Map<String, dynamic>>> getAllPlans() async {
  // إضافة select() بتخلي سوبابيز يعمل Fetch جديد
  final response = await supabase
      .from('visits')
      .select() 
      .order('visit_date', ascending: true);
      
  return response;
}
  // التعديل: دالة تحديث الحالة مع إضافة ملاحظات الإدمن
Future<void> updatePlanStatusWithNotes({
  required String visitId, 
  required String newStatus,
  required String adminNotes,
}) async {
  try {
    // التأكد من استخدام اسم الجدول 'visits' والعمود 'id' كما في الصورة
    final response = await supabase
        .from('visits') 
        .update({
          'status': newStatus, // اتأكدي إنك ضفتي العمود ده في سوبابيز
          'admin_notes': adminNotes,   // اتأكدي إنك ضفتي العمود ده في سوبابيز
        })
        .eq('id', visitId) 
        .select();

    if (response == null || (response as List).isEmpty) {
      throw Exception("Visit ID ($visitId) not found in Database.");
    }
  } catch (e) {
    print("Update Error: $e");
    rethrow;
  }
}
  // admin_data_source.dart
Future<List<Map<String, dynamic>>> getRepresentativePlan(String userId) async {
  try {
    final response = await supabase
        .from('visits')
        .select()
        .eq('user_id', userId)
        .order('visit_date', ascending: true);
    return response;
  } catch (e) {
    print("Error fetching single rep plan: $e");
    return [];
  }
}
}