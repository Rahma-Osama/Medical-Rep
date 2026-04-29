import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_rep/features/weekly_planning/model/visit_model.dart';
import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
 Hive.registerAdapter(VisitModelAdapter()); // المولد تلقائياً
  await Hive.openBox<VisitModel>('weekly_plan_box');
  runApp(const MedicalApp());
}
class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreatePlanScreen(),
    );
  }
}