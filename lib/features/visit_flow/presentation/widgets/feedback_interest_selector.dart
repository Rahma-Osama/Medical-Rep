import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/visit_feedback.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_states.dart';

class FeedbackInterestSelector extends StatelessWidget {
  const FeedbackInterestSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisitFeedbackCubit, VisitFeedbackState>(
      builder: (context, state) {
        final current = state as VisitFeedbackState;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Doctor's Interest Level", style: AppTextStyle.subtitle),
              const SizedBox(height: 16),
              Row(
                children: DoctorInterestLevel.values
                    .map((level) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _InterestOption(
                      level: level,
                      isSelected: current.interestLevel == level,
                      onTap: () =>
                          context.read<VisitFeedbackCubit>().setInterestLevel(level),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InterestOption extends StatelessWidget {
  final DoctorInterestLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestOption({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _color : AppColors.lightgrayColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _color : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(_icon, color: isSelected ? AppColors.whiteColor : AppColors.grayColor, size: 20),
            const SizedBox(height: 4),
            Text(
              _label,
              style: AppTextStyle.hint.copyWith(
                color: isSelected ? AppColors.whiteColor : AppColors.grayColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _color {
    switch (level) {
      case DoctorInterestLevel.high:
        return Colors.green;
      case DoctorInterestLevel.medium:
        return Colors.orange;
      case DoctorInterestLevel.low:
        return AppColors.errorColor;
    }
  }

  IconData get _icon {
    switch (level) {
      case DoctorInterestLevel.high:
        return Icons.sentiment_very_satisfied_outlined;
      case DoctorInterestLevel.medium:
        return Icons.sentiment_neutral_outlined;
      case DoctorInterestLevel.low:
        return Icons.sentiment_dissatisfied_outlined;
    }
  }

  String get _label {
    switch (level) {
      case DoctorInterestLevel.high:
        return 'High';
      case DoctorInterestLevel.medium:
        return 'Medium';
      case DoctorInterestLevel.low:
        return 'Low';
    }
  }
}