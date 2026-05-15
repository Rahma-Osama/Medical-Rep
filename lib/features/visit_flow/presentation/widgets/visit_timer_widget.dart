import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_state.dart';

class VisitTimerWidget extends StatelessWidget {
  const VisitTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveVisitCubit, ActiveVisitState>(
      buildWhen: (prev, curr) => prev.tick != curr.tick,
      builder: (context, state) {
        final cubit = context.read<ActiveVisitCubit>();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                'Visit Duration',
                style: AppTextStyle.hint.copyWith(
                  color: AppColors.whiteColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                cubit.formattedTime,
                style: AppTextStyle.appName.copyWith(
                  color: AppColors.whiteColor,
                  fontSize: 42,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Started at ${_formatStartTime(cubit.visit.startTime)}',
                style: AppTextStyle.hint.copyWith(
                  color: AppColors.whiteColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatStartTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}