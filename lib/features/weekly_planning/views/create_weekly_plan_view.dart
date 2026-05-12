import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/core/widgets/custom_button_widget.dart';
import 'package:medical_rep/core/widgets/custom_snackbar_widget.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_cubit.dart';
import 'package:medical_rep/features/weekly_planning/cubit/weekly_plan_state.dart';
import 'package:medical_rep/features/weekly_planning/domain/entities/visit_entity.dart'; // تأكدي من الاستيراد
import 'package:medical_rep/features/weekly_planning/views/widgets/custom_days_tab.dart';
import 'package:medical_rep/features/weekly_planning/views/widgets/custom_dropdown_widget.dart';
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

        if (state is! WeeklyPlanUpdated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // جلب قائمة الزيارات لليوم المختار حالياً مع معالجة الـ null
        final currentDayVisits = state.weeklyData[state.selectedDayIndex] ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              const CustomAppBar(label: 'Plan Weekly Visit'),
              
              // تم دمج كل محتويات الصفحة في Sliver واحد لتجنب خطأ الـ RenderBox
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
                      
                      _buildSectionTitle("Add Visit to ${cubit.weekDays[state.selectedDayIndex]}"),
                      const SizedBox(height: 12),
                      _buildAddVisitForm(context, cubit, currentDayVisits),
                      
                      const SizedBox(height: 25),
                      
                      _buildSectionTitle("Added Visits (${currentDayVisits.length})"),
                      const SizedBox(height: 12),
                      _buildVisitsList(currentDayVisits, cubit),

                      const SizedBox(height: 40),
                      
                      // زر إرسال الخطة (أصبح جزءاً من الـ Column العادي)
                      state is WeeklyPlanLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomElevatedButton(
                              text: "Submit Entire Weekly Plan",
                              onPressed: currentDayVisits.isEmpty 
                                  ? null 
                                  : () => cubit.submitPlan(),
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

  // فورم إضافة زيارة واحدة
  Widget _buildAddVisitForm(BuildContext context, WeeklyPlanCubit cubit, List<VisitEntity> visits) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _containerDecoration(),
      child: Column(
        children: [
          CustomDropdownWidget(
            label: "Select Brick",
            icon: Icons.location_city_outlined,
            items: const ["Maadi", "Nasr City", "Dokki"],
            onChanged: (val) => cubit.tempUpdateField("brick", val),
          ),
          const Divider(height: 30),
          CustomDropdownWidget(
            label: "Select Doctor",
            icon: Icons.person_search_outlined,
            items: cubit.getFilteredDoctors(),
            onChanged: (val) {
              bool exists = visits.any((v) => v.doctor == val);
              if (exists) {
                AppSnackBar.showError(context: context, message: "This doctor is already added for today!");
              } else {
                cubit.tempUpdateField("doctor", val);
              }
            },
          ),
          const SizedBox(height: 20),
          CustomElevatedButton(
            text: "Add to Day List",
            onPressed: () => cubit.addVisitToDay(),
          ),
        ],
      ),
    );
  }

  // عرض الزيارات المضافة كـ Cards
  Widget _buildVisitsList(List<VisitEntity> visits, WeeklyPlanCubit cubit) {
    if (visits.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("No visits added for this day yet.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // لتعطيل السكرول الداخلي والاعتماد على الأب
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: Text("${index + 1}", style: TextStyle(color: AppColors.primaryColor)),
            ),
            title: Text(visit.doctor ?? "Unknown Doctor", style: AppTextStyle.body),
            subtitle: Text("${visit.brick} | ${visit.shift} | ${visit.type}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
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
      style: AppTextStyle.title.copyWith(color: Colors.blueGrey, fontSize: 16),
    );
  }
}