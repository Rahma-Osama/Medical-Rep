import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';

class CustomDropdownWidget extends StatelessWidget {
  const CustomDropdownWidget({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    // التحقق إذا كانت القائمة فارغة
    bool isEmpty = items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyle.body),
          ],
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: AppColors.backgroundColor,
            // التأكد أن الـ value موجود فعلاً في الـ items لتجنب الـ Error الشهير في Flutter
            value: (items.contains(value)) ? value : null,
            isExpanded: true,
            hint: Text(
              isEmpty ? "Select area first" : "Tap to select",
              style: AppTextStyle.body.copyWith(color: AppColors.grayColor),
            ),
            // لو القائمة فاضية بنخلي الـ items بـ null عشان الزرار يبقى Disabled تلقائياً
            items: isEmpty
                ? null
                : items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            // لو القائمة فاضية بنخلي الـ onChanged بـ null
            onChanged: isEmpty ? null : onChanged,
          ),
        ),
      ],
    );
  }
}