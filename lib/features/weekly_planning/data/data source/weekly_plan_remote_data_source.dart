import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/visit_model.dart';

abstract class WeeklyPlanRemoteDataSource {
  Future<void> uploadPlan(List<VisitModel> visits);
  Stream<List<VisitModel>> getVisitsWithCache();
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

    for (var visit in visits) {
      // 1️⃣ تحويل الكائن لـ Map وتأمين الحقول الأساسية للسيرفر
      final map = visit.toJson();
      map['user_id'] = user.id;
      map['status'] = 'pending'; // تحويل إجباري لـ pending
      map['manager_notes'] = null; // تصفير الملاحظات

      // 2️⃣ الفحص الصريح: بنقرا المتغيرات مباشرة من الـ visit لضمان عدم وجود null
      final String? visitDate = visit.date;
      final String? doctorName = visit.doctor;

      if (visitDate == null || doctorName == null) {
        debugPrint("⚠️ Skipping visit due to missing date or doctor name");
        continue; 
      }

      // 3️⃣ الاستعلام الذكي من سوبابيز بأسماء الحقول الحقيقية في الجدول
      final existingVisits = await supabase
          .from('visits')
          .select('id')
          .eq('user_id', user.id)
          .eq('visit_date', visitDate)
          .eq('doctor_name', doctorName)
          .maybeSingle();

      if (existingVisits != null) {
        // 4️⃣ لو وجدها: تحديث (Update) بناءً على الـ Primary Key الحقيقي للـ row
        final existingId = existingVisits['id'];
        map.remove('id'); // إزالة الـ ID العشوائي المؤقت من الـ map
        
        await supabase
            .from('visits')
            .update(map)
            .eq('id', existingId);
            
        debugPrint("🔄 Successfully UPDATED visit to pending for: $doctorName");
      } else {
        // 5️⃣ لو لم يجدها: إضافة (Insert) كصف جديد تماماً
        // تنظيف الـ id المؤقت لو جاي من الـ local cache مش UUID حقيقي
        if (map['id'] == null || map['id'].toString().length < 10) {
          map.remove('id'); 
        }
        
        await supabase.from('visits').insert(map);
        debugPrint("✨ Successfully INSERTED new visit for: $doctorName");
      }
    }
    
    debugPrint("✅ Database synchronization completed perfectly!");
  } catch (e) {
    debugPrint("❌ CRITICAL ERROR in uploadPlan Remote Source: $e");
    rethrow;
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

  @override
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
 
              final docInfo = doctorsData.cast<Map<String, dynamic>>().firstWhere(
                    (d) => d['name'] == visit.doctor,
                orElse: () => <String, dynamic>{}, 
              );

              if (docInfo.isNotEmpty) {
                visit.lat = double.tryParse(docInfo['latitude'].toString());
                visit.long = double.tryParse(docInfo['longitude'].toString());
                debugPrint("Linked: ${visit.doctor} at (${visit.lat}, ${visit.long})");
              }
            }
          } catch (e) {
            debugPrint("Error fetching doctors coordinates: $e");
          }
        }

  
        await _saveVisitsToCache(visits);

        return visits;
      } catch (e) {
        debugPrint("Critical Error in getVisitsWithCache: $e");
        return [];
      }
    });
  }

  
  Future<void> _saveVisitsToCache(List<VisitModel> visits) async {
    try {
      // ✅ شيلنا الـ <VisitModel> من نداء الـ box لمنع القفلة مع المين
final box = Hive.box('weekly_visits_box');
      var settingsBox = Hive.box('settings');

      await box.clear();
      await box.addAll(visits);

      await settingsBox.put('last_sync_date', DateTime.now().millisecondsSinceEpoch);
      debugPrint("Cache Updated & 5-Day Timer Started!");
    } catch (e) {
      debugPrint("Error saving to Hive: $e");
    }
  }
}