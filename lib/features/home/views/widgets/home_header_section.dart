import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

/// Blue gradient header with greeting, role line, settings, and notifications.
class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({
    super.key,
    required this.greeting,
    required this.userName,
    required this.roleLine,
    this.notificationCount = 0,
    this.onSettings,
    this.onNotifications,
  });

  final String greeting;
  final String userName;
  final String roleLine;
  final int notificationCount;
  final VoidCallback? onSettings;
  final VoidCallback? onNotifications;

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
              backgroundColor: AppColors.whiteColor.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: -50,
            bottom: 20,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: AppColors.whiteColor.withValues(alpha: 0.06),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyle.hint.copyWith(
                        color: AppColors.whiteColor.withValues(alpha: 0.85),
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
                        color: AppColors.whiteColor.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _circleIconButton(
                icon: Icons.settings_outlined,
                onPressed: onSettings ?? () {},
              ),
              const SizedBox(width: 10),
              _circleIconButton(
                icon: Icons.notifications_none_rounded,
                onPressed: onNotifications ?? () {},
                badge: notificationCount > 0 ? '$notificationCount' : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? badge,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.whiteColor.withValues(alpha: 0.2),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: AppColors.whiteColor, size: 22),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.errorColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: AppTextStyle.label.copyWith(
                  color: AppColors.whiteColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
