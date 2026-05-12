import 'package:flutter/material.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/features/home/views/widgets/home_bottom_navigation_bar.dart';
import 'package:medical_rep/features/home/views/widgets/home_header_section.dart';
import 'package:medical_rep/features/home/views/widgets/home_profile_progress_card.dart';
import 'package:medical_rep/features/home/views/widgets/home_recent_visits_section.dart';
import 'package:medical_rep/features/home/views/widgets/home_services_section.dart';
import 'package:medical_rep/features/home/views/widgets/home_stats_row.dart';
import 'package:medical_rep/features/profile/views/profile_screen.dart';
import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.userName = 'Ahmed Elsayed',
    this.roleLine = 'Senior Medical Rep · Region 4',
    this.regionLabel = 'Region 4',
    this.email = 'ahmed.elsayed@pharma',
    this.repId = 'MR-2024-0042',
  });

  final String userName;
  final String roleLine;
  final String regionLabel;
  final String email;
  final String repId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  static final List<HomeRecentVisitItem> _sampleVisits = [
    HomeRecentVisitItem(
      leadingIcon: Icons.medical_services_outlined,
      title: 'Dr. Sara Hassan',
      subtitle: 'Cardiologist · 9:30 AM',
      statusLabel: 'Completed',
    ),
    HomeRecentVisitItem(
      leadingIcon: Icons.medication_outlined,
      title: 'Al-Noor Pharmacy',
      subtitle: 'Pharmacy Visit · 11:00 AM',
      statusLabel: 'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final stackHeight = topInset + 200+20;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildHomeScroll(context, topInset, stackHeight),
          _placeholderTab('Visits'),
          _planningTab(context),
          _placeholderTab('Reports'),
          const ProfileScreen(
            showBackButton: false,
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  Widget _buildHomeScroll(BuildContext context, double topInset, double stackHeight) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: stackHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                HomeHeaderSection(
                  greeting: 'Good Morning',
                  userName: widget.userName,
                  roleLine: widget.roleLine,
                  notificationCount: 2,
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 118 + topInset,
                  child: HomeProfileProgressCard(
                    email: widget.email,
                    repId: widget.repId,
                    onProfile: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    onQrTap: () {},
                    onSummaryTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WeeklyPlanningView(),
                        ),
                      );
                    },
                    onTargetTap: () {},
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                HomeStatsRow(
                  visitsToday: 6,
                  visitsPlanned: 10,
                  pendingDrafts: 3,
                  weekVisitsDone: 28,
                  onDraftsTap: () => setState(() => _navIndex = 1),
                ),
                const SizedBox(height: 24),
                HomeServicesSection(
                  onViewAll: () {},
                  onDoctorsList: () {},
                  onPharmacyList: () {},
                  onWeeklyPlanning: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CreatePlanScreen(),
                      ),
                    );
                  },
                  onDrafts: () => setState(() => _navIndex = 1),
                ),
                const SizedBox(height: 28),
                HomeRecentVisitsSection(
                  items: _sampleVisits,
                  onSeeAll: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planningTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Planning',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreatePlanScreen(),
                  ),
                );
              },
              child: const Text('Open weekly plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderTab(String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
