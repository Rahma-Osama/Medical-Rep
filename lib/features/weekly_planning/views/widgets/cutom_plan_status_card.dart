import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_button_widget.dart';

class CutomPlanStatusCard extends StatelessWidget {
  const CutomPlanStatusCard({
    super.key,
    required this.day,
    required this.date,
    required this.status,
    required this.color,
    required this.icon,
    required this.doctorName,
    required this.specialty,
    required this.shift,
    required this.clinicName,
    required this.location,
    this.onStartVisit,
  });

  final String day;
  final String date;
  final String status;
  final Color color;
  final IconData icon;
  final String doctorName;
  final String specialty;
  final String shift;
  final String clinicName;
  final String location;
  final VoidCallback? onStartVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.bold)),
                  Text(date, style: AppTextStyle.body.copyWith(color: AppColors.grayColor, fontSize: 12)),
                ],
              ),
              const Spacer(),
              _buildStatusBadge(),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // 2. بيانات الدكتور والتخصص
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: Colors.blueGrey, size: 20),
              const SizedBox(width: 8),
              Text(doctorName, style: AppTextStyle.subtitle.copyWith(fontSize: 16)),
              const SizedBox(width: 8),
              Text("• $specialty", style: AppTextStyle.body.copyWith(color: Colors.blueAccent, fontSize: 13)),
            ],
          ),

          const SizedBox(height: 12),

          // 3. المعلومات الفرعية (Shift, Clinic, Location) في Grid بسيط
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _buildInfoItem(Icons.access_time_filled_rounded, shift),
              _buildInfoItem(Icons.local_hospital_rounded, clinicName),
              _buildInfoItem(Icons.location_on_rounded, location),
            ],
          ),

          const SizedBox(height: 20),

          // 4. زرار Start Visit (يظهر فقط لو الحالة Planned)
          if (status.toLowerCase() == "planned")
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomElevatedButton(
  text: "Start Visit",
  icon: Icons.play_circle_fill,
  height: 48, // ارتفاع أصغر قليلاً ليناسب الكارت
  borderRadius: 12,
  onPressed: onStartVisit,
)
            ),
        ],
      ),
    );
  }

  // ويدجت صغيرة لعرض الحالات (Badge)
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: AppTextStyle.body.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // ويدجت لعرض سطر معلومات صغير مع أيقونة
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.grayColor),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyle.body.copyWith(color: Colors.black54, fontSize: 13)),
      ],
    );
  }
}