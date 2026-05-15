import 'package:flutter/material.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/features/home/data/home_dashboard_repository.dart';
import 'package:medical_rep/features/home/data/models/home_dashboard_snapshot.dart';
import 'package:medical_rep/features/home/views/widgets/home_bottom_navigation_bar.dart';
import 'package:medical_rep/features/home/views/widgets/home_header_section.dart';
import 'package:medical_rep/features/home/views/widgets/home_profile_progress_card.dart';
import 'package:medical_rep/features/home/views/widgets/home_recent_visits_section.dart';
import 'package:medical_rep/features/home/views/widgets/home_services_section.dart';
import 'package:medical_rep/features/home/views/widgets/home_stats_row.dart';
import 'package:medical_rep/features/profile/views/profile_screen.dart';
import 'package:medical_rep/features/visit_flow/presentation/pages/pending_visits_screen.dart';
import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  HomeDashboardSnapshot? _dashboard;
  bool _loadingDashboard = true;
  String? _dashboardError;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }


  Future<void> _loadDashboard() async {
    setState(() {
      _loadingDashboard = true;
      _dashboardError = null;
    });
    try {
      final data = await getIt<HomeDashboardRepository>().loadDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _loadingDashboard = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dashboardError = e.toString();
        _loadingDashboard = false;
      });
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final stackHeight = topInset + 200 + 20;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: _navIndex,
        children: [
          // Tab 0: Home Page
          _buildHomeScroll(context, topInset, stackHeight),

          const WeeklyPlanningView(),

   
          const CreatePlanScreen(),

          // Tab 3: Reports
          _placeholderTab('Reports'),

          // Tab 4: Profile Page
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

  Widget _buildHomeScroll(
    BuildContext context,
    double topInset,
    double stackHeight,
  ) {
    final profile = _dashboard?.profile;
    final userName = profile?.fullName ?? '…';
    final roleLine = profile != null
        ? '${profile.roleTitle} · ${profile.regionLabel}'
        : '…';
    final email = profile?.email ?? '…';
    final repId = profile?.repId ?? '…';

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: stackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  HomeHeaderSection(
                    greeting: _greeting(),
                    userName: userName,
                    roleLine: roleLine,
                    notificationCount: 0,
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 118 + topInset,
                    child: HomeProfileProgressCard(
                      email: email,
                      repId: repId,
                      onProfile: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      onQrTap: () {},
                      onSummaryTap: () {
                        // عند الضغط على ملخص الكارد يفتح صفحة عرض الخطة
                        setState(() => _navIndex = 1);
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
                  if (_dashboardError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Could not load dashboard: $_dashboardError',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.errorColor,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (_loadingDashboard && _dashboard == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    HomeStatsRow(
                      visitsToday: _dashboard?.visitsDoneToday ?? 0,
                      visitsPlanned: _dashboard?.visitsPlannedToday ?? 0,
                      pendingDrafts: _dashboard?.pendingDrafts ?? 0,
                      weekVisitsDone: _dashboard?.weekVisitsDone ?? 0,
                      onDraftsTap: () => setState(() => _navIndex = 1),
                    ),
                  const SizedBox(height: 24),
                  HomeServicesSection(
                    onViewAll: () {},
                    onDoctorsList: () {},
                    onPharmacyList: () {},
                    onWeeklyPlanning: () {
                      // عند الضغط على Weekly Planning من الخدمات يفتح صفحة الإنشاء
                      setState(() => _navIndex = 2);
                    },
                    onDrafts: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const PendingVisitsScreen()));
                    },
                  ),
                  const SizedBox(height: 28),
                  HomeRecentVisitsSection(
                    items: _dashboard?.recentVisits.isNotEmpty == true
                        ? _dashboard!.recentVisits
                        : _emptyRecentPlaceholder,
                    onSeeAll: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<HomeRecentVisitItem> _emptyRecentPlaceholder = [
    HomeRecentVisitItem(
      leadingIcon: Icons.event_note_outlined,
      title: 'No visits yet',
      subtitle: 'Plan or complete visits to see them here',
      statusLabel: '—',
    ),
  ];

  Widget _placeholderTab(String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}