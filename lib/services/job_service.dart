import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/postgrest_error_mapper.dart';
import '../models/company_model.dart';
import '../models/job_model.dart';
import 'company_service.dart';

class JobService {
  JobService({SupabaseClient? client, CompanyService? companyService})
    : _client = client ?? SupabaseConfig.client,
      _companies = companyService ?? CompanyService(client: client);

  final SupabaseClient _client;
  final CompanyService _companies;

  static const String _select = '*, companies(company_name, logo, industry)';
  static const int _maxPageSize = 50;

  // ---------------------------------------------------------------- JOB SEEKER

  /// Daftar lowongan Dibuka, dengan pencarian, filter, dan pagination.
  /// [page] dimulai dari 0.
  Future<List<JobModel>> getJobs({
    String? query,
    String? location,
    String? jobType,
    String? workSystem,
    String? education,
    int page = 0,
    int pageSize = 10,
  }) async {
    _requireUid();
    _validatePaging(page, pageSize);
    if (location != null && !JobOptions.locations.contains(location)) {
      throw const AppException('Lokasi filter tidak valid.');
    }
    if (jobType != null && !JobOptions.jobTypes.contains(jobType)) {
      throw const AppException('Jenis pekerjaan filter tidak valid.');
    }
    if (workSystem != null && !JobOptions.workSystems.contains(workSystem)) {
      throw const AppException('Sistem kerja filter tidak valid.');
    }
    try {
      var q = _client
          .from('jobs')
          .select(_select)
          .eq('status', JobOptions.statusOpen);

      final term = _sanitizeSearch(query);
      if (term.isNotEmpty) {
        q = q.or(
          'title.ilike.%$term%,skills.ilike.%$term%,description.ilike.%$term%',
        );
      }
      if (location != null) q = q.eq('location', location);
      if (jobType != null) q = q.eq('job_type', jobType);
      if (workSystem != null) q = q.eq('work_system', workSystem);
      if (education != null && education.trim().isNotEmpty) {
        q = q.eq('education', education.trim());
      }

      final from = page * pageSize;
      final rows = await q
          .order('id_job', ascending: false)
          .range(from, from + pageSize - 1);
      return rows.map((r) => JobModel.fromMap(r)).toList();
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getJobs error: ${e.runtimeType}');
      throw const AppException('Gagal memuat lowongan. Periksa koneksi Anda.');
    }
  }

  /// Detail satu lowongan. Null jika tidak ada atau tidak boleh dilihat.
  Future<JobModel?> getJobById(int idJob) async {
    _requireUid();
    try {
      final row = await _client
          .from('jobs')
          .select(_select)
          .eq('id_job', idJob)
          .maybeSingle();
      return row == null ? null : JobModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getJobById error: ${e.runtimeType}');
      throw const AppException('Gagal memuat lowongan. Periksa koneksi Anda.');
    }
  }

  // ----------------------------------------------------------------- RECRUITER

  /// Lowongan milik perusahaan sendiri (Dibuka dan Ditutup).
  Future<List<JobModel>> getMyJobs({
    String? status,
    int page = 0,
    int pageSize = 10,
  }) async {
    _validatePaging(page, pageSize);
    final company = await _requireMyCompany();
    try {
      var q = _client
          .from('jobs')
          .select(_select)
          .eq('id_company', company.idCompany);
      if (status != null) q = q.eq('status', status);

      final from = page * pageSize;
      final rows = await q
          .order('id_job', ascending: false)
          .range(from, from + pageSize - 1);
      return rows.map((r) => JobModel.fromMap(r)).toList();
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getMyJobs error: ${e.runtimeType}');
      throw const AppException('Gagal memuat lowongan. Periksa koneksi Anda.');
    }
  }

  Future<JobModel> createJob({
    required String title,
    required String description,
    required String location,
    required String jobType,
    String? workSystem,
    String? skills,
    String? education,
    num? salary,
  }) async {
    _validateFields(
      title: title,
      description: description,
      location: location,
      jobType: jobType,
      workSystem: workSystem,
      salary: salary,
      creating: true,
    );
    final company = await _requireMyCompany();
    try {
      final row = await _client
          .from('jobs')
          .insert({
            'id_company': company.idCompany,
            'title': title.trim(),
            'description': description.trim(),
            'location': location,
            'job_type': jobType,
            if (_clean(workSystem) != null) 'work_system': _clean(workSystem),
            if (_clean(skills) != null) 'skills': _clean(skills),
            if (_clean(education) != null) 'education': _clean(education),
            if (salary != null) 'salary': salary,
          })
          .select(_select)
          .single();
      return JobModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('createJob error: ${e.runtimeType}');
      throw const AppException('Gagal membuat lowongan. Periksa koneksi Anda.');
    }
  }

  /// Hanya field yang diisi (tidak null) yang diubah.
  /// String kosong pada field opsional mengosongkan nilainya.
  Future<JobModel> updateJob(
    int idJob, {
    String? title,
    String? description,
    String? location,
    String? jobType,
    String? workSystem,
    String? skills,
    String? education,
    num? salary,
  }) async {
    _requireUid();
    _validateFields(
      title: title,
      description: description,
      location: location,
      jobType: jobType,
      workSystem: workSystem,
      salary: salary,
      creating: false,
    );
    final changes = <String, dynamic>{
      if (title != null) 'title': title.trim(),
      if (description != null) 'description': description.trim(),
      if (location != null) 'location': location,
      if (jobType != null) 'job_type': jobType,
      if (workSystem != null) 'work_system': _clean(workSystem),
      if (skills != null) 'skills': _clean(skills),
      if (education != null) 'education': _clean(education),
      if (salary != null) 'salary': salary,
    };
    if (changes.isEmpty) {
      throw const AppException('Tidak ada data yang diubah.');
    }
    return _update(idJob, changes);
  }

  Future<JobModel> closeJob(int idJob) =>
      _update(idJob, {'status': JobOptions.statusClosed});

  Future<JobModel> reopenJob(int idJob) =>
      _update(idJob, {'status': JobOptions.statusOpen});

  // ------------------------------------------------------------------- HELPERS

  Future<JobModel> _update(int idJob, Map<String, dynamic> changes) async {
    _requireUid();
    try {
      final row = await _client
          .from('jobs')
          .update(changes)
          .eq('id_job', idJob)
          .select(_select)
          .maybeSingle();
      if (row == null) {
        // RLS menyaring baris yang bukan milik pengguna: hasilnya kosong,
        // bukan error.
        throw const AppException(
          'Lowongan tidak ditemukan atau Anda tidak berwenang.',
          code: 'not_found',
        );
      }
      return JobModel.fromMap(row);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('update error: ${e.runtimeType}');
      throw const AppException(
        'Gagal menyimpan lowongan. Periksa koneksi Anda.',
      );
    }
  }

  Future<CompanyModel> _requireMyCompany() async {
    final company = await _companies.getMyCompany();
    if (company == null) {
      throw const AppException(
        'Lengkapi profil perusahaan terlebih dahulu.',
        code: 'no_company',
      );
    }
    return company;
  }

  void _validateFields({
    String? title,
    String? description,
    String? location,
    String? jobType,
    String? workSystem,
    num? salary,
    required bool creating,
  }) {
    if (creating || title != null) {
      if (title == null || title.trim().isEmpty) {
        throw const AppException('Judul lowongan wajib diisi.');
      }
      if (title.trim().length > 150) {
        throw const AppException('Judul lowongan terlalu panjang.');
      }
    }
    if (creating || description != null) {
      if (description == null || description.trim().isEmpty) {
        throw const AppException('Deskripsi lowongan wajib diisi.');
      }
    }
    if (creating || location != null) {
      if (location == null || !JobOptions.locations.contains(location)) {
        throw const AppException(
          'Lokasi harus Malang, Surabaya, atau Pasuruan.',
        );
      }
    }
    if (creating || jobType != null) {
      if (jobType == null || !JobOptions.jobTypes.contains(jobType)) {
        throw const AppException('Jenis pekerjaan tidak valid.');
      }
    }
    // Kolom work_system boleh kosong, tetapi jika diisi harus WFA/WFO/Hybrid.
    if (workSystem != null &&
        workSystem.trim().isNotEmpty &&
        !JobOptions.workSystems.contains(workSystem.trim())) {
      throw const AppException('Sistem kerja tidak valid.');
    }
    if (salary != null && (salary.isNaN || salary.isInfinite || salary < 0)) {
      throw const AppException('Gaji tidak boleh negatif.');
    }
  }

  void _validatePaging(int page, int pageSize) {
    if (page < 0 || pageSize < 1 || pageSize > _maxPageSize) {
      throw const AppException('Parameter halaman tidak valid.');
    }
  }

  /// Membuang karakter yang merusak sintaks filter PostgREST.
  String _sanitizeSearch(String? raw) {
    if (raw == null) return '';
    final cleaned = raw.replaceAll(RegExp(r'[,()%*\\"]'), ' ').trim();
    return cleaned.length > 50 ? cleaned.substring(0, 50) : cleaned;
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
    if (kDebugMode) debugPrint('[JobService] $text');
  }
}
