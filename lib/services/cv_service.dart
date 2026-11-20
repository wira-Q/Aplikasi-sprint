import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/postgrest_error_mapper.dart';
import '../models/cv_model.dart';

class CvService {
  CvService({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  /// Menerima bytes (bukan File) agar jalan di web dan mobile.
  /// Untuk UI: ambil file dengan file_picker (withData: true) lalu kirim
  /// bytes dan nama file ke sini.
  Future<CvModel> uploadCv({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final uid = _requireUid();
    final displayName = _validateFile(bytes, fileName);
    final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.pdf';
    final storage = _client.storage.from(CvRules.bucket);

    try {
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          contentType: CvRules.mimeType,
          upsert: false,
        ),
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

    try {
      final row = await _client
          .from('cvs')
          .insert({
            'id_user': uid,
            'file_name': displayName,
            'file_url': path,
            'file_size': bytes.length,
          })
          .select()
          .single();
      return CvModel.fromMap(row);
    } catch (e) {
      // Metadata gagal disimpan: hapus file agar tidak menjadi data yatim.
      await _removeQuietly(path);
      if (e is PostgrestException) throw mapPostgrestError(e);
      _log('insert metadata error: ${e.runtimeType}');
      throw const AppException('Gagal menyimpan data CV. Silakan coba lagi.');
    }
  }

  Future<List<CvModel>> getMyCvs() async {
    final uid = _requireUid();
    try {
      final rows = await _client
          .from('cvs')
          .select()
          .eq('id_user', uid)
          .order('uploaded_at', ascending: false);
      return rows.map((r) => CvModel.fromMap(r)).toList();
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getMyCvs error: ${e.runtimeType}');
      throw const AppException('Gagal memuat CV. Periksa koneksi Anda.');
    }
  }

  /// Menghapus data dulu, baru file. CV yang dipakai lamaran ditolak
  /// oleh database (FK RESTRICT) dan filenya TIDAK disentuh.
  Future<void> deleteCv(int idCv) async {
    final uid = _requireUid();
    try {
      final deleted = await _client
          .from('cvs')
          .delete()
          .eq('id_cv', idCv)
          .eq('id_user', uid)
          .select();
      if (deleted.isEmpty) {
        throw const AppException('CV tidak ditemukan.', code: 'not_found');
      }
      final path = (deleted.first['file_url'] as String?) ?? '';
      if (path.isNotEmpty) await _removeQuietly(path);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw const AppException(
          'CV ini sedang dipakai pada lamaran, jadi tidak dapat dihapus.',
          code: 'cv_in_use',
        );
      }
      throw mapPostgrestError(e);
    } catch (e) {
      _log('deleteCv error: ${e.runtimeType}');
      throw const AppException('Gagal menghapus CV. Periksa koneksi Anda.');
    }
  }

  /// Signed URL berumur pendek. Berhasil untuk pemilik CV, dan untuk
  /// recruiter yang CV-nya terkait lamaran ke lowongan miliknya.
  Future<String> createSignedUrl(int idCv) async {
    _requireUid();
    try {
      final row = await _client
          .from('cvs')
          .select('file_url')
          .eq('id_cv', idCv)
          .maybeSingle();
      if (row == null) {
        throw const AppException(
          'CV tidak ditemukan atau akses ditolak.',
          code: 'not_found',
        );
      }
      return await _client.storage
          .from(CvRules.bucket)
          .createSignedUrl(row['file_url'] as String, CvRules.signedUrlSeconds);
    } on AppException {
      rethrow;
    } on StorageException catch (e) {
      throw _mapStorage(e);
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('signedUrl error: ${e.runtimeType}');
      throw const AppException(
        'Gagal membuat tautan CV. Periksa koneksi Anda.',
      );
    }
  }

  // ------------------------------------------------------------------ HELPERS

  /// Mengembalikan nama tampilan yang sudah dibersihkan.
  String _validateFile(Uint8List bytes, String fileName) {
    final name = _safeName(fileName);
    if (!name.toLowerCase().endsWith('.pdf')) {
      throw const AppException('CV harus berformat PDF.', code: 'invalid_type');
    }
    if (bytes.isEmpty) {
      throw const AppException('File CV kosong.', code: 'empty');
    }
    if (bytes.length > CvRules.maxBytes) {
      throw const AppException('Ukuran CV maksimal 5 MB.', code: 'too_large');
    }
    if (!_hasPdfHeader(bytes)) {
      throw const AppException(
        'File bukan PDF yang valid.',
        code: 'invalid_type',
      );
    }
    return name;
  }

  /// Tanda awal PDF: %PDF-
  bool _hasPdfHeader(Uint8List b) =>
      b.length >= 5 &&
      b[0] == 0x25 &&
      b[1] == 0x50 &&
      b[2] == 0x44 &&
      b[3] == 0x46 &&
      b[4] == 0x2D;

  String _safeName(String raw) {
    final base = raw.split(RegExp(r'[\\/]')).last.trim();
    final cleaned = base.replaceAll(RegExp(r'[\x00-\x1F]'), '');
    return cleaned.length > 100
        ? cleaned.substring(cleaned.length - 100)
        : cleaned;
  }

  Future<void> _removeQuietly(String path) async {
    try {
      await _client.storage.from(CvRules.bucket).remove([path]);
    } catch (e) {
      _log('gagal menghapus file ($path): ${e.runtimeType}');
    }
  }

  AppException _mapStorage(StorageException e) {
    _log('StorageException status=${e.statusCode}');
    switch (e.statusCode) {
      case '413':
        return const AppException(
          'Ukuran CV maksimal 5 MB.',
          code: 'too_large',
        );
      case '415':
        return const AppException(
          'CV harus berformat PDF.',
          code: 'invalid_type',
        );
      case '401':
      case '403':
        return const AppException('Akses ditolak.', code: 'forbidden');
      case '404':
        return const AppException('File tidak ditemukan.', code: 'not_found');
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
    if (kDebugMode) debugPrint('[CvService] $text');
  }
}
