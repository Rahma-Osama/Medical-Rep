import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_states.dart';

class FeedbackFollowUpCard extends StatelessWidget {
  const FeedbackFollowUpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisitFeedbackCubit, VisitFeedbackState>(
      builder: (context, state) {
        final cubit = context.read<VisitFeedbackCubit>();

        bool isSampleGiven = false;

        if (state is VisitFeedbackState) {
          isSampleGiven = state.sampleGiven;
        } else {
          // هنا بنعتمد على المتغير المخزن داخل الكيوبت نفسه كمرجع ثابت
          isSampleGiven = state.sampleGiven;
        }

        return Container(
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
              _buildToggleRow(
                icon: Icons.science_outlined,
                title: 'Sample Given',
                subtitle: 'A product sample was provided',
                value: isSampleGiven,
                onChanged: (_) => cubit.toggleSample(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: value
                ? AppColors.primaryColor.withOpacity(0.1)
                : AppColors.lightgrayColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: value ? AppColors.primaryColor : AppColors.grayColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: AppTextStyle.hint.copyWith(color: AppColors.grayColor),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
        ),
      ],
    );
  }
}