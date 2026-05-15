import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_rep/features/admin/view/admin_page.dart';
import 'package:medical_rep/features/home/views/home_screen.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/hive_adapters/pending_feedback_hive_model.dart';
import 'package:medical_rep/features/weekly_planning/data/model/visit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:medical_rep/core/services/services.dart';


import 'features/Auth/views/LoginView.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://chhwbitslfgqmlkuubsr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaHdiaXRzbGZncW1sa3V1YnNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDAxMzgsImV4cCI6MjA5NDA3NjEzOH0.g2cZBSw3uBXJb7sq2SYOEyGgh2rNwXlva03OviOwmcI',
  );

  await Hive.initFlutter();


  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(VisitModelAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(PendingFeedbackHiveModelAdapter());
  }
  if (!Hive.isBoxOpen('weekly_visits_box')) {
    await Hive.openBox<VisitModel>('weekly_visits_box');
  }

  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox('settings');
  }
  if (!Hive.isBoxOpen('pending_feedbacks')) {
    await Hive.openBox<PendingFeedbackHiveModel>('pending_feedbacks');
  }
  if (!Hive.isBoxOpen('weekly_plan_box')) {
    await Hive.openBox('weekly_plan_box');
  }

  setupServiceLocator();

  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});


  Future<String> _getUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 'guest';

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return data['role'] ?? 'user';
    } catch (e) {
      print("user");
      return 'user'; // الافتراضي لو حصل مشكلة
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Rep App',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0055FF),
      ),
      home: user == null
          ? const LoginScreen()
          : FutureBuilder<String>(
        future: _getUserRole(),
        builder: (context, snapshot) {
          // أثناء جلب البيانات بنعرض شاشة تحميل بسيطة
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // توجيه المستخدم بناءً على الرتبة
          if (snapshot.data == 'admin') {
            return const AdminPanelScreen(); // شاشة الأدمن بتاعتك
          } else {
            return const HomeScreen(); // شاشة المندوب
          }
        },
      ),
    );
  }
}
