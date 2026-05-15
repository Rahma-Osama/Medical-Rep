import 'package:medical_rep/features/home/views/widgets/home_recent_visits_section.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';

/// Server-backed home dashboard: stats, recent rows, and profile row for the header.
class HomeDashboardSnapshot {
  const HomeDashboardSnapshot({
    required this.profile,
    required this.visitsDoneToday,
    required this.visitsPlannedToday,
    required this.pendingDrafts,
    required this.weekVisitsDone,
    required this.recentVisits,
  });

  final ProfileUser profile;
  final int visitsDoneToday;
  final int visitsPlannedToday;
  final int pendingDrafts;
  final int weekVisitsDone;
  final List<HomeRecentVisitItem> recentVisits;
}
