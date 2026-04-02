import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

const Color _kBadgeGreen = Color(0xFF2E7D32);
const Color _kBadgeGreenBg = Color(0xFFE8F5E9);

class HomeRecentVisitItem {
  const HomeRecentVisitItem({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    this.statusColor,
    this.statusBackgroundColor,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color? statusColor;
  final Color? statusBackgroundColor;
}

class HomeRecentVisitsSection extends StatelessWidget {
  const HomeRecentVisitsSection({
    super.key,
    required this.items,
    this.onSeeAll,
    this.onItemTap,
  });

  final List<HomeRecentVisitItem> items;
  final VoidCallback? onSeeAll;
  final void Function(int index)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Visits',
              style: AppTextStyle.title.copyWith(
                color: AppColors.primaryColor,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: onSeeAll ?? () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: AppTextStyle.body.copyWith(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.secondaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < items.length - 1 ? 12 : 0),
            child: _VisitCard(
              item: item,
              onTap: onItemTap != null ? () => onItemTap!(i) : null,
            ),
          );
        }),
      ],
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.item,
    this.onTap,
  });

  final HomeRecentVisitItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = item.statusBackgroundColor ?? _kBadgeGreenBg;
    final fg = item.statusColor ?? _kBadgeGreen;

    return Material(
      color: AppColors.whiteColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.leadingIcon, color: AppColors.primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyle.subtitle.copyWith(
                        fontSize: 15,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.grayColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusLabel,
                  style: AppTextStyle.body.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
