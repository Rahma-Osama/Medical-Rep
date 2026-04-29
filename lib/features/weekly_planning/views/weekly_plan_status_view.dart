import 'package:flutter/material.dart';
import 'package:medical_rep/core/data/repositeries/weekly_plan_repository.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/weekly_planning/model/visit_model.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/cutom_plan_status_card.dart';
class WeeklyPlanningView extends StatelessWidget {
  const WeeklyPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. الوصول للـ Repository
    final repository = WeeklyPlanRepository();
    // 2. جلب الخطة المخزنة فعلياً
    final Map<int, VisitModel> savedPlan = repository.getLocalPlan();

    // قائمة بأسماء الأيام بنفس ترتيب الـ Cubit
    final List<String> weekDays = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday"];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(label: 'Weekly Plan Status'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 3. عرض البيانات بناءً على اللي اتسيف
                  // بنلف على الـ 5 أيام
                  for (int i = 0; i < weekDays.length; i++) 
                    if (savedPlan.containsKey(i)) // التأكد إن اليوم ده له داتا
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CutomPlanStatusCard(
                          day: weekDays[i],
                          date: "March ${21 + i}", // تقدري تحسبي التاريخ فعلياً
                          doctorName: savedPlan[i]?.doctor ?? "No Doctor Selected",
                          specialty: "General", // ممكن تزوديها في الموديل لاحقاً
                          shift: savedPlan[i]?.shift ?? "AM",
                          clinicName: savedPlan[i]?.brick ?? "N/A", // عرض المنطقة كـ اسم مبدئي
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
          ),
        ],
      ),
    );
  }
}