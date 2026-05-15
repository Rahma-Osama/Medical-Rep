import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/services/connectivity_service.dart';
import 'package:medical_rep/core/services/sync_service.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/core/styles/app_text_style.dart';
import 'package:medical_rep/core/widgets/custom_app_bar.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/local/visit_local_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/datasources/remote/visit_remote_datasource.dart';
import 'package:medical_rep/features/visit_flow/data/repoetries/visit_repo_impl.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/pending_visits/pending_visits_cubit.dart';
import 'package:medical_rep/features/visit_flow/presentation/cubits/pending_visits/pending_visits_states.dart';
import 'package:medical_rep/features/visit_flow/domain/entities/pending_feedback_entity.dart';
import 'package:intl/intl.dart';


class PendingVisitsScreen extends StatelessWidget {
  const PendingVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final remote = VisitRemoteDataSourceImpl();
        final local = VisitLocalDataSourceImpl();
        final connectivity = ConnectivityService();
        final repo = VisitRepositoryImpl(remote, local, connectivity);
        final sync = SyncService(
          local: local,
          remote: remote,
          connectivity: connectivity,
        );
        return PendingVisitsCubit(repository: repo, syncService: sync);
      },
      child: const _PendingVisitsView(),
    );
  }
}

class _PendingVisitsView extends StatelessWidget {
  const _PendingVisitsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(label: 'Pending Visits'),
          SliverToBoxAdapter(
            child: BlocBuilder<PendingVisitsCubit, PendingVisitsState>(
              builder: (context, state) {
                if (state is PendingVisitsLoading ||
                    state is PendingVisitsSyncing) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is PendingVisitsError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is PendingVisitsLoaded) {
                  if (state.items.isEmpty) return _buildEmptyState();
                  return _buildList(context, state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, PendingVisitsLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Banner تحذيري
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${state.items.length} visit(s) waiting to sync',
                    style: AppTextStyle.body.copyWith(
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // زرار Sync
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<PendingVisitsCubit>().syncNow(),
              icon: const Icon(Icons.sync, color: Colors.white),
              label: Text(
                'Sync Now',
                style: AppTextStyle.body.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _PendingCard(item: state.items[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cloud_done_outlined, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'All visits are synced!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<PendingVisitsCubit>().loadPending(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final PendingFeedbackEntity item;
  const _PendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.hourglass_top,
                color: Colors.orange.shade700, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.doctorName, style: AppTextStyle.title),
                const SizedBox(height: 4),
                Text(item.clinicName,
                    style: AppTextStyle.body
                        .copyWith(color: AppColors.grayColor)),
              ],
            ),
          ),
          Text(
            DateFormat('dd MMM\nhh:mm a').format(item.submittedAt),
            textAlign: TextAlign.end,
            style: AppTextStyle.hint,
          ),
        ],
      ),
    );
  }
}