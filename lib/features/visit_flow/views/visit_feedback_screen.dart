import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/data/repositeries/visit_repository.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/core/widgets/custom_button_widget.dart';
import 'package:medical_rep/core/widgets/custom_snackbar_widget.dart';
import 'package:medical_rep/features/visit_flow/viewmodels/visit_feedback/visit_feedback_states.dart';
import 'package:medical_rep/features/visit_flow/views/widgets/feedback_interest_selector.dart';
import '../viewmodels/visit_feedback/visit_feedback_cubit.dart';
import 'widgets/feedback_followup_card.dart';
import 'widgets/feedback_attachments_card.dart';

class VisitFeedbackScreen extends StatelessWidget {
  final String visitId;
  final bool prefillSampleGiven;

  const VisitFeedbackScreen({
    super.key,
    required this.visitId,
    required this.prefillSampleGiven,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitFeedbackCubit(
        repository: VisitRepositoryImpl(),
        visitId: visitId,
        prefillSampleGiven: prefillSampleGiven,
      ),
      child: const _VisitFeedbackView(),
    );
  }
}

class _VisitFeedbackView extends StatelessWidget {
  const _VisitFeedbackView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VisitFeedbackCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocListener<VisitFeedbackCubit, VisitFeedbackState>(
        listener: (context, state) {
          if (state is VisitFeedbackSuccess) {
            AppSnackBar.showSuccess(
              context: context,
              title: 'Report Submitted!',
              message: 'Your visit feedback has been saved.',
            );
            Navigator.popUntil(context, (route) => route.isFirst);
          }
          if (state is VisitFeedbackFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorColor,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            const CustomAppBar(label: 'Visit Feedback'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Interest Level'),
                      const SizedBox(height: 12),
                      const FeedbackInterestSelector(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Visit Outcome'),
                      const SizedBox(height: 12),
                      const FeedbackFollowUpCard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Detailed Notes'),
                      const SizedBox(height: 12),
                      _buildNotesField(cubit),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Attachments'),
                      const SizedBox(height: 12),
                      const FeedbackAttachmentsCard(),
                      const SizedBox(height: 30),
                      _buildSubmitButton(context),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.title.copyWith(color: AppColors.grayColor),
    );
  }

  Widget _buildNotesField(VisitFeedbackCubit cubit) {
    return TextFormField(
      controller: cubit.notesController,
      maxLines: 5,
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Please add visit notes';
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Describe the visit outcome, doctor feedback, next steps...',
        hintStyle: AppTextStyle.hint,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<VisitFeedbackCubit, VisitFeedbackState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: state is VisitFeedbackLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : CustomElevatedButton(
            text: 'Submit Report',
            onPressed: () => context.read<VisitFeedbackCubit>().submitFeedback(),
          ),
        );
      },
    );
  }
}