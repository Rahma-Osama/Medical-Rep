import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_state.dart';


class VisitLocationCard extends StatelessWidget {
  const VisitLocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveVisitCubit, ActiveVisitState>(
      buildWhen: (prev, curr) => prev.locationStatus != curr.locationStatus,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _backgroundColor(state.locationStatus),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor(state.locationStatus), width: 0.5),
          ),
          child: Row(
            children: [
              Icon(_icon(state.locationStatus), color: _iconColor(state.locationStatus), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location Verification',
                        style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(_statusText(state.locationStatus),
                        style: AppTextStyle.hint.copyWith(color: _iconColor(state.locationStatus))),
                  ],
                ),
              ),
              if (state.locationStatus == LocationStatus.failed)
                TextButton(
                  onPressed: () => context.read<ActiveVisitCubit>().verifyLocation(),
                  child: Text('Retry',
                      style: AppTextStyle.hint.copyWith(color: AppColors.errorColor)),
                ),
              if (state.locationStatus == LocationStatus.verifying)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _backgroundColor(LocationStatus status) {
    switch (status) {
      case LocationStatus.verified:
        return Colors.green.withOpacity(0.08);
      case LocationStatus.failed:
        return AppColors.errorColor.withOpacity(0.08);
      default:
        return AppColors.lightgrayColor;
    }
  }

  Color _borderColor(LocationStatus status) {
    switch (status) {
      case LocationStatus.verified:
        return Colors.green.withOpacity(0.3);
      case LocationStatus.failed:
        return AppColors.errorColor.withOpacity(0.3);
      default:
        return AppColors.grayColor.withOpacity(0.2);
    }
  }

  Color _iconColor(LocationStatus status) {
    switch (status) {
      case LocationStatus.verified:
        return Colors.green;
      case LocationStatus.failed:
        return AppColors.errorColor;
      default:
        return AppColors.grayColor;
    }
  }

  IconData _icon(LocationStatus status) {
    switch (status) {
      case LocationStatus.verified:
        return Icons.verified_outlined;
      case LocationStatus.failed:
        return Icons.location_off_outlined;
      default:
        return Icons.location_searching_outlined;
    }
  }

  String _statusText(LocationStatus status) {
    switch (status) {
      case LocationStatus.verified:
        return 'You are at the clinic location';
      case LocationStatus.failed:
        return 'Could not verify your location';
      case LocationStatus.verifying:
        return 'Verifying your location...';
      default:
        return 'Tap to verify location';
    }
  }
}