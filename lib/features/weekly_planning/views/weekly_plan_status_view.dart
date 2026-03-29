import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/cutom_plan_status_card.dart';

class WeeklyPlanningView extends StatelessWidget {
  const WeeklyPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 🔹 App Bar
          const CustomAppBar(label: 'Weekly Plan Status'),

          /// 🔹 Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Current Week Schedule"),
                  const SizedBox(height: 15),

                  // كارت زيارة السبت (مثال للبيانات الجديدة)
                  CutomPlanStatusCard(
                    day: 'Saturday',
                    date: 'March 21',
                    doctorName: 'Dr. Ahmed Ali', // أضفنا اسم الدكتور
                    specialty: 'Cardiology', // التخصص
                    shift: 'AM ', // الوقت
                    clinicName: 'Elite Clinic', // اسم العيادة
                    location: 'Alexandria, Smouha', // اللوكيشن
                    status: 'Planned',
                    color: Colors.green,
                    icon: Icons.check_circle_rounded,
                    onStartVisit: () {
                      // Logic لبدء الزيارة
                      print("Visit Started");
                    },
                  ),

                  const SizedBox(height: 12),

                  // كارت زيارة الأحد
                  CutomPlanStatusCard(
                    day: 'Sunday',
                    date: 'March 22',
                    doctorName: 'Dr. Sarah Mahmoud',
                    specialty: 'Dermatology',
                    shift: 'PM',
                    clinicName: 'Skin Care Center',
                    location: 'Cairo, Maadi',
                    status: 'Pending',
                    color: Colors.orange,
                    icon: Icons.access_time_filled_rounded,
                    onStartVisit: () {
                       // Logic لبدء الزيارة
                    },
                  ),

                  const SizedBox(height: 100), // مساحة للـ FAB لو وجد
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.title.copyWith(color: AppColors.grayColor),
    );
  }
}