import 'package:flutter/material.dart';
import 'package:medical_rep/core/utils/work_week_dates.dart';
import 'package:medical_rep/features/home/data/models/home_dashboard_snapshot.dart';
import 'package:medical_rep/features/home/views/widgets/home_recent_visits_section.dart';
import 'package:medical_rep/features/profile/domain/repositories/profile_repository.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Counts visits for the signed-in user. Expects `visits` columns:
/// `user_id`, `visit_date` (ISO `yyyy-MM-dd` or date), `status`.
///
/// Semantics:
/// - **Planned (today)**: rows for today with `status != rejected`.
/// - **Planned (this week)**: rows from **Saturday through Thursday** (inclusive) in the
///   current local week with `status != rejected`.
/// - **Drafts**: `status == draft`.
abstract class HomeDashboardRepository {
  Future<HomeDashboardSnapshot> loadDashboard({int recentVisitLimit = 5});
}

class HomeDashboardRepositoryImpl implements HomeDashboardRepository {
  HomeDashboardRepositoryImpl({
    required ProfileRepository profileRepository,
    SupabaseClient? supabase,
  })  : _profileRepository = profileRepository,
        _client = supabase ?? Supabase.instance.client;

  final ProfileRepository _profileRepository;
  final SupabaseClient _client;

  static const List<String> _draftStatuses = ['draft'];

  Future<int> _exactCount(
    PostgrestFilterBuilder<dynamic> Function() query,
  ) async {
    final res = await query().count(CountOption.exact);
    return res.count;
  }

  @override
  Future<HomeDashboardSnapshot> loadDashboard({int recentVisitLimit = 5}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('HomeDashboardRepository: no signed-in user');
    }
    final uid = user.id;
    final today = WorkWeekDates.isoDate(DateTime.now());
    final weekPlanned = WorkWeekDates.plannedWeekRange();

    final result = await _profileRepository.getCurrentProfile();

    final profile = result.when(
      success: (p) => p,
      onFailure: (_) => _fallbackProfile(user),
    );

    int plannedToday = 0;
    int weekPlannedCount = 0;
    int drafts = 0;
    List<HomeRecentVisitItem> recent = [];

    try {
      plannedToday = await _exactCount(
        () => _client
            .from('visits')
            .select('id')
            .eq('user_id', uid)
            .eq('visit_date', today)
            .neq('status', 'rejected'),
      );

      weekPlannedCount = await _exactCount(
        () => _client
            .from('visits')
            .select('id')
            .eq('user_id', uid)
            .gte('visit_date', weekPlanned.$1)
            .lte('visit_date', weekPlanned.$2)
            .neq('status', 'rejected'),
      );

      drafts = await _exactCount(
        () => _client
            .from('visits')
            .select('id')
            .eq('user_id', uid)
            .inFilter('status', _draftStatuses),
      );

      final rawRecent = await _client
          .from('visits')
          .select(
            'doctor_name, visit_date, shift, status, visit_type',
          )
          .eq('user_id', uid)
          .order('visit_date', ascending: false)
          .limit(recentVisitLimit);

      recent = _mapRecent(rawRecent as List<dynamic>);
    } catch (e, st) {
      debugPrint('HomeDashboardRepository load error: $e\n$st');
    }

    return HomeDashboardSnapshot(
      profile: profile,
      visitsPlannedToday: plannedToday,
      pendingDrafts: drafts,
      weekVisitsPlanned: weekPlannedCount,
      recentVisits: recent,
    );
  }

  ProfileUser _fallbackProfile(User user) {
    final email = user.email?.trim() ?? '';
    final meta = user.userMetadata ?? {};
    final avatarUrl = meta['avatar_url']?.toString() ??
        meta['avatarUrl']?.toString() ??
        meta['picture']?.toString();

    return ProfileUser(
      fullName: email.isNotEmpty ? email.split('@').first : 'User',
      email: email.isNotEmpty ? email : '—',
      repId: 'MR-${user.id.replaceAll('-', '').substring(0, 8).toUpperCase()}',
      roleTitle: 'Medical representative',
      regionLabel: '—',
      phone: user.phone,
      avatarUrl: avatarUrl,
    );
  }

  List<HomeRecentVisitItem> _mapRecent(List<dynamic> rows) {
    final out = <HomeRecentVisitItem>[];
    for (final raw in rows) {
      if (raw is! Map) continue;
      final row = Map<String, dynamic>.from(raw);
      final doctor = row['doctor_name']?.toString() ?? 'Visit';
      final date = row['visit_date']?.toString() ?? '';
      final shift = row['shift']?.toString() ?? '';
      final type = row['visit_type']?.toString() ?? '';
      final status = (row['status'] ?? 'pending').toString().toLowerCase();
      final (label, fg, bg) = _statusStyle(status);

      out.add(
        HomeRecentVisitItem(
          leadingIcon: Icons.local_hospital_outlined,
          title: doctor,
          subtitle: [type, shift, date].where((s) => s.isNotEmpty).join(' · '),
          statusLabel: label,
          statusColor: fg,
          statusBackgroundColor: bg,
        ),
      );
    }
    return out;
  }

  (String label, Color fg, Color bg) _statusStyle(String status) {
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
