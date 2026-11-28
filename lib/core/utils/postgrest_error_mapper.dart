import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_exception.dart';

/// Mengubah error database menjadi pesan aman untuk pengguna.
/// Detail internal hanya dicatat kodenya, tanpa isi pesan.
AppException mapPostgrestError(PostgrestException e) {
  if (kDebugMode) debugPrint('[Postgrest] code=${e.code}');
  switch (e.code) {
    case '42501':
      return const AppException('Akses ditolak.', code: 'forbidden');
    case '23505':
      return const AppException(
        'Data sudah ada dan tidak boleh ganda.',
        code: 'duplicate',
      );
    case '23502':
      return const AppException('Data belum lengkap.', code: 'incomplete');
    case '23503':
      return const AppException(
        'Data terkait tidak ditemukan.',
        code: 'fk_violation',
      );
    case '23514':
      return const AppException(
        'Data tidak sesuai aturan yang berlaku.',
        code: 'check_violation',
      );
    case '22P02':
      return const AppException('Format data tidak valid.', code: 'invalid');
    case 'PGRST116':
      return const AppException('Data tidak ditemukan.', code: 'not_found');
    case 'PGRST103':
      // Nomor halaman melewati jumlah data. Ditangani PagedController.
      return const AppException(
        'Halaman tidak ditemukan.',
        code: 'page_out_of_range',
      );
    default:
      return const AppException('Terjadi kesalahan pada server. Coba lagi.');
  }
}
