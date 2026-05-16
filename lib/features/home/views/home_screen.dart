// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medical_rep/core/services/services.dart';
// import 'package:medical_rep/core/styles/app_color.dart';
// import 'package:medical_rep/features/doctor_and_pharmacy/presentation/cubit/medical_cubit.dart';
// import 'package:medical_rep/features/doctor_and_pharmacy/presentation/views/entities_list_page.dart';
// import 'package:medical_rep/features/home/data/home_dashboard_repository.dart';
// import 'package:medical_rep/features/home/data/models/home_dashboard_snapshot.dart';
// import 'package:medical_rep/features/home/views/widgets/home_bottom_navigation_bar.dart';
// import 'package:medical_rep/features/home/views/widgets/home_header_section.dart';
// import 'package:medical_rep/features/home/views/widgets/home_profile_progress_card.dart';
// import 'package:medical_rep/features/home/views/widgets/home_recent_visits_section.dart';
// import 'package:medical_rep/features/home/views/widgets/home_services_section.dart';
// import 'package:medical_rep/features/home/views/widgets/home_stats_row.dart';
// import 'package:medical_rep/features/profile/views/profile_screen.dart';
// import 'package:medical_rep/features/visit_flow/presentation/pages/pending_visits_screen.dart';
// import 'package:medical_rep/features/weekly_planning/views/create_weekly_plan_view.dart';
// import 'package:medical_rep/features/weekly_planning/views/weekly_plan_status_view.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   static const Set<String> _recentVisitStatuses = {'done', 'completed'};
//   static const int _recentVisitFetchCap = 50;
//
//   int _navIndex = 0;
//   HomeDashboardSnapshot? _dashboard;
//   List<HomeRecentVisitItem> _recentCompletedVisits = [];
//   bool _loadingDashboard = true;
//   String? _dashboardError;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDashboard();
//   }
//
//
//   Future<void> _loadDashboard() async {
//     setState(() {
//       _loadingDashboard = true;
//       _dashboardError = null;
//     });
//     try {
//       final data = await getIt<HomeDashboardRepository>().loadDashboard();
//       final recent = await _fetchRecentDoneOrCompletedVisits();
//       if (!mounted) return;
//       setState(() {
//         _dashboard = data;
//         _recentCompletedVisits = recent;
//         _loadingDashboard = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _dashboardError = e.toString();
//         _loadingDashboard = false;
//       });
//     }
//   }
//
//   String _greeting() {
//     final h = DateTime.now().hour;
//     if (h < 12) return 'Good Morning';
//     if (h < 17) return 'Good Afternoon';
//     return 'Good Evening';
//   }
//
//   void _openDoctorsList() {
//     Navigator.of(context).push(
//       MaterialPageRoute<void>(
//         builder: (_) => BlocProvider<MedicalCubit>(
//           create: (_) => getIt<MedicalCubit>(),
//           child: const EntitiesListPage(),
//         ),
//       ),
//     );
//   }
//
//   void _openPendingVisitsScreen() {
//     Navigator.of(context).push(
//       MaterialPageRoute<void>(
//         builder: (_) => const PendingVisitsScreen(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final topInset = MediaQuery.paddingOf(context).top;
//     final stackHeight = topInset + 200 + 20;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: IndexedStack(
//         index: _navIndex,
//         children: [
//           _buildHomeScroll(context, topInset, stackHeight),
//           const WeeklyPlanningView(),
//           const CreatePlanScreen(),
//         ],
//       ),
//       bottomNavigationBar: HomeBottomNavigationBar(
//         currentIndex: _navIndex,
//         onTap: (i) => setState(() => _navIndex = i),
//       ),
//     );
//   }
//
//   Widget _buildHomeScroll(
//     BuildContext context,
//     double topInset,
//     double stackHeight,
//   ) {
//     final profile = _dashboard?.profile;
//     final userName = profile?.fullName ?? '…';
//     final roleLine = profile != null
//         ? '${profile.roleTitle} · ${profile.regionLabel}'
//         : '…';
//     final email = profile?.email ?? '…';
//     final repId = profile?.repId ?? '…';
//
//     return RefreshIndicator(
//       onRefresh: _loadDashboard,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(
//           parent: BouncingScrollPhysics(),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             SizedBox(
//               height: stackHeight,
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   HomeHeaderSection(
//                     greeting: _greeting(),
//                     userName: userName,
//                     roleLine: roleLine,
//                   ),
//                   Positioned(
//                     left: 20,
//                     right: 20,
//                     top: 118 + topInset,
//                     child: HomeProfileProgressCard(
//                       email: email,
//                       repId: repId,
//                       avatarUrl: profile?.avatarUrl,
//                       onProfile: () async {
//                         await Navigator.of(context).push(
//                           MaterialPageRoute<void>(
//                             builder: (_) => const ProfileScreen(),
//                           ),
//                         );
//                         if (mounted) {
//                           _loadDashboard();
//                         }
//                       },
//                       onQrTap: () {},
//                       onSummaryTap: () {
//                         // عند الضغط على ملخص الكارد يفتح صفحة عرض الخطة
//                         setState(() => _navIndex = 1);
//                       },
//                       onTargetTap: () {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (_dashboardError != null) ...[
//                     const SizedBox(height: 8),
//                     Text(
//                       'Could not load dashboard: $_dashboardError',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: AppColors.errorColor,
//                           ),
//                     ),
//                   ],
//                   const SizedBox(height: 8),
//                   if (_loadingDashboard && _dashboard == null)
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 24),
//                       child: Center(
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                     )
//                   else
//                     HomeStatsRow(
//                       visitsPlannedToday: _dashboard?.visitsPlannedToday ?? 0,
//                       pendingDrafts: _dashboard?.pendingDrafts ?? 0,
//                       weekVisitsPlanned: _dashboard?.weekVisitsPlanned ?? 0,
//                       onDraftsTap: _openPendingVisitsScreen,
//                     ),
//                   const SizedBox(height: 24),
//                   HomeServicesSection(
//                     onDoctorsList: _openDoctorsList,
//                     onWeeklyPlanning: () {
//                       setState(() => _navIndex = 2);
//                     },
//
//                     onDrafts: _openPendingVisitsScreen,
//
//                     onDrafts: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (context)=>const PendingVisitsScreen()));
//                     },
//
//                   ),
//                   const SizedBox(height: 28),
//                   HomeRecentVisitsSection(
//                     items: _recentCompletedVisits.isNotEmpty
//                         ? _recentCompletedVisits
//                         : _emptyRecentPlaceholder,
//                     onSeeAll: () => setState(() => _navIndex = 1),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   static const List<HomeRecentVisitItem> _emptyRecentPlaceholder = [
//     HomeRecentVisitItem(
//       leadingIcon: Icons.event_note_outlined,
//       title: 'No visits yet',
//       subtitle: 'Plan or complete visits to see them here',
//       statusLabel: '—',
//     ),
//   ];
//
//   Future<List<HomeRecentVisitItem>> _fetchRecentDoneOrCompletedVisits() async {
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user == null) return [];
//
//     try {
//       final raw = await Supabase.instance.client
//           .from('visits')
//           .select(
//             'doctor_name, visit_date, shift, status, visit_type',
//           )
//           .eq('user_id', user.id)
//           .order('visit_date', ascending: false)
//           .limit(_recentVisitFetchCap);
//
//       return _mapRowsToRecentItemsLimited(
//         raw as List<dynamic>,
//         allowedStatuses: _recentVisitStatuses,
//         maxItems: 5,
//       );
//     } catch (_) {
//       return [];
//     }
//   }
//
//   static List<HomeRecentVisitItem> _mapRowsToRecentItemsLimited(
//     List<dynamic> rows, {
//     required Set<String> allowedStatuses,
//     required int maxItems,
//   }) {
//     final out = <HomeRecentVisitItem>[];
//     for (final raw in rows) {
//       if (out.length >= maxItems) break;
//       if (raw is! Map) continue;
//       final row = Map<String, dynamic>.from(raw);
//       final status = (row['status'] ?? '').toString().toLowerCase();
//       if (!allowedStatuses.contains(status)) continue;
//
//       final doctor = row['doctor_name']?.toString() ?? 'Visit';
//       final date = row['visit_date']?.toString() ?? '';
//       final shift = row['shift']?.toString() ?? '';
//       final type = row['visit_type']?.toString() ?? '';
//       final style = _recentVisitStatusStyle(status);
//
//       out.add(
//         HomeRecentVisitItem(
//           leadingIcon: Icons.local_hospital_outlined,
//           title: doctor,
//           subtitle: [type, shift, date].where((s) => s.isNotEmpty).join(' · '),
//           statusLabel: style.$1,
//           statusColor: style.$2,
//           statusBackgroundColor: style.$3,
//         ),
//       );
//     }
//     return out;
//   }
//
//   static (String, Color, Color) _recentVisitStatusStyle(String status) {
//     switch (status) {
//       case 'approved':
//       case 'completed':
//       case 'done':
//       case 'visited':
//         return ('Done', const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
//       case 'rejected':
//         return ('Rejected', const Color(0xFFC62828), const Color(0xFFFFEBEE));
//       case 'draft':
//         return ('Draft', const Color(0xFF1565C0), const Color(0xFFE3F2FD));
//       default:
//         return ('Pending', const Color(0xFFEF6C00), const Color(0xFFFFF3E0));
//     }
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_rep/core/services/services.dart';
import 'package:medical_rep/core/styles/app_color.dart';
import 'package:medical_rep/features/doctor_and_pharmacy/presentation/cubit/medical_cubit.dart';
import 'package:medical_rep/features/doctor_and_pharmacy/presentation/views/entities_list_page.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Set<String> _recentVisitStatuses = {'done', 'completed'};
  static const int _recentVisitFetchCap = 50;

  int _navIndex = 0;
  HomeDashboardSnapshot? _dashboard;
  List<HomeRecentVisitItem> _recentCompletedVisits = [];
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
      final recent = await _fetchRecentDoneOrCompletedVisits();
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _recentCompletedVisits = recent;
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

  void _openDoctorsList() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<MedicalCubit>(
          create: (_) => getIt<MedicalCubit>(),
          child: const EntitiesListPage(),
        ),
      ),
    );
  }

  void _openPendingVisitsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PendingVisitsScreen(),
      ),
    );
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
          _buildHomeScroll(context, topInset, stackHeight),
          const WeeklyPlanningView(),
          const CreatePlanScreen(),
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
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 118 + topInset,
                    child: HomeProfileProgressCard(
                      email: email,
                      repId: repId,
                      avatarUrl: profile?.avatarUrl,
                      onProfile: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                        if (mounted) {
                          _loadDashboard();
                        }
                      },
                      onQrTap: () {},
                      onSummaryTap: () {
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
                      visitsPlannedToday: _dashboard?.visitsPlannedToday ?? 0,
                      pendingDrafts: _dashboard?.pendingDrafts ?? 0,
                      weekVisitsPlanned: _dashboard?.weekVisitsPlanned ?? 0,
                      onDraftsTap: _openPendingVisitsScreen,
                    ),
                  const SizedBox(height: 24),
                  HomeServicesSection(
                    onDoctorsList: _openDoctorsList,
                    onWeeklyPlanning: () {
                      setState(() => _navIndex = 2);
                    },
                    onDrafts: _openPendingVisitsScreen, // تم حل التكرار هنا بأمان وعبر الدالة المخصصة
                  ),
                  const SizedBox(height: 28),
                  HomeRecentVisitsSection(
                    items: _recentCompletedVisits.isNotEmpty
                        ? _recentCompletedVisits
                        : _emptyRecentPlaceholder,
                    onSeeAll: () => setState(() => _navIndex = 1),
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

  Future<List<HomeRecentVisitItem>> _fetchRecentDoneOrCompletedVisits() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    try {
      final raw = await Supabase.instance.client
          .from('visits')
          .select(
        'doctor_name, visit_date, shift, status, visit_type',
      )
          .eq('user_id', user.id)
          .order('visit_date', ascending: false)
          .limit(_recentVisitFetchCap);

      return _mapRowsToRecentItemsLimited(
        raw as List<dynamic>,
        allowedStatuses: _recentVisitStatuses,
        maxItems: 5,
      );
    } catch (_) {
      return [];
    }
  }

  static List<HomeRecentVisitItem> _mapRowsToRecentItemsLimited(
      List<dynamic> rows, {
        required Set<String> allowedStatuses,
        required int maxItems,
      }) {
    final out = <HomeRecentVisitItem>[];
    for (final raw in rows) {
      if (out.length >= maxItems) break;
      if (raw is! Map) continue;
      final row = Map<String, dynamic>.from(raw);
      final status = (row['status'] ?? '').toString().toLowerCase();
      if (!allowedStatuses.contains(status)) continue;

      final doctor = row['doctor_name']?.toString() ?? 'Visit';
      final date = row['visit_date']?.toString() ?? '';
      final shift = row['shift']?.toString() ?? '';
      final type = row['visit_type']?.toString() ?? '';
      final style = _recentVisitStatusStyle(status);

      out.add(
        HomeRecentVisitItem(
          leadingIcon: Icons.local_hospital_outlined,
          title: doctor,
          subtitle: [type, shift, date].where((s) => s.isNotEmpty).join(' · '),
          statusLabel: style.$1,
          statusColor: style.$2,
          statusBackgroundColor: style.$3,
        ),
      );
    }
    return out;
  }

  static (String, Color, Color) _recentVisitStatusStyle(String status) {
    switch (status) {
      case 'approved':
      case 'completed':
      case 'done':
      case 'visited':
        return ('Done', const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
      case 'rejected':
        return ('Rejected', const Color(0xFFC62828), const Color(0xFFFFEBEE));
      case 'draft':
        return ('Draft', const Color(0xFF1565C0), const Color(0xFFE3F2FD));
      default:
        return ('Pending', const Color(0xFFEF6C00), const Color(0xFFFFF3E0));
    }
  }
}