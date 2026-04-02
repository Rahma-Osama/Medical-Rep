import 'package:flutter/material.dart';
import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';

void main() {
  runApp(const MedicalApp());
}
class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeeklyPlanningView(),
    );
  }
}