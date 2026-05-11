import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import '../../viewmodels/active_visit/active_visit_cubit.dart';

class VisitNotesField extends StatelessWidget {
  const VisitNotesField({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ActiveVisitCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Real-time Notes', style: AppTextStyle.subtitle),
        const SizedBox(height: 12),
        TextField(
          controller: cubit.notesController,
          maxLines: 4,
          onChanged: cubit.updateNotes,
          decoration: InputDecoration(
            hintText: 'Add notes during the visit...',
            hintStyle: AppTextStyle.hint,
            fillColor: AppColors.whiteColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}