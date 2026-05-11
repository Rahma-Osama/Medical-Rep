import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/visit_model.dart';

abstract class WeeklyPlanRemoteDataSource {
  /// بياخد قائمة من الزيارات ويرفعها دفعة واحدة للسيرفر
  Future<void> uploadPlan(List<VisitModel> visits);
}

class WeeklyPlanRemoteDataSourceImpl implements WeeklyPlanRemoteDataSource {
  // الحصول على نسخة من عميل سوبابيز
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<void> uploadPlan(List<VisitModel> visits) async {
    try {
      // 1. التأكد من أن المستخدم مسجل دخول (Authentication Check)
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User must be logged in to upload a plan.");
      }

      // 2. تحويل قائمة الـ Models لـ List of Maps
      // سوبابيز بتفهم البيانات لما تتبعت كـ JSON (Map في دارت)
      final List<Map<String, dynamic>> dataToUpload = visits.map((visit) {
        return {
          'user_id': user.id,          // ربط الزيارة بالمندوب اللي رفعها
          'brick': visit.brick,        // المنطقة
          'doctor_name': visit.doctor, // اسم الدكتور
          'shift': visit.shift,        // صباحي ولا مسائي
          'visit_type': visit.type,    // فردية ولا مشتركة
          'notes': visit.notes,        // ملاحظات إضافية
        };
      }).toList();

      // 3. عملية الرفع للجدول اللي كريتناه (visits)
      // ميزة سوبابيز إنها بتسمح برفع List كاملة في طلب واحد (Bulk Insert)
      await supabase
          .from('visits')
          .insert(dataToUpload);

      print("✅ Plan uploaded successfully to Supabase!");
      
    } on PostgrestException catch (error) {
      // التعامل مع أخطاء قاعدة البيانات (مثل مشاكل الـ RLS أو اسم الجدول غلط)
      print("❌ Supabase Postgrest Error: ${error.message}");
      throw Exception("Database error: ${error.message}");
    } catch (e) {
      // التعامل مع أي خطأ غير متوقع (مثل انقطاع الإنترنت)
      print("❌ Unexpected Error: $e");
      throw Exception("An unexpected error occurred during upload.");
    }
  }
}