import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/backend_validators.dart';
import '../core/utils/postgrest_error_mapper.dart';
import '../models/company_model.dart';

class CompanyService {
  CompanyService({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  /// Null jika recruiter belum membuat profil perusahaan.
  Future<CompanyModel?> getMyCompany() async {
    final uid = _requireUid();
    try {
      final row = await _client
          .from('companies')
          .select()
          .eq('id_user', uid)
          .maybeSingle();
      return row == null ? null : CompanyModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getMyCompany error: ${e.runtimeType}');
      throw const AppException(
        'Gagal memuat profil perusahaan. Periksa koneksi Anda.',
      );
    }
  }

  /// Untuk job seeker: hanya berhasil jika perusahaan punya lowongan Dibuka.
  Future<CompanyModel?> getCompanyById(int idCompany) async {
    _requireUid();
    try {
      final row = await _client
          .from('companies')
          .select()
          .eq('id_company', idCompany)
          .maybeSingle();
      return row == null ? null : CompanyModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getCompanyById error: ${e.runtimeType}');
      throw const AppException(
        'Gagal memuat perusahaan. Periksa koneksi Anda.',
      );
    }
  }

  Future<CompanyModel> createMyCompany({
    required String companyName,
    String? industry,
    String? description,
    String? location,
    String? email,
    String? website,
    String? logo,
  }) async {
    final uid = _requireUid();
    _validate(
      name: companyName,
      email: email,
      website: website,
      creating: true,
    );
    try {
      final row = await _client
          .from('companies')
          .insert({
            'id_user': uid,
            'company_name': companyName.trim(),
            if (_clean(industry) != null) 'industry': _clean(industry),
            if (_clean(description) != null) 'description': _clean(description),
            if (_clean(location) != null) 'location': _clean(location),
            if (_clean(email) != null) 'email': _clean(email),
            if (_clean(website) != null) 'website': _clean(website),
            if (_clean(logo) != null) 'logo': _clean(logo),
          })
          .select()
          .single();
      return CompanyModel.fromMap(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AppException(
          'Akun ini sudah memiliki profil perusahaan.',
          code: 'duplicate',
        );
      }
      throw mapPostgrestError(e);
    } catch (e) {
      _log('createMyCompany error: ${e.runtimeType}');
      throw const AppException(
        'Gagal menyimpan perusahaan. Periksa koneksi Anda.',
      );
    }
  }

  /// Hanya field yang diisi (tidak null) yang diubah.
  /// String kosong pada field opsional mengosongkan nilainya.
  Future<CompanyModel> updateMyCompany({
    String? companyName,
    String? industry,
    String? description,
    String? location,
    String? email,
    String? website,
    String? logo,
  }) async {
    final uid = _requireUid();
    _validate(
      name: companyName,
      email: email,
      website: website,
      creating: false,
    );
    final changes = <String, dynamic>{
      if (companyName != null) 'company_name': companyName.trim(),
      if (industry != null) 'industry': _clean(industry),
      if (description != null) 'description': _clean(description),
      if (location != null) 'location': _clean(location),
      if (email != null) 'email': _clean(email),
      if (website != null) 'website': _clean(website),
      if (logo != null) 'logo': _clean(logo),
    };
    if (changes.isEmpty) {
      throw const AppException('Tidak ada data yang diubah.');
    }
    try {
      final row = await _client
          .from('companies')
          .update(changes)
          .eq('id_user', uid)
          .select()
          .maybeSingle();
      if (row == null) {
        throw const AppException(
          'Profil perusahaan tidak ditemukan atau tidak dapat diubah.',
          code: 'not_found',
        );
      }
      return CompanyModel.fromMap(row);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('updateMyCompany error: ${e.runtimeType}');
      throw const AppException(
        'Gagal menyimpan perusahaan. Periksa koneksi Anda.',
      );
    }
  }

  void _validate({
    String? name,
    String? email,
    String? website,
    required bool creating,
  }) {
    if (creating || name != null) {
      if (name == null || name.trim().isEmpty) {
        throw const AppException('Nama perusahaan wajib diisi.');
      }
      if (name.trim().length > 150) {
        throw const AppException('Nama perusahaan terlalu panjang.');
      }
    }
    final mail = _clean(email);
    if (mail != null && !BackendValidators.isValidEmail(mail)) {
      throw const AppException('Format email perusahaan tidak valid.');
    }
    final site = _clean(website);
    if (site != null && !BackendValidators.isValidHttpUrl(site)) {
      throw const AppException(
        'Website harus diawali http:// atau https:// dan valid.',
      );
    }
  }

  String? _clean(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? null : v;
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
    if (kDebugMode) debugPrint('[CompanyService] $text');
  }
}
