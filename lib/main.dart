import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Imports الخاصة بمشروعك
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/features/doctor_and_pharmacy/presentation/cubit/medical_cubit.dart';
import 'package:medical_rep/features/doctor_and_pharmacy/presentation/views/entities_list_page.dart';

void main() async {
  // 1. التأكد من تهيئة الـ Widgets
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة Supabase (البيانات اللي صحابك ضافوها)
  await Supabase.initialize(
    url: 'https://chhwbitslfgqmlkuubsr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaHdiaXRzbGZncW1sa3V1YnNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDAxMzgsImV4cCI6MjA5NDA3NjEzOH0.g2cZBSw3uBXJb7sq2SYOEyGgh2rNwXlva03OviOwmcI',
  );

  // 3. تهيئة الـ Service Locator (الـ GetIt)
  setupServiceLocator();

  runApp(const MedicalApp());
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      return const MaterialApp(
          debugShowCheckedModeBanner: false,
        home: LoginScreen());
    }

    // 👈 تأكدي من كتابة ['role'] بالظبط زي ما كتبتيها في الـ SQL
    final String? role = user.userMetadata?['role'];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Rep App',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0055FF),
      ),
      // تشغيل صفحتك كبداية للتطبيق مع الـ Cubit بتاعها
      home: BlocProvider(
        create: (context) => getIt<MedicalCubit>()..fetchEntities(),
        child: const EntitiesListPage(),
      ),
    );
  }
}