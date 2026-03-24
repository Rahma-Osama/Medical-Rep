import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';

class CustomDropdownWidget extends StatelessWidget {
    CustomDropdownWidget({super.key,required this.label, required this.icon, this.value, required this.items, required this.onChanged});
 final String label;
  final  IconData icon;
   final String? value;
   final List<String> items;
  final  Function(String?) onChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
        DropdownButtonHideUnderline(
          
          child: DropdownButton<String>(
            dropdownColor: AppColors.backgroundColor,
            value: value,
            isExpanded: true,
            hint: const Text("Tap to select"),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );;
  }
}
