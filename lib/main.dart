import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/features/Auth/views/LoginView.dart';
import 'package:medical_rep/features/admin/view/admin_page.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';
import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_local_data_source.dart';
import 'package:medical_rep/features/weekly_planning/data/data%20source/weekly_plan_remote_data_source.dart';
import 'package:medical_rep/features/weekly_planning/data/repositories/weekly_plan_repository_impl.dart';
import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Imports الطبقات (تأكدي من صحة المسارات عندك)
import 'features/weekly_planning/data/model/visit_model.dart';

import 'features/weekly_planning/domain/usecases/save_visit_usecase.dart';
import 'features/weekly_planning/domain/usecases/submit_plan_usecase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
await Supabase.initialize(
    url: 'https://chhwbitslfgqmlkuubsr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaHdiaXRzbGZncW1sa3V1YnNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDAxMzgsImV4cCI6MjA5NDA3NjEzOH0.g2cZBSw3uBXJb7sq2SYOEyGgh2rNwXlva03OviOwmcI',
  );


  // 2. تهيئة Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(VisitModelAdapter().typeId)) {
    Hive.registerAdapter(VisitModelAdapter());
  }
  await Hive.openBox<VisitModel>('weekly_plan_box');

  // 3. إعداد الـ Dependency Injection (الربط اللي سألتي عنه)
  // بنبني الطبقات من تحت لفوق (Data -> Domain -> Presentation)
  final localDS = WeeklyPlanLocalDataSourceImpl();
  final remoteDS = WeeklyPlanRemoteDataSourceImpl();
  
  final repository = WeeklyPlanRepositoryImpl(
    localDS: localDS,
    remoteDS: remoteDS,
  );

  final saveVisitUseCase = SaveVisitUseCase(repository);
  final submitPlanUseCase = SubmitPlanUseCase(repository);

  runApp(
    // 4. توفير الـ Cubit لكل التطبيق من البداية
    BlocProvider(
      create: (context) => WeeklyPlanCubit(
        saveVisitUseCase: saveVisitUseCase,
        submitPlanUseCase: submitPlanUseCase,
      ),
      child: const MedicalApp(),
    ),
  );
}

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      return const MaterialApp(home: LoginScreen());
    }

    // 👈 تأكدي من كتابة ['role'] بالظبط زي ما كتبتيها في الـ SQL
    final String? role = user.userMetadata?['role'];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: role == 'admin' ? const AdminPanelScreen() : const CreatePlanScreen(),
    );
  }
}