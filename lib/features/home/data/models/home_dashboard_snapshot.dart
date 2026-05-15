import 'package:medical_rep/features/home/views/widgets/home_recent_visits_section.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';

/// Server-backed home dashboard: stats, recent rows, and profile row for the header.
class HomeDashboardSnapshot {
  const HomeDashboardSnapshot({
    required this.profile,
    required this.visitsPlannedToday,
    required this.pendingDrafts,
    required this.weekVisitsPlanned,
    required this.recentVisits,
  });

  final ProfileUser profile;
  /// Non-rejected visits scheduled for today.
  final int visitsPlannedToday;
  final int pendingDrafts;
  /// Non-rejected visits scheduled from Saturday through Thursday (current week).
  final int weekVisitsPlanned;
  final List<HomeRecentVisitItem> recentVisits;
}
