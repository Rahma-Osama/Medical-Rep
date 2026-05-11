import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // ✅ ملاحظة: شيلنا الـ BlocProvider من هنا لأنه موجود في الـ main.dart
    return BlocConsumer<WeeklyPlanCubit, WeeklyPlanState>(
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
          AppSnackBar.showError(context: context, message: state.message);
        }
      },
      builder: (context, state) {
        final cubit = context.read<WeeklyPlanCubit>();

        // التأكد من أن الحالة هي Updated للوصول للبيانات
        if (state is! WeeklyPlanUpdated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final currentVisit = state.weeklyData[state.selectedDayIndex];

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
                      CustomDaysTab(
                        selectedIndex: state.selectedDayIndex,
                        weeklyData: state.weeklyData,
                        onDaySelected: (index) => cubit.selectDay(index),
                      ),
                      const SizedBox(height: 25),
                      _buildSectionTitle("Visit for ${cubit.weekDays[state.selectedDayIndex]}"),
                      const SizedBox(height: 12),
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
                            // ✅ تعديل: الوصول للبيانات عبر الـ Entity (currentVisit.brick)
                            CustomDropdownWidget(
                              label: "Select Brick",
                              icon: Icons.location_city_outlined,
                              value: currentVisit?.brick,
                              items: const ["Maadi", "Nasr City", "Dokki"],
                              onChanged: (val) => cubit.updateField("brick", val),
                            ),
                            const Divider(height: 30),
                            CustomDropdownWidget(
                              label: "Select Doctor",
                              icon: Icons.person_search_outlined,
                              value: currentVisit?.doctor,
                              items: cubit.getFilteredDoctors(),
                              onChanged: (val) => cubit.updateField("doctor", val),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: SegmentedControllWidget(
                                    label: "Shift",
                                    option: const ["AM", "PM"],
                                    selected: currentVisit?.shift ?? "AM",
                                    onSelected: (val) => cubit.updateField("shift", val),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SegmentedControllWidget(
                                    label: "Visit Type",
                                    option: const ["Single", "Double"],
                                    selected: currentVisit?.type ?? "Single",
                                    onSelected: (val) => cubit.updateField("type", val),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Additional Notes"),
                      const SizedBox(height: 12),
                      TextField(
                        maxLines: 3,
                        onChanged: (val) => cubit.updateField("notes", val),
                        decoration: InputDecoration(
                          hintText: "Add details for ${cubit.weekDays[state.selectedDayIndex]}...",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: state is WeeklyPlanLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomElevatedButton(
                                text: "Submit Plan",
                                onPressed: () => cubit.submitPlan(),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.title.copyWith(color: AppColors.grayColor, fontSize: 16),
    );
  }
}