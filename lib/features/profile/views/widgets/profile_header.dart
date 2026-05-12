import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.showBack = true,
    this.onBack,
    this.title = 'Profile',
  });

  final bool showBack;
  final VoidCallback? onBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8, top + 8, 16, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.secondaryColor,
            AppColors.thirdColor,
          ],
        ),
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.whiteColor, size: 20),
            )
          else
            const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: showBack ? TextAlign.center : TextAlign.left,
              style: AppTextStyle.title.copyWith(
                color: AppColors.whiteColor,
                fontSize: 20,
              ),
            ),
          ),
          if (showBack) const SizedBox(width: 48) else const SizedBox(width: 8),
        ],
      ),
    );
  }
}
