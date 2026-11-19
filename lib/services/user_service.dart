import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../models/user_model.dart';

class UserService {
  UserService({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const _allowedGender = {'Laki-laki', 'Perempuan'};

  /// Role SELALU dibaca dari database, bukan dari input client.
  /// Mengembalikan null jika profil belum ada.
  Future<UserModel?> getCurrentProfile() async {
    final uid = _requireUid();
    try {
      final row = await _client
          .from('users')
          .select()
          .eq('id_user', uid)
          .maybeSingle();
      return row == null ? null : UserModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw _mapPostgrest(e);
    } catch (e) {
      _log('getCurrentProfile error: ${e.runtimeType}');
      throw const AppException('Gagal memuat profil. Periksa koneksi Anda.');
    }
  }

  /// Hanya kolom yang diizinkan RLS/grant yang dikirim. role & email tidak ada.
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? education,
    String? gender,
  }) async {
    final uid = _requireUid();
    if (name != null && name.trim().isEmpty) {
      throw const AppException('Nama tidak boleh kosong.');
    }
    if (gender != null && !_allowedGender.contains(gender)) {
      throw const AppException('Pilihan jenis kelamin tidak valid.');
    }
    final changes = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (location != null) 'location': location.trim(),
      if (education != null) 'education': education.trim(),
      if (gender != null) 'gender': gender,
    };
    if (changes.isEmpty) {
      throw const AppException('Tidak ada data yang diubah.');
    }
    try {
      final row = await _client
          .from('users')
          .update(changes)
          .eq('id_user', uid)
          .select()
          .maybeSingle();
      if (row == null) {
        throw const AppException(
          'Profil tidak ditemukan atau tidak dapat diubah.',
        );
      }
      return UserModel.fromMap(row);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _mapPostgrest(e);
    } catch (e) {
      _log('updateProfile error: ${e.runtimeType}');
      throw const AppException('Gagal menyimpan profil. Periksa koneksi Anda.');
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

  AppException _mapPostgrest(PostgrestException e) {
    _log('PostgrestException code=${e.code}');
    if (e.code == '42501') {
      return const AppException('Akses ditolak.', code: 'forbidden');
    }
    return const AppException('Terjadi kesalahan pada server. Coba lagi.');
  }

  void _log(String text) {
    if (kDebugMode) debugPrint('[UserService] $text');
  }
}
