import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/medical_entity.dart';
import '../../domain/repositories/medical_repository.dart';
import '../models/medical_model.dart';

class MedicalRepositoryImpl implements MedicalRepository {
  // استخدام الـ client الخاص بسوبابيس
  final _supabase = Supabase.instance.client;

  @override
  Future<List<MedicalEntity>> getMedicalEntities() async {
    try {
      // 1. جلب البيانات من جدول 'doctors'
      // تأكدي أن اسم الجدول في سوبابيس هو 'doctors' بكل الحروف صغيرة
      final response = await _supabase
          .from('doctors')
          .select();

      // 2. تحويل البيانات القادمة (List of Maps) إلى قائمة من الـ Entities
      final List<dynamic> data = response as List<dynamic>;

      // هنا الـ MedicalModel.fromJson هو اللي هيقوم بمهمة ترجمة الأسماء
      return data.map((json) => MedicalModel.fromJson(json)).toList();
    } catch (e) {
      // طباعة الخطأ في الـ Console عشان نعرف لو فيه مشكلة في الـ Connection
      print("Error fetching doctors: $e");
      throw Exception("Failed to fetch doctors: $e");
    }
  }

  @override
  Future<void> addMedicalEntity(MedicalEntity entity) async {
    try {
      // تحويل الـ Entity لـ Model عشان نستخدم دالة toJson
      final medicalModel = MedicalModel(
        name: entity.name,
        specialty: entity.specialty,
        category: entity.category,
        hospital: entity.hospital,
        phone: entity.phone,
        email: entity.email,
        address: entity.address,
      );

      // إضافة البيانات للجدول
      await _supabase
          .from('doctors')
          .insert(medicalModel.toJson());
    } catch (e) {
      print("Error adding doctor: $e");
      throw Exception("Failed to add doctor: $e");
    }
  }
}