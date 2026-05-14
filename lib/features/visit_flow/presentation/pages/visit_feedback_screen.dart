import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/services/connectivity_service.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/visit_local_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/remote/visit_remote_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/repoetries/visit_repo_impl.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/visit_feedback/visit_feedback_states.dart';
import 'package:medical_rep/features/visit_flow/presentation/widgets/feedback_followup_card.dart';
import 'package:medical_rep/features/visit_flow/presentation/widgets/feedback_interest_selector.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/visit_flow/domain/usecases/visit_usecases.dart';

import '../widgets/feedback_attachments_card.dart';

class VisitFeedbackScreen extends StatelessWidget {
  final String visitId;
  final String doctorName;
  final String clinicName;
  final bool prefillSampleGiven;

  const VisitFeedbackScreen({
    super.key,
    required this.visitId,
    required this.prefillSampleGiven,
    required this.doctorName,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        // نصيحة: يفضل مستقبلاً استخدام GetIt لعمل Dependency Injection بدل التعريف اليدوي هنا
        final remoteDataSource = VisitRemoteDataSourceImpl();
        final local = VisitLocalDataSourceImpl();
        final connectivity = ConnectivityService();
        final repository = VisitRepositoryImpl(remoteDataSource, local, connectivity);

        return VisitFeedbackCubit(
          // الآن سيتم التعرف على الـ UseCase بشكل صحيح لأنه مستورد من الملف الموحد
          submitVisitFeedback: SubmitVisitFeedbackUseCase(repository),
          visitId: visitId,
          prefillSampleGiven: prefillSampleGiven,
          doctorName: doctorName,
          clinicName: clinicName,
        );
      },
      child: const _VisitFeedbackView(),
    );
  }
}

class _VisitFeedbackView extends StatefulWidget {
  const _VisitFeedbackView();

  @override
  State<_VisitFeedbackView> createState() => _VisitFeedbackViewState();
}

class _VisitFeedbackViewState extends State<_VisitFeedbackView> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocListener<VisitFeedbackCubit, VisitFeedbackState>(
        listenWhen: (prev, curr) =>
        prev.isSuccess != curr.isSuccess || prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report Submitted Successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.popUntil(context, (route) => route.isFirst);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
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
                  key: _formKey,
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
                      _buildNotesField(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Attachments'),
                      const SizedBox(height: 12),
                      const FeedbackAttachmentsCard(),
                      const SizedBox(height: 30),
                      _buildSubmitButton(),
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 5,
      validator: (val) =>
      (val == null || val.trim().isEmpty) ? 'Please add visit notes' : null,
      decoration: InputDecoration(
        hintText: 'Describe the visit outcome...',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<VisitFeedbackCubit, VisitFeedbackState>(
      buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 60,
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context
                    .read<VisitFeedbackCubit>()
                    .submitFeedback(_notesController.text);
              }
            },
            child: const Text('Submit Report'),
          ),
        );
      },
    );
  }
}