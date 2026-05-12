import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/features/visit_flow/data/repositories/visit_repository_impl.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/end_visit_usecase.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/verify_visit_location_usecase.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/core/widgets/custom_snackbar_widget.dart';
import 'package:medical_rep/features/visit_flow/viewmodels/active_visit/active_visit_state.dart';
import 'package:medical_rep/features/visit_flow/views/visit_feedback_screen.dart';
import '../models/visit_model.dart';
import '../viewmodels/active_visit/active_visit_cubit.dart';
import 'widgets/visit_info_card.dart';
import 'widgets/visit_timer_widget.dart';
import 'widgets/visit_location_card.dart';
import 'widgets/visit_tasks_card.dart';
import 'widgets/visit_notes_field.dart';
import 'widgets/visit_sample_card.dart';

class ActiveVisitScreen extends StatelessWidget {
  final VisitModel visit;

  const ActiveVisitScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = VisitRepositoryImpl();
        return ActiveVisitCubit(
          verifyVisitLocation: VerifyVisitLocationUseCase(repository),
          endVisit: EndVisitUseCase(repository),
          visit: visit,
        );
      },
      child: _ActiveVisitView(visit: visit),
    );
  }
}

class _ActiveVisitView extends StatelessWidget {
  final VisitModel visit;

  const _ActiveVisitView({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocConsumer<ActiveVisitCubit, ActiveVisitState>(
        listenWhen: (prev, curr) => prev.isEndingVisit != curr.isEndingVisit,
        listener: (context, state) {
          if (!state.isEndingVisit) {
            final cubit = context.read<ActiveVisitCubit>();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VisitFeedbackScreen(
                  visitId: visit.visitId,
                  prefillSampleGiven: cubit.state.sampleGiven,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              const CustomAppBar(label: 'Active Visit'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const VisitTimerWidget(),
                      const SizedBox(height: 20),
                      const VisitLocationCard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Doctor & Clinic'),
                      const SizedBox(height: 12),
                      VisitInfoCard(visit: visit),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Task Checklist'),
                      const SizedBox(height: 12),
                      const VisitTasksCard(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Sample Tracking'),
                      const SizedBox(height: 12),
                      const VisitSampleCard(),
                      const SizedBox(height: 20),
                      const VisitNotesField(),
                      const SizedBox(height: 30),
                      _buildEndVisitButton(context, state),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.title.copyWith(color: AppColors.grayColor),
    );
  }

  Widget _buildEndVisitButton(BuildContext context, ActiveVisitState state) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.errorColor.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: state.isEndingVisit
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : ElevatedButton.icon(
        onPressed: () => _onEndVisitPressed(context, state),
        icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
        label: Text('End Visit',
            style: AppTextStyle.body.copyWith(color: AppColors.whiteColor)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
    );
  }

  void _onEndVisitPressed(BuildContext context, ActiveVisitState state) {
    if (state.taskProgress < 1.0) {
      AppSnackBar.showSuccess(
        context: context,
        title: 'Incomplete Tasks',
        message: 'Some tasks are not done. Are you sure you want to end the visit?',
      );
    }
    context.read<ActiveVisitCubit>().endVisit();
  }
}