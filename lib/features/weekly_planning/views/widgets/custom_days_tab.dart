import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';

class CustomDaysTab extends StatefulWidget {
  const CustomDaysTab({super.key});

  @override
  State<CustomDaysTab> createState() => _CustomDaysTabState();
}

class _CustomDaysTabState extends State<CustomDaysTab> {
       int selectedDayIndex = 0;
  final List<String> weekDays = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu"];
    final Map<int, Map<String, dynamic>> _weeklyData = {
    0: {"doctor": null, "product": null, "shift": "AM", "type": "Single", "isDone": false},
    1: {"doctor": null, "product": null, "shift": "AM", "type": "Single", "isDone": false},
    2: {"doctor": null, "product": null, "shift": "AM", "type": "Single", "isDone": false},
    3: {"doctor": null, "product": null, "shift": "AM", "type": "Single", "isDone": false},
    4: {"doctor": null, "product": null, "shift": "AM", "type": "Single", "isDone": false},
    5: {"doctor": null, "product": null, "shift": "AM", "type": "Single", "isDone": false},
  };

  // ميثود لحساب نسبة الإنجاز
  double get _completionRate {
    int completed = _weeklyData.values.where((day) => day["doctor"] != null && day["product"] != null).length;
    return completed / weekDays.length;
  }
  @override
  Widget build(BuildContext context) {
 
    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedDayIndex == index;
          bool hasData = _weeklyData[index]?["doctor"] != null;

          return GestureDetector(
            onTap: () => setState(() => selectedDayIndex = index),
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
                  if (hasData && !isSelected)
                    const Positioned(
                      top: 5,
                      right: 5,
                      child: Icon(Icons.check_circle, size: 14, color: Colors.green),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );;
  }
}