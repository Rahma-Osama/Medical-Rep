import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/data/repositeries/weekly_plan_repository.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/core/widgets/custom_button_widget.dart';
import 'package:medical_rep/core/widgets/custom_snackbar_widget.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_state.dart';

import 'package:medical_rep/features/weekly_planning/views/widgets/custom_days_tab.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/custom_dropdown_widget.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/segmented_controll_widget.dart';
import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. توفير الـ Cubit للصفحة بالكامل
    return BlocProvider(
      create: (context) => WeeklyPlanCubit(WeeklyPlanRepository()),
      child: BlocConsumer<WeeklyPlanCubit, WeeklyPlanState>(
        // 2. الـ Listener للعمليات التي تحدث مرة واحدة (Navigation / SnackBar)
        listener: (context, state) {
          if (state is WeeklyPlanSuccess) {
            AppSnackBar.showSuccess(
              context: context,
              title: "Full Plan Submitted!",
              message: "Your weekly schedule is sent for approval.",
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WeeklyPlanningView()),
            );
          } else if (state is WeeklyPlanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        // 3. الـ Builder لبناء الـ UI بناءً على الحالة الحالية
        builder: (context, state) {
          // الوصول للـ Cubit لإرسال الأوامر
          final cubit = context.read<WeeklyPlanCubit>();

          // التأكد من وجود البيانات قبل الرسم
          if (state is! WeeklyPlanUpdated) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: CustomScrollView(
              slivers: [
                const CustomAppBar(label: 'Plan Weekly Visit'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Select Day"),
                        const SizedBox(height: 12),
                        
                        // شريط الأيام المربوط بالـ Cubit
                        CustomDaysTab(
                          selectedIndex: state.selectedDayIndex,
                          weeklyData: state.weeklyData,
                          onDaySelected: (index) => cubit.selectDay(index),
                        ),

                        const SizedBox(height: 25),
                        _buildSectionTitle(
                            "Visit for ${cubit.weekDays[state.selectedDayIndex]}"),
                        const SizedBox(height: 12),

                        // كارت إدخال البيانات (نفس تصميمك الأصلي)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blackColor.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // اختيار المنطقة
                            CustomDropdownWidget(
                                label: "Select Brick",
                                icon: Icons.location_city_outlined,
                                value: state.weeklyData[state.selectedDayIndex]?["brick"],
                                items: const ["Maadi", "Nasr City", "Dokki"],
                                onChanged: (val) => cubit.updateField("brick", val),
                              ),
                              const Divider(height: 30),
                              
                              // Dropdown الدكتور (بيفلتر آلياً)
                              CustomDropdownWidget(
                                label: "Select Doctor",
                                icon: Icons.person_search_outlined,
                                value: state.weeklyData[state.selectedDayIndex]?["doctor"],
                                items: cubit.getFilteredDoctors(), // هنا الفلترة
                                onChanged: (val) => cubit.updateField("doctor", val),
                              ),
                              const SizedBox(height: 25),

                              // التوقيت والنوع
                              Row(
                                children: [
                                  Expanded(
                                    child: SegmentedControllWidget(
                                      label: "Shift",
                                      option: const ["AM", "PM"],
                                      selected: state.weeklyData[state.selectedDayIndex]?["shift"],
                                      onSelected: (val) => cubit.updateField("shift", val),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SegmentedControllWidget(
                                      label: "Visit Type",
                                      option: const ["Single", "Double"],
                                      selected: state.weeklyData[state.selectedDayIndex]?["type"],
                                      onSelected: (val) => cubit.updateField("type", val),
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
                          onChanged: (val) => cubit.updateField("notes", val),
                          decoration: InputDecoration(
                            hintText:
                                "Add specific details for ${cubit.weekDays[state.selectedDayIndex]}...",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // زر الحفظ النهائي المربوط بحالة التحميل
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: state is WeeklyPlanLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomElevatedButton(
  text: "Submit Plan",
  onPressed: () {
    if (cubit.isPlanComplete) {
      cubit.submitPlan();
    } else {
      AppSnackBar.showError(
        context: context, 
        message: "Please complete all 5 days of your plan first!",
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
        },
      ),
    );
  }

  // ميثود مساعدة لبناء العنوان (نفس اللي كانت عندك)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.title.copyWith(color: AppColors.grayColor),
    );
  }
}