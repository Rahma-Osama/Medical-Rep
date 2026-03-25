import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';

class HeaderWeekPlanWidget extends StatelessWidget {
  const HeaderWeekPlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.thirdColor.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Plan",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CircleAvatar(
                backgroundColor: AppColors.whiteColor.withOpacity(0.2),
                child: const Icon(Icons.calendar_month, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
