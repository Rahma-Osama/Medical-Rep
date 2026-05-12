import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';

class CustomDaysTab extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDaySelected;

final Map<int, List<VisitEntity>> weeklyData;

  const CustomDaysTab({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> weekDays = ["Sat", "Sun", "Mon", "Tue", "Wed"];

    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          
          // شرط ظهور علامة الصح: لازم الدكتور والمنتج ميكونوش null في اليوم ده
       // داخل itemBuilder في ملف custom_days_tab.dart
// ✅ الطريقة الجديدة للتأكد من اكتمال اليوم (داخل الـ build بتاع الـ Tab)
// لازم نتأكد إن القائمة مش فاضية الأول، وبعدين نشوف لو كل اللي فيها سليم
bool isCompleted = (weeklyData[index]?.isNotEmpty ?? false) && 
                   (weeklyData[index]!.every((visit) => visit.isValid));

          return GestureDetector(
            onTap: () => onDaySelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 75,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primaryColor 
                      : (isCompleted ? Colors.green.shade300 : Colors.grey.shade300),
                  width: 1.5,
                ),
                boxShadow: isSelected 
                    ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] 
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    weekDays[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // أيقونة الصح (تظهر لو اليوم مكتمل)
                  if (isCompleted)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}