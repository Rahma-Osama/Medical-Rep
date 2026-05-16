// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:medical_rep/features/admin/view/admin_page.dart';
// import 'package:medical_rep/features/home/views/home_screen.dart';
// import 'package:medical_rep/features/visit_flow/data/datasources/local/hive_adapters/pending_feedback_hive_model.dart';
// import 'package:medical_rep/features/weekly_planning/data/model/visit_model.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:medical_rep/core/services/services.dart';
// import 'features/Auth/views/LoginView.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 1. Supabase Init
//   await Supabase.initialize(
//     url: 'https://chhwbitslfgqmlkuubsr.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaHdiaXRzbGZncW1sa3V1YnNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDAxMzgsImV4cCI6MjA5NDA3NjEzOH0.g2cZBSw3uBXJb7sq2SYOEyGgh2rNwXlva03OviOwmcI',
//   );
//
//   // 2. Hive Init
//   await Hive.initFlutter();
//
//   // 3. Register Adapters
//   if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(VisitModelAdapter());
//   if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PendingFeedbackHiveModelAdapter());
//
//   // 4. Open Boxes "مرة واحدة فقط هنا"
//   // ده بيمنع خطأ "Box already open"
//   await Hive.openBox<VisitModel>('weekly_visits_box');
//   await Hive.openBox('settings');
//   await Hive.openBox<PendingFeedbackHiveModel>('pending_feedbacks');
//   if (!Hive.isBoxOpen('weekly_plan_box')) {
//   await Hive.openBox('weekly_plan_box');
// }
// if (!Hive.isBoxOpen('weekly_visits_box')) {
// await Hive.openBox('weekly_plan_box');
// }
// // شيلي <VisitModel> عشان يقبل يخزن لستة
// // خليته بياخد VisitModel عشان ميعملش تعارض
//
//   setupServiceLocator();
//
//   runApp(const MedicalApp());
// }
//
// class MedicalApp extends StatefulWidget {
//   const MedicalApp({super.key});
//
//   @override
//   State<MedicalApp> createState() => _MedicalAppState();
// }
//
// class _MedicalAppState extends State<MedicalApp> {
//   // بنخزن الـ Future هنا عشان ميتكررش مع كل Build ويسبب Freeze
//   late Future<String> _roleFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _roleFuture = _getUserRole();
//   }
//
//   Future<String> _getUserRole() async {
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user == null) return 'guest';
//
//     try {
//       final data = await Supabase.instance.client
//           .from('profiles')
//           .select('role')
//           .eq('id', user.id)
//           .single();
//
//       return data['role'] ?? 'user';
//     } catch (e) {
//       debugPrint("Error fetching role: $e");
//       return 'user';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = Supabase.instance.client.auth.currentUser;
//
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true, primaryColor: const Color(0xFF0055FF)),
//       home: user == null
//           ? const LoginScreen()
//           : FutureBuilder<String>(
//               future: _roleFuture, // بنادي المتغير مش الدالة
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Scaffold(body: Center(child: CircularProgressIndicator()));
//                 }
//                 return snapshot.data == 'admin' ? const AdminPanelScreen() : const HomeScreen();
//               },
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medical_rep/features/home/views/home_screen.dart';
import 'package:medical_rep/features/Auth/views/LoginView.dart';
import 'package:medical_rep/features/weekly_planning/data/model/visit_model.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/hive_adapters/pending_feedback_hive_model.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/features/admin/view/admin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة السوبابيز
  await Supabase.initialize(
    url: 'https://chhwbitslfgqmlkuubsr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaHdiaXRzbGZncW1sa3V1YnNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDAxMzgsImV4cCI6MjA5NDA3NjEzOH0.g2cZBSw3uBXJb7sq2SYOEyGgh2rNwXlva03OviOwmcI',
  );

  // تهيئة الـ Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(VisitModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PendingFeedbackHiveModelAdapter());

  // 4. Open Boxes بطريقة مؤمنة تماماً ضد الـ HiveError
  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox('settings');
  }

  if (!Hive.isBoxOpen('pending_feedbacks')) {
    await Hive.openBox<PendingFeedbackHiveModel>('pending_feedbacks');
  }

// 🔹 صندوق الزيارات: نفتحه عام تماماً وبدون أي أنواع لمنع التعارض نهائياً
  if (!Hive.isBoxOpen('weekly_visits_box')) {
    await Hive.openBox('weekly_visits_box'); 
  }

  setupServiceLocator();
  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  // دالة فحص الـ Role بطريقة احترافية من السيرفر (ومعافاة من الـ Freeze)
  Future<String> _getUserRole(String userId, String email) async {
    // خط دفاع أول: لو الإيميل صريح للآدمنز بتوعك، رجعي آدمن فوراً لتسريع الفتح
    final cleanEmail = email.toLowerCase().trim();
    if (cleanEmail == 'admin@medrep.com' || cleanEmail == 'manar@gmail.com' || cleanEmail.contains('admin')) {
      return 'admin';
    }

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      return data['role'] ?? 'user'; 
    } catch (e) {
      debugPrint("Error fetching role: $e");
      return 'user'; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0055FF),
      ),
      // 🔹 الحل السحري: الـ StreamBuilder ده بيراقب حالة الـ Auth في الوقت الفعلي
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;

          // 1. لو مفيش سيشن (خروج أو لسه مفتحش) -> شاشة اللوجن فوراً
          if (session == null) {
            return const LoginScreen();
          }

          // 2. لو فيه سيشن -> بنفحص الرول بأمان مع استخدام ValueKey لمنع تعليق الشاشة
          return FutureBuilder<String>(
            key: ValueKey(session.user.id), 
            future: _getUserRole(session.user.id, session.user.email ?? ""),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasData && roleSnapshot.data == 'admin') {
                return const AdminPanelScreen();
              }
              
              return const HomeScreen();
            },
          );
        },
      ),
    );
  }
}