import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/cutom_plan_status_card.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_state.dart';

class WeeklyPlanningView extends StatelessWidget {
  const WeeklyPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WeeklyPlanCubit>(),
      child: const _WeeklyPlanningBody(),
    );
  }
}

class _WeeklyPlanningBody extends StatelessWidget {
  const _WeeklyPlanningBody();

  @override
  Widget build(BuildContext context) {
    final List<String> weekDays = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday"];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<WeeklyPlanCubit, WeeklyPlanState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              const CustomAppBar(label: 'Weekly Plan Status'),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
    
                      const SizedBox(height: 15),

                      // 🔹 عرض البيانات ديناميكياً من الكيوبيت
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: weekDays.length,
                        itemBuilder: (context, dayIndex) {
                          // جلب قائمة الزيارات لليوم الحالي
                          final visits = state.weeklyData[dayIndex] ?? [];

                          if (visits.isEmpty) {
                            return const SizedBox.shrink(); // لو اليوم فاضي ميعرضش حاجة
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: visits.map((visit) {
                              return // جوه الـ map في صفحة WeeklyPlanningView
 Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: CutomPlanStatusCard(
    day: weekDays[dayIndex],
    date: visit.date ?? "No Date",
    doctorName: visit.doctor ?? "Unknown Doctor",
    specialty: visit.brick ?? "No Specialty",
    shift: visit.shift,
    clinicName: "Clinic",
    location: visit.brick ?? "No Location",
    // 🔹 التعديل هنا ليكون Pending
    status: 'Pending', 
    color: Colors.orange, // لون الانتظار
    icon: Icons.access_time_filled_rounded, // أيقونة الساعة
    onStartVisit: () {},
  ),
);
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}