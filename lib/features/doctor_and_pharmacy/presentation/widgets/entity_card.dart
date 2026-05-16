import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/doctor_and_pharmacy/domain/entities/medical_entity.dart';
import 'package:medical_rep/features/doctor_and_pharmacy/presentation/views/doctor_profile_page.dart';

class EntityCard extends StatelessWidget {
  final MedicalEntity entity;

  const EntityCard({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // الـ Avatar بيعرض أول حرف من الاسم بشكل شيك
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: Text(
                  entity.name.isNotEmpty ? entity.name[0].toUpperCase() : "?",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.name,
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      entity.specialty, // بيقرأ من specialization في الداتابيز
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 25, thickness: 0.5),

          // عرض العنوان فقط ومسحنا سطر الفون بناءً على طلبك
          _buildInfo(Icons.location_on_rounded, entity.address), // بيقرأ من address_name

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // الانتقال لصفحة التفاصيل وتمرير أوبجكت الدكتور كامل
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorProfilePage(doctor: entity),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}