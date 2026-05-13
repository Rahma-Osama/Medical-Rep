import 'package:medical_rep/core/error/app_exception.dart';
import 'package:medical_rep/core/error/error_mapper.dart';
import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/profile/domain/repositories/profile_repository.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds [ProfileUser] from the signed-in Supabase user (`auth.currentUser`
/// and `userMetadata`). Optional metadata keys: `full_name` / `name`,
/// `rep_id`, `role_title` / `role`, `region` / `region_label`, `phone`,
/// `territory`.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<Result<ProfileUser>> getCurrentProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const UnauthorizedException(
          debugMessage: 'No Supabase session when loading profile',
        );
      }

      final meta = user.userMetadata ?? {};
      final email = user.email?.trim() ?? '';

      final profile = ProfileUser(
        fullName: _firstNonEmptyString(meta, const [
              'full_name',
              'name',
              'fullName',
              'display_name',
            ]) ??
            _nameFromEmail(email),
        email: email.isNotEmpty ? email : '—',
        repId: _firstNonEmptyString(meta, const ['rep_id', 'repId']) ??
            'MR-${user.id.replaceAll('-', '').substring(0, 8).toUpperCase()}',
        roleTitle: _firstNonEmptyString(meta, const [
              'role_title',
              'job_title',
              'role',
            ]) ??
            'Medical representative',
        regionLabel: _firstNonEmptyString(meta, const [
              'region_label',
              'region',
            ]) ??
            '—',
        phone: _firstNonEmptyString(meta, const ['phone']) ?? user.phone,
        territory: _firstNonEmptyString(meta, const ['territory', 'area']),
      );

      return Success(profile);
    } catch (e, _) {
      return Failure(
        mapExceptionToFailure(
          e is AppException ? e : const ServerErrorException(),
        ),
      );
    }
  }
}

String? _firstNonEmptyString(Map<String, dynamic> meta, List<String> keys) {
  for (final key in keys) {
    final raw = meta[key];
    if (raw == null) continue;
    final s = raw.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

String _nameFromEmail(String email) {
  if (email.isEmpty) return 'User';
  final local = email.split('@').first.trim();
  if (local.isEmpty) return 'User';
  return local
      .replaceAll('.', ' ')
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .map((p) {
        if (p.length == 1) return p.toUpperCase();
        return '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}';
      })
      .join(' ');
}
