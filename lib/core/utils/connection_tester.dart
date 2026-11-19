import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';

enum ConnectionStatus {
  successWithData,
  successEmpty,
  accessDenied,
  tableNotFound,
  invalidKey,
  network,
  unknown,
}

class ConnectionTestResult {
  const ConnectionTestResult(this.status, this.message);
  final ConnectionStatus status;
  final String message;
}

class ConnectionTester {
  ConnectionTester._();

  static Future<ConnectionTestResult> run() async {
    try {
      final rows = await SupabaseConfig.client
          .from('jobs')
          .select('id_job')
          .limit(1)
          .timeout(const Duration(seconds: 10));

      if (rows.isNotEmpty) {
        return const ConnectionTestResult(
          ConnectionStatus.successWithData,
          'Terhubung. Tabel jobs dapat dibaca dan berisi data.',
        );
      }
      return const ConnectionTestResult(
        ConnectionStatus.successEmpty,
        'Terhubung ke Supabase dan key valid, tetapi hasil kosong. '
        'Penyebabnya tabel jobs kosong atau RLS belum punya policy SELECT.',
      );
    } on PostgrestException catch (e) {
      _log('PostgrestException code=${e.code}');
      final code = e.code ?? '';
      final msg = e.message.toLowerCase();

      if (code == '42501') {
        return const ConnectionTestResult(
          ConnectionStatus.accessDenied,
          'Server terjangkau, tetapi akses ke tabel jobs ditolak (izin/RLS).',
        );
      }
      if (code == '42P01' || code == 'PGRST205') {
        return const ConnectionTestResult(
          ConnectionStatus.tableNotFound,
          'Server terjangkau, tetapi tabel jobs tidak ditemukan di schema public.',
        );
      }
      if (code == 'PGRST301' ||
          msg.contains('jwt') ||
          msg.contains('api key')) {
        return const ConnectionTestResult(
          ConnectionStatus.invalidKey,
          'Key ditolak server. Periksa SUPABASE_ANON_KEY di env.json.',
        );
      }
      return const ConnectionTestResult(
        ConnectionStatus.unknown,
        'Server menolak request dengan error yang belum dikenali.',
      );
    } on TimeoutException {
      return const ConnectionTestResult(
        ConnectionStatus.network,
        'Waktu habis. Periksa koneksi internet dan SUPABASE_URL.',
      );
    } on AuthException catch (e) {
      _log('AuthException status=${e.statusCode}');
      return const ConnectionTestResult(
        ConnectionStatus.invalidKey,
        'Autentikasi ke Supabase gagal. Periksa key di env.json.',
      );
    } catch (e) {
      // Hanya tipe error yang dicatat, agar URL/key tidak bocor ke log.
      _log('Error tidak terduga: ${e.runtimeType}');
      return const ConnectionTestResult(
        ConnectionStatus.network,
        'Tidak dapat menghubungi Supabase. Periksa internet dan SUPABASE_URL.',
      );
    }
  }

  static void _log(String text) {
    if (kDebugMode) debugPrint('[ConnectionTester] $text');
  }
}
