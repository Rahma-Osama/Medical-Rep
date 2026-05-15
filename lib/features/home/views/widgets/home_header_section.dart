import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

/// Blue gradient header with greeting and role line.
class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({
    super.key,
    required this.greeting,
    required this.userName,
    required this.roleLine,
  });

  final String greeting;
  final String userName;
  final String roleLine;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      height: 200 + topPad,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primaryColor,
            AppColors.secondaryColor,
            AppColors.thirdColor,
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -40,
            top: -30,
            child: CircleAvatar(
              radius: 90,
              backgroundColor: AppColors.whiteColor.withOpacity( 0.08),
            ),
          ),
          Positioned(
            left: -50,
            bottom: 20,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: AppColors.whiteColor.withOpacity(  0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyle.hint.copyWith(
                  color: AppColors.whiteColor.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                userName,
                style: AppTextStyle.displayTitle.copyWith(
                  color: AppColors.whiteColor,
                  fontSize: 26,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                roleLine,
                style: AppTextStyle.body.copyWith(
                  color: AppColors.whiteColor.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
