import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

class HomeServicesSection extends StatelessWidget {
  const HomeServicesSection({
    super.key,
    this.onViewAll,
    this.onDoctorsList,
    this.onPharmacyList,
    this.onWeeklyPlanning,
    this.onDrafts,
  });

  final VoidCallback? onViewAll;
  final VoidCallback? onDoctorsList;
  final VoidCallback? onPharmacyList;
  final VoidCallback? onWeeklyPlanning;
  final VoidCallback? onDrafts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services',
              style: AppTextStyle.title.copyWith(
                color: AppColors.primaryColor,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: onViewAll ?? () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: AppTextStyle.body.copyWith(
                  color: AppColors.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ServiceTile(
                icon: Icons.medical_services_outlined,
                label: 'Doctors List',
                onTap: onDoctorsList,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceTile(
                icon: Icons.medication_outlined,
                label: 'Pharmacy List',
                onTap: onPharmacyList,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ServiceTile(
                icon: Icons.calendar_month_rounded,
                label: 'Weekly Planning',
                onTap: onWeeklyPlanning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceTile(
                icon: Icons.description_outlined,
                label: 'Drafts',
                onTap: onDrafts,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
