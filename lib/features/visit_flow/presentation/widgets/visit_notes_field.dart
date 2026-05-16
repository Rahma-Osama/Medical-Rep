import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_cubit.dart';

class VisitNotesField extends StatefulWidget {
  const VisitNotesField({super.key});

  @override
  State<VisitNotesField> createState() => _VisitNotesFieldState();
}

class _VisitNotesFieldState extends State<VisitNotesField> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initialNotes = context.read<ActiveVisitCubit>().state.notes;
    _notesController = TextEditingController(text: initialNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Real-time Notes', style: AppTextStyle.subtitle),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          onChanged: (value) => context.read<ActiveVisitCubit>().updateNotes(value),
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