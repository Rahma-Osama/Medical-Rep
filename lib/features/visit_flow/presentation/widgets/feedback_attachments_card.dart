import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_states.dart';

class FeedbackAttachmentsCard extends StatelessWidget {
  const FeedbackAttachmentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisitFeedbackCubit, VisitFeedbackState>(
      builder: (context, state) {
        final current = state as VisitFeedbackInitial;
        final cubit = context.read<VisitFeedbackCubit>();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Attachments', style: AppTextStyle.subtitle),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: integrate file picker
                      cubit.addAttachment('file_${DateTime.now().millisecondsSinceEpoch}.jpg');
                    },
                    icon: Icon(Icons.add, size: 18, color: AppColors.primaryColor),
                    label: Text('Add', style: AppTextStyle.body.copyWith(color: AppColors.primaryColor)),
                  ),
                ],
              ),
              if (current.attachmentPaths.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('No attachments added',
                        style: AppTextStyle.hint.copyWith(color: AppColors.grayColor)),
                  ),
                )
              else
                ...current.attachmentPaths.asMap().entries.map(
                      (entry) => _buildAttachmentItem(context, entry.key, entry.value, cubit),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem(
      BuildContext context, int index, String path, VisitFeedbackCubit cubit) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightgrayColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(path, style: AppTextStyle.hint, overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: AppColors.grayColor),
            onPressed: () => cubit.removeAttachment(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}