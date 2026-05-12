import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

/// Rounded top bar with five tabs: Home, Visits, Planning, Reports, More.
class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <_NavSpec>[
      _NavSpec(Icons.home_rounded, 'Home'),
      _NavSpec(Icons.assignment_outlined, 'Visits'),
      _NavSpec(Icons.calendar_month_rounded, 'Planning'),
    ];

    return Material(
      elevation: 12,
      shadowColor: AppColors.blackColor.withValues(alpha: 0.08),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final selected = i == currentIndex;
                final spec = items[i];
                final color = selected ? AppColors.secondaryColor : AppColors.grayColor;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(spec.icon, color: color, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            spec.label,
                            style: AppTextStyle.hint.copyWith(
                              color: color,
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.icon, this.label);
  final IconData icon;
  final String label;
}
