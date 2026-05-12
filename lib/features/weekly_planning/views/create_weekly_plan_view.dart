import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/core/widgets/custom_button_widget.dart';
import 'package:medical_rep/core/widgets/custom_snackbar_widget.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_state.dart';
import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/custom_days_tab.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/custom_dropdown_widget.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/segmented_controll_widget.dart'; 
import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeeklyPlanCubit, WeeklyPlanState>(
      listener: (context, state) {
        if (state is WeeklyPlanSuccess) {
          AppSnackBar.showSuccess(
            context: context,
            title: "Full Plan Submitted!",
            message: "Plan Submitted Successfully! Waiting for approval.",
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WeeklyPlanningView()),
          );
        } else if (state is WeeklyPlanError) {
          AppSnackBar.showError(context: context, message: state.message);
        }
      },
      builder: (context, state) {
        final cubit = context.read<WeeklyPlanCubit>();

        if (state is! WeeklyPlanUpdated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // جلب قائمة الزيارات لليوم المختار حالياً
        final currentDayVisits = state.weeklyData[state.selectedDayIndex] ?? [];

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
                      // 1. اختيار اليوم (التعديل اللي عملناه لليست)
                      _buildSectionTitle("Select Day"),
                      const SizedBox(height: 12),
                      CustomDaysTab(
                        selectedIndex: state.selectedDayIndex,
                        weeklyData: state.weeklyData,
                        onDaySelected: (index) => cubit.selectDay(index),
                      ),
                      const SizedBox(height: 25),

                      // 2. الفورم الأصلي بتاعك (زي ما هو بالظبط)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: _containerDecoration(),
                        child: Column(
                          children: [
                            // 1. Dropdown المنطقة (Brick/Area)
CustomDropdownWidget(
  label: "Select Brick", // المسمى في الـ UI
  icon: Icons.location_city_outlined,
  items: context.read<WeeklyPlanCubit>().allBricks, // دي اللي شايلة الـ area_name حالياً
  value: state.tempVisit.brick,
  onChanged: (val) => cubit.tempUpdateField("brick", val),
),
const Divider(height: 30),

// 2. Dropdown الدكتور (Doctor)
CustomDropdownWidget(
  label: "Select Doctor",
  icon: Icons.person_search_outlined,
  // التأكد من عرض رسالة تنبيه إذا لم يتم اختيار منطقة بعد

  // استخدام القائمة المفلترة من الـ Cubit
  items: context.read<WeeklyPlanCubit>().filteredDoctors, 
  value: state.tempVisit.doctor,
  onChanged: (val) => cubit.tempUpdateField("doctor", val),
),
                            const SizedBox(height: 20),
                            
                    
                            SegmentedControllWidget(
                              label: "Select Shift",
                              option: const ["AM", "PM"],
                              selected: state.tempVisit.shift,
                              onSelected: (val) => cubit.tempUpdateField("shift", val!),
                            ),
                            const SizedBox(height: 20),
                            
                            SegmentedControllWidget(
                              label: "Visit Type",
                              option: const ["Single", "Double"],
                              selected: state.tempVisit.type,
                              onSelected: (val) => cubit.tempUpdateField("type", val!),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // زرار الإضافة للقائمة اليومية
                            CustomElevatedButton(
                              text: "Add Visit to Day",
                              onPressed: () => cubit.addVisitToDay(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),
                      
                      // 3. عرض قائمة الزيارات المضافة لليوم ده (الـ List اللي طلبتيها)
                      if (currentDayVisits.isNotEmpty) ...[
                        _buildSectionTitle("Current Day Visits"),
                        const SizedBox(height: 12),
                        _buildVisitsList(currentDayVisits, cubit),
                      ],

                      const SizedBox(height: 30),

                      // 4. زرار الإرسال النهائي للخطة كاملة
                      state is WeeklyPlanLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomElevatedButton(
                              text: "Submit Full Plan",
                             onPressed: !cubit.isPlanComplete ? null : () => cubit.submitPlan(),
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

  // ويدجت عرض القائمة (الـ List اللي بتظهر تحت الفورم)
  Widget _buildVisitsList(List<VisitEntity> visits, WeeklyPlanCubit cubit) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            title: Text(visit.doctor ?? "Unknown Doctor", style: AppTextStyle.body),
            subtitle: Text("${visit.brick} | ${visit.shift}"),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => cubit.removeVisitFromDay(index),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.title.copyWith(color: AppColors.grayColor, fontSize: 16),
    );
  }
}