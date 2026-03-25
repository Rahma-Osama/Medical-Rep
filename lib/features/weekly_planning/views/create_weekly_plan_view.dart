import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';
import 'package:medical_rep/core/widgets/custom_button_widget.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/custom_days_tab.dart';

import 'package:medical_rep/features/weekly_planning/views/widgets/custom_dropdown_widget.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/custom_snackbar_widget.dart';
// تأكدي من اسم الملف
import 'package:medical_rep/features/weekly_planning/views/widgets/segmented_controll_widget.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  // 1. إدارة بيانات الأسبوع
  int selectedDayIndex = 0;
  final List<String> weekDays = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu"];

  // تخزين البيانات لكل يوم بشكل مستقل
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          //header
                    
CustomAppBar(label: 'Plan Weekly Visit',),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  _buildSectionTitle("Select Day"),
                  const SizedBox(height: 12),
                  //days tab
                  CustomDaysTab(),

                  const SizedBox(height: 25),
                  _buildSectionTitle("Visit Configuration for ${weekDays[selectedDayIndex]}"),
                  const SizedBox(height: 12),

                  // كارت البيانات الأساسي
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: AppColors.blackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // اختيار الدكتور
                        CustomDropdownWidget(
                          label: "Select Doctor",
                          icon: Icons.person_search_outlined,
                          value: _weeklyData[selectedDayIndex]?["doctor"],
                          items: const ["Dr. Ahmed Ali", "Dr. Sarah Mahmoud", "Dr. Mohamed Hassan", "Dr. Layla Ibrahim"],
                          onChanged: (val) => setState(() => _weeklyData[selectedDayIndex]?["doctor"] = val),
                        ),
                        const Divider(height: 30),

                        // اختيار المنتج (البريكا)
                        CustomDropdownWidget(
                          label: "Target Product",
                          icon: Icons.medication_outlined,
                          value: _weeklyData[selectedDayIndex]?["product"],
                          items: const ["Panadol", "Augmentin", "Cataflam", "Brufen"],
                          onChanged: (val) => setState(() => _weeklyData[selectedDayIndex]?["product"] = val),
                        ),
                        const SizedBox(height: 25),

                        // التوقيت والنوع
                        Row(
                          children: [
                            Expanded(
                              child: SegmentedControllWidget(
                                label: "Shift",
                                option: const ["AM", "PM"],
                                selected: _weeklyData[selectedDayIndex]?["shift"],
                                onSelected: (val) => setState(() => _weeklyData[selectedDayIndex]?["shift"] = val!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SegmentedControllWidget(
                                label: "Visit Type",
                                option: const ["Single", "Double"],
                                selected: _weeklyData[selectedDayIndex]?["type"],
                                onSelected: (val) => setState(() => _weeklyData[selectedDayIndex]?["type"] = val!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // قسم الملاحظات
                  _buildSectionTitle("Additional Notes"),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Add specific details for ${weekDays[selectedDayIndex]}...",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // زر الحفظ النهائي
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: CustomElevatedButton(
  text: "Submit Plan",
  onPressed: () {
    if (_completionRate < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all 6 days before submitting.")),
      );
    } else {
      AppSnackBar.showSuccess(
        context: context,
        title: "Full Plan Submitted!",
        message: "Your weekly schedule is sent for approval.",
      );
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const WeeklyPlanningView())
      );
    }
  },
),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت شريط الأيام

  Widget _buildSectionTitle(String title) {
    return Text(title, style:   AppTextStyle.title.copyWith(
                  color: AppColors.grayColor
                ));
  }
}