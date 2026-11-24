import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/image_signature.dart';
import '../models/user_model.dart';
import 'user_service.dart';

/// Aturan foto. Nilainya HARUS sama dengan pengaturan bucket di database.
class AvatarRules {
  AvatarRules._();

  static const String bucket = 'avatars';
  static const int maxBytes = 2 * 1024 * 1024; // 2 MB
  static const int signedUrlSeconds = 3600; // 1 jam
}

class AvatarService {
  AvatarService({SupabaseClient? client, UserService? userService})
    : _client = client ?? SupabaseConfig.client,
      _users = userService ?? UserService(client: client);

  final SupabaseClient _client;
  final UserService _users;

  /// Menerima bytes (bukan File) agar jalan di web dan mobile.
  /// Hanya untuk job seeker. Mengembalikan profil terbaru.
  Future<UserModel> uploadPhoto(Uint8List bytes) async {
    final uid = _requireUid();
    final kind = _validate(bytes);

    final profile = await _users.getCurrentProfile();
    if (profile == null) {
      throw const AppException('Profil tidak ditemukan.', code: 'no_profile');
    }
    if (profile.role != UserRole.jobSeeker) {
      throw const AppException(
        'Foto profil hanya untuk pencari kerja.',
        code: 'forbidden',
      );
    }

    final oldPath = profile.photo;
    final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.${kind.ext}';
    final storage = _client.storage.from(AvatarRules.bucket);

    try {
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: kind.mime, upsert: false),
      );
    } on StorageException catch (e) {
      throw _mapStorage(e);
    } catch (e) {
      _log('upload error: ${e.runtimeType}');
      throw const AppException(
        'Upload gagal. Periksa koneksi Anda.',
        code: 'upload_failed',
      );
    }

    final UserModel updated;
    try {
      updated = await _users.updatePhotoPath(path);
    } catch (e) {
      // Kolom gagal diperbarui: hapus file baru agar tidak menjadi data yatim.
      await _removeQuietly(path);
      rethrow;
    }

    if (oldPath != null && oldPath.isNotEmpty && oldPath != path) {
      await _removeQuietly(oldPath);
    }
    return updated;
  }

  /// Kolom dikosongkan dulu, baru filenya dihapus.
  Future<UserModel> removePhoto() async {
    _requireUid();
    final profile = await _users.getCurrentProfile();
    if (profile == null) {
      throw const AppException('Profil tidak ditemukan.', code: 'no_profile');
    }
    final oldPath = profile.photo;
    if (oldPath == null || oldPath.isEmpty) return profile;

    final updated = await _users.updatePhotoPath(null);
    await _removeQuietly(oldPath);
    return updated;
  }

  /// URL bertanda tangan berumur 1 jam. Berhasil untuk pemilik foto, dan
  /// untuk recruiter yang pelamarnya melamar ke lowongan miliknya.
  /// Mengembalikan null jika tidak ada foto atau gagal dimuat, supaya UI
  /// cukup menampilkan ikon bawaan.
  Future<String?> signedUrl(String? path) async {
    if (path == null || path.trim().isEmpty) return null;
    _requireUid();
    try {
      return await _client.storage
          .from(AvatarRules.bucket)
          .createSignedUrl(path, AvatarRules.signedUrlSeconds);
    } on StorageException catch (e) {
      _log('signedUrl status=${e.statusCode}');
      return null;
    } catch (e) {
      _log('signedUrl error: ${e.runtimeType}');
      return null;
    }
  }

  // ------------------------------------------------------------------ HELPERS

  ImageKind _validate(Uint8List b) {
    if (b.isEmpty) {
      throw const AppException('File foto kosong.', code: 'empty');
    }
    if (b.length > AvatarRules.maxBytes) {
      throw const AppException('Ukuran foto maksimal 2 MB.', code: 'too_large');
    }
    final kind = ImageSignature.detect(b);
    if (kind == null) {
      throw const AppException(
        'Foto harus berformat PNG, JPG, atau WebP.',
        code: 'invalid_type',
      );
    }
    return kind;
  }

  Future<void> _removeQuietly(String path) async {
    try {
      await _client.storage.from(AvatarRules.bucket).remove([path]);
    } catch (e) {
      _log('gagal menghapus file ($path): ${e.runtimeType}');
    }
  }

  AppException _mapStorage(StorageException e) {
    _log('StorageException status=${e.statusCode}');
    switch (e.statusCode) {
      case '413':
        return const AppException(
          'Ukuran foto maksimal 2 MB.',
          code: 'too_large',
        );
      case '415':
        return const AppException(
          'Foto harus berformat PNG, JPG, atau WebP.',
          code: 'invalid_type',
        );
      case '401':
      case '403':
        return const AppException('Akses ditolak.', code: 'forbidden');
      default:
        return const AppException(
          'Upload gagal. Silakan coba lagi.',
          code: 'upload_failed',
        );
    }
  }

  String _requireUid() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw const AppException(
        'Sesi berakhir. Silakan login kembali.',
        code: 'no_session',
      );
    }
    return uid;
  }

  void _log(String text) {
    if (kDebugMode) debugPrint('[AvatarService] $text');
  }
}
