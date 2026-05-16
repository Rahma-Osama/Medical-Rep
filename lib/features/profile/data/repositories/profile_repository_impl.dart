import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:medical_rep/core/error/app_exception.dart';
import 'package:medical_rep/core/services/image_upload.dart';
import 'package:medical_rep/core/error/app_failure.dart';
import 'package:medical_rep/core/error/error_mapper.dart';
import 'package:medical_rep/core/error/result.dart';
import 'package:medical_rep/features/profile/domain/repositories/profile_repository.dart';
import 'package:medical_rep/features/profile/models/profile_user.dart';
import 'package:medical_rep/features/profile/models/update_profile_email_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds [ProfileUser] from Supabase `profiles` (when present) and
/// `auth.currentUser` / `userMetadata`.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl([
    SupabaseClient? client,
    ImageUpload? imageUpload,
  ])  : _client = client ?? Supabase.instance.client,
        _imageUpload = imageUpload ?? ImageUpload(client);

  final SupabaseClient _client;
  final ImageUpload _imageUpload;

  @override
  Future<Result<ProfileUser>> getCurrentProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const UnauthorizedException(
          debugMessage: 'No Supabase session when loading profile',
        );
      }

      final profileRow = await _client
          .from('profiles')
          .select('email, role, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      final meta = user.userMetadata ?? {};
      final emailFromProfile =
          profileRow?['email']?.toString().trim() ?? '';
      final emailFromAuth = user.email?.trim() ?? '';
      final email = emailFromProfile.isNotEmpty
          ? emailFromProfile
          : emailFromAuth;

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
            (profileRow?['role']?.toString() ?? 'Medical representative'),
        regionLabel: _firstNonEmptyString(meta, const [
              'region_label',
              'region',
            ]) ??
            '—',
        phone: _firstNonEmptyString(meta, const ['phone']) ?? user.phone,
        territory: _firstNonEmptyString(meta, const ['territory', 'area']),
        avatarUrl: _resolveAvatarUrl(profileRow, meta),
      );

      return Success(profile);
    } catch (e, _) {
      return Failure(_mapProfileFailure(e));
    }
  }

  @override
  Future<Result<UpdateProfileEmailResult>> updateEmail(String email) async {
    try {
      final trimmed = email.trim();
      if (trimmed.isEmpty || !_isValidEmail(trimmed)) {
        return const Failure(
          GeneralFailure(message: 'Please enter a valid email address.'),
        );
      }

      final user = _client.auth.currentUser;
      if (user == null) {
        throw const UnauthorizedException(
          debugMessage: 'No Supabase session when updating email',
        );
      }

      final current = await _resolveCurrentEmail(user.id, user.email);
      if (trimmed.toLowerCase() == current.toLowerCase()) {
        final profileResult = await getCurrentProfile();
        return profileResult.when(
          success: (user) => Success(
            UpdateProfileEmailResult(user: user),
          ),
          onFailure: (f) => Failure(f),
        );
      }

      // 1) Auth user email (may require inbox confirmation depending on project settings).
      final authResponse = await _client.auth.updateUser(
        UserAttributes(email: trimmed),
      );
      await _client.auth.refreshSession();

      final pendingNewEmail = authResponse.user?.newEmail?.trim();
      final pendingConfirmation = pendingNewEmail != null &&
          pendingNewEmail.isNotEmpty;

      // 2) `public.profiles` — visible in Supabase Table Editor (requires UPDATE RLS).
      await _client.from('profiles').update({'email': trimmed}).eq('id', user.id);

      final profileResult = await getCurrentProfile();
      return profileResult.when(
        success: (profileUser) => Success(
          UpdateProfileEmailResult(
            user: profileUser,
            emailChangePendingConfirmation: pendingConfirmation,
          ),
        ),
        onFailure: (f) => Failure(f),
      );
    } on AuthException catch (e) {
      return Failure(
        GeneralFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Could not update email. Please try again.',
        ),
      );
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository updateEmail Postgrest: ${e.message}');
      }
      return Failure(
        GeneralFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Could not save email to your profile. Please try again.',
        ),
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('ProfileRepository updateEmail error: $e\n$st');
      }
      return Failure(_mapProfileFailure(e));
    }
  }

  @override
  Future<Result<ProfileUser>> updateProfilePhoto(File imageFile) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const UnauthorizedException(
          debugMessage: 'No Supabase session when updating profile photo',
        );
      }

      final imageUrl = await _imageUpload.uploadProfilePhoto(
        userId: user.id,
        imageFile: imageFile,
      );

      await _client
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', user.id);

      final meta = Map<String, dynamic>.from(user.userMetadata ?? {});
      meta['avatar_url'] = imageUrl;
      await _client.auth.updateUser(UserAttributes(data: meta));

      return getCurrentProfile();
    } on StorageException catch (e) {
      return Failure(
        GeneralFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Could not upload profile photo. Please try again.',
        ),
      );
    } on PostgrestException catch (e) {
      return Failure(
        GeneralFailure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Could not save profile photo. Please try again.',
        ),
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('ProfileRepository updateProfilePhoto error: $e\n$st');
      }
      return Failure(_mapProfileFailure(e));
    }
  }

  Future<String> _resolveCurrentEmail(String userId, String? authEmail) async {
    try {
      final row = await _client
          .from('profiles')
          .select('email')
          .eq('id', userId)
          .maybeSingle();
      final fromProfile = row?['email']?.toString().trim() ?? '';
      if (fromProfile.isNotEmpty) return fromProfile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository: could not read profiles.email: $e');
      }
    }
    return authEmail?.trim() ?? '';
  }

  AppFailure _mapProfileFailure(Object e) => mapExceptionToFailure(
        e is AppException ? e : const ServerErrorException(),
      );
}

bool _isValidEmail(String value) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
}

String? _resolveAvatarUrl(
  Map<String, dynamic>? profileRow,
  Map<String, dynamic> meta,
) {
  final fromProfile = profileRow?['avatar_url']?.toString().trim();
  if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
  return _firstNonEmptyString(meta, const [
    'avatar_url',
    'avatarUrl',
    'picture',
    'photo_url',
  ]);
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
