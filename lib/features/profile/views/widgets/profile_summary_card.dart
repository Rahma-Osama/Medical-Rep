import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.user,
    this.onEditPhoto,
  });

  final ProfileUser user;
  final VoidCallback? onEditPhoto;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(   0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.15),
                        AppColors.thirdColor.withOpacity( 0.2),
                      ],
                    ),
                  ),
                  child: Icon(Icons.person_rounded, size: 48, color: AppColors.primaryColor),
                ),
                Material(
                  color: AppColors.secondaryColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onEditPhoto,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.camera_alt_outlined, color: AppColors.whiteColor, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              user.fullName,
              style: AppTextStyle.subtitle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              user.roleTitle,
              style: AppTextStyle.body.copyWith(
                color: AppColors.grayColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user.regionLabel,
              style: AppTextStyle.hint.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(   0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'REP ID: ${user.repId}',
                style: AppTextStyle.body.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
