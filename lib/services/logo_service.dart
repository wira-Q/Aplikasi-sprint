import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../models/company_model.dart';
import 'company_service.dart';

/// Aturan logo. Nilainya HARUS sama dengan pengaturan bucket di database.
class LogoRules {
  LogoRules._();

  static const String bucket = 'logos';
  static const int maxBytes = 2 * 1024 * 1024; // 2 MB
}

class LogoService {
  LogoService({SupabaseClient? client, CompanyService? companyService})
    : _client = client ?? SupabaseConfig.client,
      _companies = companyService ?? CompanyService(client: client);

  final SupabaseClient _client;
  final CompanyService _companies;

  /// URL publik dari path logo. Null jika perusahaan belum punya logo.
  /// Dipakai UI untuk menampilkan logo (daftar lowongan, profil perusahaan).
  static String? publicUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    return SupabaseConfig.client.storage
        .from(LogoRules.bucket)
        .getPublicUrl(path);
  }

  /// Menerima bytes (bukan File) agar jalan di web dan mobile.
  /// Untuk UI: ambil gambar dengan image_picker atau file_picker, lalu
  /// kirim bytes-nya ke sini. Mengembalikan data perusahaan terbaru.
  Future<CompanyModel> uploadLogo(Uint8List bytes) async {
    final uid = _requireUid();
    final kind = _validate(bytes);

    final company = await _companies.getMyCompany();
    if (company == null) {
      throw const AppException(
        'Lengkapi profil perusahaan terlebih dahulu.',
        code: 'no_company',
      );
    }
    final oldPath = company.logo;
    final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.${kind.ext}';
    final storage = _client.storage.from(LogoRules.bucket);

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

    final CompanyModel updated;
    try {
      updated = await _companies.updateMyCompany(logo: path);
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

  /// Menghapus logo: kolom dikosongkan dulu, baru filenya dihapus.
  Future<CompanyModel> removeLogo() async {
    _requireUid();
    final company = await _companies.getMyCompany();
    if (company == null) {
      throw const AppException(
        'Lengkapi profil perusahaan terlebih dahulu.',
        code: 'no_company',
      );
    }
    final oldPath = company.logo;
    if (oldPath == null || oldPath.isEmpty) return company;

    final updated = await _companies.updateMyCompany(logo: '');
    await _removeQuietly(oldPath);
    return updated;
  }

  // ------------------------------------------------------------------ HELPERS

  /// Tipe dicek dari isi file, bukan dari nama atau ekstensi.
  ({String ext, String mime}) _validate(Uint8List b) {
    if (b.isEmpty) {
      throw const AppException('File logo kosong.', code: 'empty');
    }
    if (b.length > LogoRules.maxBytes) {
      throw const AppException('Ukuran logo maksimal 2 MB.', code: 'too_large');
    }
    if (_isPng(b)) return (ext: 'png', mime: 'image/png');
    if (_isJpeg(b)) return (ext: 'jpg', mime: 'image/jpeg');
    if (_isWebp(b)) return (ext: 'webp', mime: 'image/webp');
    throw const AppException(
      'Logo harus berformat PNG, JPG, atau WebP.',
      code: 'invalid_type',
    );
  }

  bool _isPng(Uint8List b) =>
      b.length >= 8 &&
      b[0] == 0x89 &&
      b[1] == 0x50 &&
      b[2] == 0x4E &&
      b[3] == 0x47 &&
      b[4] == 0x0D &&
      b[5] == 0x0A &&
      b[6] == 0x1A &&
      b[7] == 0x0A;

  bool _isJpeg(Uint8List b) =>
      b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;

  bool _isWebp(Uint8List b) =>
      b.length >= 12 &&
      b[0] == 0x52 && // R
      b[1] == 0x49 && // I
      b[2] == 0x46 && // F
      b[3] == 0x46 && // F
      b[8] == 0x57 && // W
      b[9] == 0x45 && // E
      b[10] == 0x42 && // B
      b[11] == 0x50; // P

  Future<void> _removeQuietly(String path) async {
    try {
      await _client.storage.from(LogoRules.bucket).remove([path]);
    } catch (e) {
      _log('gagal menghapus file ($path): ${e.runtimeType}');
    }
  }

  AppException _mapStorage(StorageException e) {
    _log('StorageException status=${e.statusCode}');
    switch (e.statusCode) {
      case '413':
        return const AppException(
          'Ukuran logo maksimal 2 MB.',
          code: 'too_large',
        );
      case '415':
        return const AppException(
          'Logo harus berformat PNG, JPG, atau WebP.',
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
    if (kDebugMode) debugPrint('[LogoService] $text');
  }
}
