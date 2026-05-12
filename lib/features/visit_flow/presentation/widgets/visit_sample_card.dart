import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_state.dart';

class VisitSampleCard extends StatelessWidget {
  const VisitSampleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveVisitCubit, ActiveVisitState>(
      buildWhen: (prev, curr) => prev.sampleGiven != curr.sampleGiven,
      builder: (context, state) {
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: state.sampleGiven
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : AppColors.lightgrayColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.science_outlined,
                  color: state.sampleGiven ? AppColors.primaryColor : AppColors.grayColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sample Provided', style: AppTextStyle.subtitle),
                    Text(
                      state.sampleGiven ? 'Sample was given' : 'No sample given',
                      style: AppTextStyle.hint.copyWith(color: AppColors.grayColor),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.sampleGiven,
                onChanged: (_) => context.read<ActiveVisitCubit>().toggleSample(),
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}