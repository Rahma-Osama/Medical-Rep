import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/services/connectivity_service.dart';
import 'package:medical_rep/core/utils/constants.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/visit_local_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/remote/visit_remote_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/models/visit_data_models.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/core/error/failure_ui_extension.dart';
import 'package:medical_rep/core/widgets/custom_snackbar_widget.dart';
import 'package:medical_rep/features/visit_flow/data/repoetries/visit_repo_impl.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/visit_usecases.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_state.dart';
import 'package:medical_rep/features/visit_flow/presentation/pages/visit_feedback_screen.dart';
import 'package:medical_rep/features/visit_flow/presentation/widgets/visit_info_card.dart';
import 'package:medical_rep/features/visit_flow/presentation/widgets/visit_notes_field.dart';
import 'package:medical_rep/features/visit_flow/presentation/widgets/visit_sample_card.dart';
import 'package:medical_rep/features/visit_flow/presentation/widgets/visit_timer_widget.dart';


class ActiveVisitScreen extends StatelessWidget {
  final VisitModel visit;

  const ActiveVisitScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final remoteDataSource = VisitRemoteDataSourceImpl();
        final localDataSource = VisitLocalDataSourceImpl();
        final connectivityService = ConnectivityService();
        final repository = VisitRepositoryImpl(
          remoteDataSource,
          localDataSource,
          connectivityService,
        );
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
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitDialog(context);
        return shouldExit;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: BlocConsumer<ActiveVisitCubit, ActiveVisitState>(
          listenWhen: (prev, curr) =>
              prev.failure != curr.failure ||
              (!prev.visitEndedSuccessfully && curr.visitEndedSuccessfully),
          listener: (context, state) {
            if (state.visitEndedSuccessfully) {
              final cubit = context.read<ActiveVisitCubit>();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VisitFeedbackScreen(
                    visitId: visit.visitId,
                    prefillSampleGiven: cubit.state.sampleGiven,
                    doctorName: visit.doctorName,
                    clinicName: visit.clinicName,
                  ),
                ),
              );
              return;
            }
            final failure = state.failure;
            if (failure != null) {
              final cubit = context.read<ActiveVisitCubit>();
              failure.showFailureDialog(
                context,
                onRetry: () {
                  if (state.locationStatus == LocationStatus.failed) {
                    cubit.verifyLocation();
                  } else {
                    cubit.endVisit();
                  }
                },
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
                        _buildSectionTitle('Doctor & Clinic'),
                        const SizedBox(height: 12),
                        VisitInfoCard(visit: visit),
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
    final cubit = context.read<ActiveVisitCubit>();

    if (cubit.elapsed.inSeconds < MIN_VISIT_TIME) {
      AppSnackBar.showError(
        context: context,
        message: 'visit time is not acceptable',
      );
      return;
    }

    context.read<ActiveVisitCubit>().endVisit();
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final cubit = context.read<ActiveVisitCubit>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("End Visit?"),
          content: const Text(
            "If you leave now, the visit will be ended. Do you want to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                cubit.endVisit();
                Navigator.pop(dialogContext, true);
              },
              child: const Text("End Visit"),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }}