import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

class SegmentedControllWidget extends StatelessWidget {
  const SegmentedControllWidget({super.key, required this.label, required this.option, required this.selected, required this.onSelected});
 final String label;
 final List<String> option;
 final String selected;
 final Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style:  AppTextStyle.body),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.lightgrayColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: option.map((opt) {
              bool isSelected = selected == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.whiteColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.blackColor.withOpacity(0.05), blurRadius: 5)] : [],
                    ),
                    child: Center(
                      child: Text(opt, style: TextStyle(
                        fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primaryColor : AppColors.grayColor)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );;
  }
}
