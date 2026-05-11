import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ إضافة الـ Bloc
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_state.dart';

import 'package:medical_rep/features/weekly_planning/views/widgets/cutom_plan_status_card.dart';

class WeeklyPlanningView extends StatelessWidget {
  const WeeklyPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة بأسماء الأيام
    final List<String> weekDays = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday"];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(label: 'Weekly Plan Status'),
          // ✅ بنستخدم BlocBuilder عشان الـ UI يتحدث لو الداتا اتغيرت
          BlocBuilder<WeeklyPlanCubit, WeeklyPlanState>(
            builder: (context, state) {
              // لو الحالة هي الحالة المحدثة (التي تحتوي على البيانات)
              if (state is WeeklyPlanUpdated) {
                final savedPlan = state.weeklyData;

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        for (int i = 0; i < weekDays.length; i++)
                          if (savedPlan.containsKey(i) && savedPlan[i]!.isValid) // ✅ التأكد إن اليوم مكتمل
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CutomPlanStatusCard(
                                day: weekDays[i],
                                date: "March ${21 + i}",
                                doctorName: savedPlan[i]?.doctor ?? "No Doctor Selected",
                                specialty: "General",
                                shift: savedPlan[i]?.shift ?? "AM",
                                clinicName: savedPlan[i]?.brick ?? "N/A",
                                location: savedPlan[i]?.brick ?? "",
                                status: 'Planned',
                                color: Colors.green,
                                icon: Icons.check_circle_rounded,
                                onStartVisit: () {
                                  // مبرمج (د) هيكمل هنا
                                },
                              ),
                            ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              }
              
              // حالة التحميل أو لو مفيش داتا
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }
}