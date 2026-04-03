import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryColor,
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 32),
          _buildTitle(),
          const SizedBox(height: 10),
          _buildSubtitle(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.star, color: AppColors.whiteColor, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("MedRep", style: AppTextStyle.title.copyWith(color: AppColors.whiteColor)),
            Text(
              "FIELD INTELLIGENCE",
              style: AppTextStyle.hint.copyWith(
                color: AppColors.whiteColor.withOpacity(0.45),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: TextSpan(
        style: AppTextStyle.displayTitle.copyWith(color: AppColors.whiteColor),
        children: [
          const TextSpan(text: "Welcome\nback, "),
          TextSpan(
            text: "Doctor",
            style: TextStyle(color: AppColors.secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      "Sign in to manage your\nvisits and weekly plans",
      style: AppTextStyle.body.copyWith(color: AppColors.whiteColor.withOpacity(0.5)),
    );
  }
}