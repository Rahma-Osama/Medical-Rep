import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

/// White card overlapping the header: profile, quick row, progress bars.
class HomeProfileProgressCard extends StatelessWidget {
  const HomeProfileProgressCard({
    super.key,
    required this.email,
    required this.repId,
    this.onProfile,
    this.onQrTap,
    this.onSummaryTap,
    this.onTargetTap,
  });

  final String email;
  final String repId;
  final VoidCallback? onProfile;
  final VoidCallback? onQrTap;
  final VoidCallback? onSummaryTap;
  final VoidCallback? onTargetTap;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.lightgrayColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_rounded, color: AppColors.primaryColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: AppTextStyle.subtitle.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'REP ID: $repId',
                      style: AppTextStyle.hint.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onProfile ?? () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Profile',
                  style: AppTextStyle.body.copyWith(
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
