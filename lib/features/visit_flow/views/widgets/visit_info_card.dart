import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import '../../models/visit_model.dart';

class VisitInfoCard extends StatelessWidget {
  final VisitModel visit;

  const VisitInfoCard({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.person_outline, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.doctorName, style: AppTextStyle.subtitle),
                    const SizedBox(height: 2),
                    Text(visit.specialty,
                        style: AppTextStyle.hint.copyWith(color: AppColors.grayColor)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  visit.shift,
                  style: AppTextStyle.hint.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 0.5),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.local_hospital_outlined, visit.clinicName),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, visit.location),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.medication_outlined, visit.targetProduct),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grayColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: AppTextStyle.body.copyWith(color: AppColors.grayColor)),
        ),
      ],
    );
  }
}