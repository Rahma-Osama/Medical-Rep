import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

/// White card overlapping the header: profile, quick row, progress bars.
class HomeProfileProgressCard extends StatelessWidget {
  const HomeProfileProgressCard({
    super.key,
    required this.email,
    required this.repId,
    this.visitsCurrent = 6,
    this.visitsPlanned = 10,
    this.monthlyTargetPercent = 56,
    this.onProfile,
    this.onQrTap,
    this.onSummaryTap,
    this.onTargetTap,
  });

  final String email;
  final String repId;
  final int visitsCurrent;
  final int visitsPlanned;
  final int monthlyTargetPercent;
  final VoidCallback? onProfile;
  final VoidCallback? onQrTap;
  final VoidCallback? onSummaryTap;
  final VoidCallback? onTargetTap;

  @override
  Widget build(BuildContext context) {
    final visitsProgress = visitsPlanned > 0 ? visitsCurrent / visitsPlanned : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.08),
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
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          Row(
            children: [
              Expanded(
                child: _QuickIcon(
                  icon: Icons.qr_code_2_rounded,
                  label: 'QR Code',
                  onTap: onQrTap,
                ),
              ),
              Expanded(
                child: _QuickIcon(
                  icon: Icons.dashboard_customize_outlined,
                  label: "Today's Summary",
                  onTap: onSummaryTap,
                ),
              ),
              Expanded(
                child: _QuickIcon(
                  icon: Icons.track_changes_rounded,
                  label: 'Target',
                  onTap: onTargetTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ProgressRow(
                  icon: Icons.schedule_rounded,
                  label: "Today's Visits",
                  valueText: '$visitsCurrent/$visitsPlanned',
                  progress: visitsProgress,
                ),
                const SizedBox(height: 14),
                _ProgressRow(
                  icon: Icons.trending_up_rounded,
                  label: 'Monthly Target',
                  valueText: '$monthlyTargetPercent%',
                  progress: monthlyTargetPercent / 100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickIcon extends StatelessWidget {
  const _QuickIcon({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondaryColor, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.body.copyWith(
                color: AppColors.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.valueText,
    required this.progress,
  });

  final IconData icon;
  final String label;
  final String valueText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.thirdColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: AppTextStyle.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Text(
                    valueText,
                    style: AppTextStyle.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.whiteColor.withValues(alpha: 0.7),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
