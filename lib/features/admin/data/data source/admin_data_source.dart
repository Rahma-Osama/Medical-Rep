// داخل ملف الـ Remote Data Source الخاص بالأدمن
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRemoteDataSource {
  final supabase = Supabase.instance.client;

  // جلب كل الخطط المرفوعة
Future<List<Map<String, dynamic>>> getAllPlans() async {
  try {
    final response = await Supabase.instance.client
        .from('visits')
        .select() // تأكدي إنها select فاضية عشان تجيب كل الأعمدة
        .order('visit_date', ascending: true);
    return response;
  } catch (e) {
    print("Error fetching plans: $e");
    return [];
  }
}
  // تحديث حالة الخطة (Accepted / Rejected)
  Future<void> updatePlanStatus(String visitId, String newStatus) async {
    await supabase
        .from('visits')
        .update({'status': newStatus})
        .eq('id', visitId);
  }
}