import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({
    super.key,
    required this.visitsToday,
    required this.visitsPlanned,
    required this.pendingDrafts,
    required this.weekVisitsDone,
    this.onDraftsTap,
  });

  final int visitsToday;
  final int visitsPlanned;
  final int pendingDrafts;
  final int weekVisitsDone;
  final VoidCallback? onDraftsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline_rounded,
            value: '$visitsToday',
            title: 'Visits Today',
            subtitle: 'of $visitsPlanned planned',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.description_outlined,
            value: '$pendingDrafts',
            title: 'Pending Drafts',
            subtitle: 'tap to review',
            onTap: onDraftsTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            value: '$weekVisitsDone',
            title: 'This Week',
            subtitle: 'visits done',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor. withOpacity(   0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.secondaryColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyle.HeadLine1.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyle.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyle.hint.copyWith(fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: child,
        ),
      );
    }
    return child;
  }
}
