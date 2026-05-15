import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Uploads profile photos to Supabase Storage bucket `profile_image`.
class ImageUpload {
  ImageUpload([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String bucketName = 'profile_image';

  Future<void> uploadProfileImage(String fileName, File imageFile) {
    return _client.storage.from(bucketName).upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );
  }

  String getImageUrl(String fileName) {
    return _client.storage.from(bucketName).getPublicUrl(fileName);
  }

  /// Stores under `{userId}/profile_<timestamp>.<ext>` and returns the public URL.
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    final ext = _safeExtension(imageFile.path);
    final fileName =
        '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await uploadProfileImage(fileName, imageFile);
    return getImageUrl(fileName);
  }

  static String _safeExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    const allowed = {'jpg', 'jpeg', 'png', 'webp', 'heic'};
    return allowed.contains(ext) ? ext : 'jpg';
  }
}
