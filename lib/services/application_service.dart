import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/postgrest_error_mapper.dart';
import '../models/application_model.dart';
import '../models/paged_result.dart';

class ApplicationService {
  ApplicationService({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _seekerSelect =
      '*, jobs(title, location, job_type, companies(company_name, logo))';
  static const String _recruiterSelect =
      '*, users(name, email, phone, education, location, photo), '
      'cvs(file_name, file_size, file_url), jobs(title, location)';
  static const int _maxMessage = 1000;
  static const int _maxPageSize = 50;

  // ---------------------------------------------------------------- JOB SEEKER

  Future<ApplicationModel> apply({
    required int idJob,
    required int idCv,
    String? message,
  }) async {
    final uid = _requireUid();
    final text = message?.trim();
    if (text != null && text.length > _maxMessage) {
      throw const AppException('Pesan maksimal 1000 karakter.');
    }
    try {
      final row = await _client
          .from('applications')
          .insert({
            'id_job': idJob,
            'id_user': uid,
            'id_cv': idCv,
            if (text != null && text.isNotEmpty) 'message': text,
          })
          .select(_seekerSelect)
          .single();
      return ApplicationModel.fromMap(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AppException(
          'Anda sudah melamar lowongan ini.',
          code: 'duplicate_application',
        );
      }
      if (e.code == '42501') {
        throw const AppException(
          'Lamaran tidak dapat dikirim. Pastikan lowongan masih dibuka '
          '(belum lewat tanggal tutup) dan CV adalah milik Anda.',
          code: 'forbidden',
        );
      }
      throw mapPostgrestError(e);
    } catch (e) {
      _log('apply error: ${e.runtimeType}');
      throw const AppException('Gagal mengirim lamaran. Periksa koneksi Anda.');
    }
  }

  /// Apakah pengguna yang login sudah melamar lowongan ini. Dipakai untuk
  /// menonaktifkan tombol "Lamar" sebelum ditekan. Database tetap menolak
  /// lamaran ganda (UNIQUE id_user, id_job) walaupun pemeriksaan ini dilewati.
  Future<bool> hasApplied(int idJob) async {
    final uid = _requireUid();
    try {
      final row = await _client
          .from('applications')
          .select('id_application')
          .eq('id_job', idJob)
          .eq('id_user', uid)
          .maybeSingle();
      return row != null;
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('hasApplied error: ${e.runtimeType}');
      throw const AppException(
        'Gagal memeriksa lamaran. Periksa koneksi Anda.',
      );
    }
  }

  Future<PagedResult<ApplicationModel>> getMyApplicationsPage({
    int page = 0,
    int pageSize = kPageSize,
  }) async {
    final uid = _requireUid();
    _validatePaging(page, pageSize);
    try {
      final from = page * pageSize;
      final res = await _client
          .from('applications')
          .select(_seekerSelect)
          .eq('id_user', uid)
          .order('applied_at', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);
      return PagedResult<ApplicationModel>(
        items: res.data.map((r) => ApplicationModel.fromMap(r)).toList(),
        total: res.count,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getMyApplicationsPage error: ${e.runtimeType}');
      throw const AppException('Gagal memuat lamaran. Periksa koneksi Anda.');
    }
  }

  Future<List<ApplicationModel>> getMyApplications({
    int page = 0,
    int pageSize = 10,
  }) async =>
      (await getMyApplicationsPage(page: page, pageSize: pageSize)).items;

  Future<ApplicationModel?> getMyApplicationById(int idApplication) async {
    final uid = _requireUid();
    try {
      final row = await _client
          .from('applications')
          .select(_seekerSelect)
          .eq('id_application', idApplication)
          .eq('id_user', uid)
          .maybeSingle();
      return row == null ? null : ApplicationModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getMyApplicationById error: ${e.runtimeType}');
      throw const AppException('Gagal memuat lamaran. Periksa koneksi Anda.');
    }
  }

  // ----------------------------------------------------------------- RECRUITER

  /// Pelamar pada lowongan milik recruiter. RLS membatasi hasilnya,
  /// filter idJob hanya mempersempit.
  Future<PagedResult<ApplicationModel>> getApplicantsPage({
    int? idJob,
    String? status,
    int page = 0,
    int pageSize = kPageSize,
  }) async {
    _requireUid();
    _validatePaging(page, pageSize);
    if (status != null && !ApplicationStatus.all.contains(status)) {
      throw const AppException('Status filter tidak valid.');
    }
    try {
      var q = _client.from('applications').select(_recruiterSelect);
      if (idJob != null) q = q.eq('id_job', idJob);
      if (status != null) q = q.eq('status', status);

      final from = page * pageSize;
      final res = await q
          .order('applied_at', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);
      return PagedResult<ApplicationModel>(
        items: res.data.map((r) => ApplicationModel.fromMap(r)).toList(),
        total: res.count,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getApplicantsPage error: ${e.runtimeType}');
      throw const AppException('Gagal memuat pelamar. Periksa koneksi Anda.');
    }
  }

  Future<List<ApplicationModel>> getApplicants({
    int? idJob,
    String? status,
    int page = 0,
    int pageSize = 10,
  }) async => (await getApplicantsPage(
    idJob: idJob,
    status: status,
    page: page,
    pageSize: pageSize,
  )).items;

  Future<ApplicationModel?> getApplicantById(int idApplication) async {
    _requireUid();
    try {
      final row = await _client
          .from('applications')
          .select(_recruiterSelect)
          .eq('id_application', idApplication)
          .maybeSingle();
      return row == null ? null : ApplicationModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getApplicantById error: ${e.runtimeType}');
      throw const AppException('Gagal memuat pelamar. Periksa koneksi Anda.');
    }
  }

  /// Perpindahan status dicek di filter UPDATE (atomik): baris hanya
  /// berubah jika status saat ini termasuk status asal yang diizinkan.
  Future<ApplicationModel> updateStatus(
    int idApplication,
    String newStatus,
  ) async {
    _requireUid();
    final allowedFrom = ApplicationStatus.allowedFrom[newStatus];
    if (allowedFrom == null) {
      throw const AppException('Status tujuan tidak valid.');
    }
    try {
      final row = await _client
          .from('applications')
          .update({'status': newStatus})
          .eq('id_application', idApplication)
          .inFilter('status', allowedFrom)
          .select(_recruiterSelect)
          .maybeSingle();
      if (row == null) {
        throw const AppException(
          'Status tidak dapat diubah. Lamaran tidak ditemukan, bukan milik '
          'lowongan Anda, atau perpindahan status tidak diizinkan.',
          code: 'transition_denied',
        );
      }
      return ApplicationModel.fromMap(row);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('updateStatus error: ${e.runtimeType}');
      throw const AppException('Gagal mengubah status. Periksa koneksi Anda.');
    }
  }

  // ------------------------------------------------------------------- HELPERS

  void _validatePaging(int page, int pageSize) {
    if (page < 0 || pageSize < 1 || pageSize > _maxPageSize) {
      throw const AppException('Parameter halaman tidak valid.');
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
    if (kDebugMode) debugPrint('[ApplicationService] $text');
  }
}
