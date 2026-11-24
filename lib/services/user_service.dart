import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../models/job_model.dart';
import '../models/profile_options.dart';
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
  /// education, gender, dan birthDate hanya bermakna untuk job seeker;
  /// UI recruiter tidak menampilkannya.
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? education,
    String? gender,
    DateTime? birthDate,
  }) async {
    if (name != null && name.trim().isEmpty) {
      throw const AppException('Nama tidak boleh kosong.');
    }
    if (gender != null && !_allowedGender.contains(gender)) {
      throw const AppException('Pilihan jenis kelamin tidak valid.');
    }
    if (education != null && !EducationOptions.isValid(education)) {
      throw const AppException('Pilihan pendidikan tidak valid.');
    }
    if (birthDate != null) {
      final error = ProfileRules.validateBirthDate(birthDate);
      if (error != null) throw AppException(error, code: 'bad_birth_date');
    }
    final changes = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (phone != null) 'phone': phone.trim(),
      if (location != null) 'location': location.trim(),
      if (education != null) 'education': education,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': _dateOnly(birthDate),
    };
    if (changes.isEmpty) {
      throw const AppException('Tidak ada data yang diubah.');
    }
    return _updateOwnRow(changes);
  }

  /// Preferensi untuk halaman rekomendasi. Hanya daftar yang diisi
  /// (tidak null) yang diubah; daftar kosong mengosongkan preferensinya.
  Future<UserModel> updatePreferences({
    List<String>? locations,
    List<String>? jobTypes,
  }) async {
    if (locations == null && jobTypes == null) {
      throw const AppException('Tidak ada data yang diubah.');
    }
    final changes = <String, dynamic>{
      if (locations != null)
        'preferred_locations': _normalize(
          locations,
          JobOptions.locations,
          'Lokasi pilihan tidak valid.',
        ),
      if (jobTypes != null)
        'preferred_job_types': _normalize(
          jobTypes,
          JobOptions.jobTypes,
          'Jenis pekerjaan pilihan tidak valid.',
        ),
    };
    return _updateOwnRow(changes);
  }

  /// Dipakai AvatarService. Path harus berawalan ID user; itu dijaga
  /// constraint database. Null mengosongkan foto.
  Future<UserModel> updatePhotoPath(String? path) =>
      _updateOwnRow({'photo': path});

  Future<UserModel> _updateOwnRow(Map<String, dynamic> changes) async {
    final uid = _requireUid();
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
      _log('update error: ${e.runtimeType}');
      throw const AppException('Gagal menyimpan profil. Periksa koneksi Anda.');
    }
  }

  List<String> _normalize(
    List<String> input,
    List<String> allowed,
    String errorMessage,
  ) {
    final unique = <String>[];
    for (final raw in input) {
      final value = raw.trim();
      if (!allowed.contains(value)) throw AppException(errorMessage);
      if (!unique.contains(value)) unique.add(value);
    }
    return unique;
  }

  /// Format yyyy-MM-dd agar tidak terpengaruh zona waktu.
  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

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
    if (e.code == 'P0001' && e.message.contains('PROFILE_BAD_BIRTH_DATE')) {
      return const AppException(
        'Tanggal lahir tidak valid. Usia harus antara 15 dan 80 tahun.',
        code: 'bad_birth_date',
      );
    }
    if (e.code == '23514') {
      return const AppException(
        'Data tidak sesuai aturan yang berlaku.',
        code: 'check_violation',
      );
    }
    return const AppException('Terjadi kesalahan pada server. Coba lagi.');
  }

  void _log(String text) {
    if (kDebugMode) debugPrint('[UserService] $text');
  }
}
