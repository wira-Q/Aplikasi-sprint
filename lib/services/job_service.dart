import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/postgrest_error_mapper.dart';
import '../models/company_model.dart';
import '../models/job_model.dart';
import '../models/paged_result.dart';
import '../models/profile_options.dart';
import 'company_service.dart';

class JobService {
  JobService({SupabaseClient? client, CompanyService? companyService})
    : _client = client ?? SupabaseConfig.client,
      _companies = companyService ?? CompanyService(client: client);

  final SupabaseClient _client;
  final CompanyService _companies;

  static const String _select = '*, companies(company_name, logo, industry)';

  /// Khusus daftar lowongan recruiter: ikut menghitung jumlah pelamar.
  static const String _recruiterSelect =
      '*, companies(company_name, logo, industry), applications(count)';
  static const int _maxPageSize = 50;

  String? _cachedUid;
  CompanyModel? _cachedCompany;

  /// Lowongan yang belum lewat tanggal tutup. Database juga menjaganya lewat
  /// RLS, tetapi pelamar lama masih boleh melihat lowongan yang berakhir
  /// (untuk riwayat), jadi daftar pencarian memfilternya sendiri.
  String get _notExpiredFilter =>
      'deadline.is.null,deadline.gte.${JobModel.isoDate(JobModel.todayWib())}';

  // ---------------------------------------------------------------- JOB SEEKER

  /// Daftar lowongan dibuka dengan pencarian, filter, dan nomor halaman.
  /// Filter utama menerima SATU lokasi. [page] dimulai dari 0.
  Future<PagedResult<JobModel>> getJobsPage({
    String? query,
    String? location,
    String? jobType,
    String? workSystem,
    String? education,
    int page = 0,
    int pageSize = kPageSize,
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
    final educationFilter = _clean(education);
    if (educationFilter != null && !EducationOptions.isValid(educationFilter)) {
      throw const AppException('Pendidikan filter tidak valid.');
    }
    try {
      var q = _client
          .from('jobs')
          .select(_select)
          .eq('status', JobOptions.statusOpen)
          .or(_notExpiredFilter);

      final term = _sanitizeSearch(query);
      if (term.isNotEmpty) {
        q = q.or(
          'title.ilike.%$term%,skills.ilike.%$term%,description.ilike.%$term%',
        );
      }
      if (location != null) q = q.eq('location', location);
      if (jobType != null) q = q.eq('job_type', jobType);
      if (workSystem != null) q = q.eq('work_system', workSystem);
      if (educationFilter != null) q = q.eq('education', educationFilter);

      final from = page * pageSize;
      final res = await q
          .order('id_job', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);
      return PagedResult<JobModel>(
        items: res.data.map((r) => JobModel.fromMap(r)).toList(),
        total: res.count,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getJobsPage error: ${e.runtimeType}');
      throw const AppException('Gagal memuat lowongan. Periksa koneksi Anda.');
    }
  }

  Future<List<JobModel>> getJobs({
    String? query,
    String? location,
    String? jobType,
    String? workSystem,
    String? education,
    int page = 0,
    int pageSize = 10,
  }) async => (await getJobsPage(
    query: query,
    location: location,
    jobType: jobType,
    workSystem: workSystem,
    education: education,
    page: page,
    pageSize: pageSize,
  )).items;

  /// Halaman rekomendasi: boleh banyak lokasi dan jenis pekerjaan, diambil
  /// dari preferensi di profil. Daftar kosong berarti tidak difilter.
  Future<PagedResult<JobModel>> getRecommendedJobsPage({
    List<String> locations = const [],
    List<String> jobTypes = const [],
    int page = 0,
    int pageSize = kPageSize,
  }) async {
    _requireUid();
    _validatePaging(page, pageSize);
    if (locations.any((l) => !JobOptions.locations.contains(l))) {
      throw const AppException('Lokasi rekomendasi tidak valid.');
    }
    if (jobTypes.any((t) => !JobOptions.jobTypes.contains(t))) {
      throw const AppException('Jenis pekerjaan rekomendasi tidak valid.');
    }
    try {
      var q = _client
          .from('jobs')
          .select(_select)
          .eq('status', JobOptions.statusOpen)
          .or(_notExpiredFilter);
      if (locations.isNotEmpty) q = q.inFilter('location', locations);
      if (jobTypes.isNotEmpty) q = q.inFilter('job_type', jobTypes);

      final from = page * pageSize;
      final res = await q
          .order('id_job', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);
      return PagedResult<JobModel>(
        items: res.data.map((r) => JobModel.fromMap(r)).toList(),
        total: res.count,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getRecommendedJobsPage error: ${e.runtimeType}');
      throw const AppException('Gagal memuat lowongan. Periksa koneksi Anda.');
    }
  }

  Future<List<JobModel>> getRecommendedJobs({
    List<String> locations = const [],
    List<String> jobTypes = const [],
    int page = 0,
    int pageSize = 10,
  }) async => (await getRecommendedJobsPage(
    locations: locations,
    jobTypes: jobTypes,
    page: page,
    pageSize: pageSize,
  )).items;

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

  /// Lowongan milik perusahaan sendiri (Dibuka, Ditutup, dan Berakhir),
  /// beserta jumlah pelamar. [query] mencari pada judul.
  Future<PagedResult<JobModel>> getMyJobsPage({
    String? status,
    String? query,
    int page = 0,
    int pageSize = kPageSize,
  }) async {
    _validatePaging(page, pageSize);
    final company = await _requireMyCompany();
    try {
      var q = _client
          .from('jobs')
          .select(_recruiterSelect)
          .eq('id_company', company.idCompany);
      if (status != null) q = q.eq('status', status);
      final term = _sanitizeSearch(query);
      if (term.isNotEmpty) q = q.ilike('title', '%$term%');

      final from = page * pageSize;
      final res = await q
          .order('id_job', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);
      return PagedResult<JobModel>(
        items: res.data.map((r) => JobModel.fromMap(r)).toList(),
        total: res.count,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getMyJobsPage error: ${e.runtimeType}');
      throw const AppException('Gagal memuat lowongan. Periksa koneksi Anda.');
    }
  }

  Future<List<JobModel>> getMyJobs({
    String? status,
    String? query,
    int page = 0,
    int pageSize = 10,
  }) async => (await getMyJobsPage(
    status: status,
    query: query,
    page: page,
    pageSize: pageSize,
  )).items;

  Future<JobModel> createJob({
    required String title,
    required String description,
    required String location,
    required String jobType,
    String? workSystem,
    String? skills,
    String? education,
    num? salary,
    DateTime? deadline,
  }) async {
    _validateFields(
      title: title,
      description: description,
      location: location,
      jobType: jobType,
      workSystem: workSystem,
      education: education,
      salary: salary,
      deadline: deadline,
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
            if (deadline != null) 'deadline': JobModel.isoDate(deadline),
          })
          .select(_select)
          .single();
      return JobModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw _mapJobError(e);
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
    DateTime? deadline,
  }) async {
    _requireUid();
    _validateFields(
      title: title,
      description: description,
      location: location,
      jobType: jobType,
      workSystem: workSystem,
      education: education,
      salary: salary,
      deadline: deadline,
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
      if (deadline != null) 'deadline': JobModel.isoDate(deadline),
    };
    if (changes.isEmpty) {
      throw const AppException('Tidak ada data yang diubah.');
    }
    return _update(idJob, changes);
  }

  Future<JobModel> closeJob(int idJob) =>
      _update(idJob, {'status': JobOptions.statusClosed});

  /// Membuka kembali lowongan. Jika tanggal tutupnya sudah lewat, wajib
  /// mengisi [newDeadline]; database menolak tanggal yang sudah lewat.
  Future<JobModel> reopenJob(int idJob, {DateTime? newDeadline}) {
    _validateDeadline(newDeadline);
    return _update(idJob, {
      'status': JobOptions.statusOpen,
      if (newDeadline != null) 'deadline': JobModel.isoDate(newDeadline),
    });
  }

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
      throw _mapJobError(e);
    } catch (e) {
      _log('update error: ${e.runtimeType}');
      throw const AppException(
        'Gagal menyimpan lowongan. Periksa koneksi Anda.',
      );
    }
  }

  AppException _mapJobError(PostgrestException e) {
    if (e.code == 'P0001') {
      final msg = e.message;
      if (msg.contains('JOB_BAD_DEADLINE')) {
        return const AppException(
          'Tanggal tutup harus antara hari ini dan 365 hari ke depan.',
          code: 'bad_deadline',
        );
      }
      if (msg.contains('JOB_DEADLINE_PASSED')) {
        return const AppException(
          'Tanggal tutup sudah lewat. Pilih tanggal tutup yang baru.',
          code: 'deadline_passed',
        );
      }
    }
    return mapPostgrestError(e);
  }

  Future<CompanyModel> _requireMyCompany() async {
    final uid = _requireUid();
    final cached = _cachedCompany;
    if (cached != null && _cachedUid == uid) return cached;

    final company = await _companies.getMyCompany();
    if (company == null) {
      throw const AppException(
        'Lengkapi profil perusahaan terlebih dahulu.',
        code: 'no_company',
      );
    }
    _cachedUid = uid;
    _cachedCompany = company;
    return company;
  }

  void _validateDeadline(DateTime? deadline) {
    if (deadline == null) return;
    final today = JobModel.todayWib();
    final d = DateTime(deadline.year, deadline.month, deadline.day);
    final last = today.add(const Duration(days: JobOptions.maxDeadlineDays));
    if (d.isBefore(today) || d.isAfter(last)) {
      throw const AppException(
        'Tanggal tutup harus antara hari ini dan 365 hari ke depan.',
      );
    }
  }

  void _validateFields({
    String? title,
    String? description,
    String? location,
    String? jobType,
    String? workSystem,
    String? education,
    num? salary,
    DateTime? deadline,
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
    // work_system boleh kosong, tetapi jika diisi harus WFA/WFO/Hybrid.
    if (workSystem != null &&
        workSystem.trim().isNotEmpty &&
        !JobOptions.workSystems.contains(workSystem.trim())) {
      throw const AppException('Sistem kerja tidak valid.');
    }
    // education boleh kosong, tetapi jika diisi harus salah satu pilihan.
    final edu = _clean(education);
    if (edu != null && !EducationOptions.isValid(edu)) {
      throw const AppException('Pilihan pendidikan tidak valid.');
    }
    if (salary != null && (salary.isNaN || salary.isInfinite || salary < 0)) {
      throw const AppException('Gaji tidak boleh negatif.');
    }
    _validateDeadline(deadline);
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
