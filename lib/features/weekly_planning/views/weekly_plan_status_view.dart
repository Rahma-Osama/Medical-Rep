import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/cutom_plan_status_card.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/header_week_plan_widget.dart'; // افترضت أن لونك الأساسي هنا

class WeeklyPlanningView extends StatelessWidget {
  const WeeklyPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          // Header
          HeaderWeekPlanWidget(),

          // 2. Planning List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionTitle("Current Week Schedule"),
                const SizedBox(height: 15),
                CutomPlanStatusCard(
                 day: 'Saturday', date: 'March 21', status: 'Planned', color: Colors.green, icon: Icons.check_circle_rounded,
                ),
                CutomPlanStatusCard(
                day: 'Sunday', date: 'March 22', status: 'Pending', color: Colors.orange, icon: Icons.access_time_filled_rounded,
                ),

                const SizedBox(height: 80), // Padding for FAB
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header Widget with Gradient

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3142),
      ),
    );
  }

  // Enhanced Card Design
}
