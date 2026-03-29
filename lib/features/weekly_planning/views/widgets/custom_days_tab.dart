import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';

class CustomDaysTab extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDaySelected;
  final Map<int, Map<String, dynamic>> weeklyData; // بنمرر الداتا عشان نرسم علامة الصح

  const CustomDaysTab({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> weekDays = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu"];

    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          // لو اليوم فيه دكتور ومنتج مختارين، نعتبره خلص
          bool isDayCompleted = weeklyData[index]?["doctor"] != null && 
                               weeklyData[index]?["product"] != null;

          return GestureDetector(
            onTap: () => onDaySelected(index), // بننادي الفانكشن اللي جاية من الشاشة الكبيرة
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: isSelected 
                    ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                    : [],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      weekDays[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // علامة الصح تظهر لو اليوم خلص ومش واقفين عليه حالياً
                  if (isDayCompleted)
                    const Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
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