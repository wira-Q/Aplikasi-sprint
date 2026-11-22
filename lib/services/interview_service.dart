import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/postgrest_error_mapper.dart';
import '../models/interview_model.dart';

class InterviewService {
  InterviewService({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const String _select =
      '*, applications(status, jobs(title, location, companies(company_name)), '
      'users(name, email))';
  static const int _maxPageSize = 50;

  // ----------------------------------------------------------------- RECRUITER

  /// Hanya untuk lamaran berstatus Interview milik lowongan sendiri.
  /// [dateTime] adalah waktu lokal perangkat; dikirim sebagai UTC.
  Future<InterviewModel> schedule({
    required int idApplication,
    required DateTime dateTime,
    required String meetingLink,
    String? notes,
  }) async {
    _requireUid();
    _validateDate(dateTime);
    _validateLink(meetingLink);
    _validateNotes(notes);
    try {
      final row = await _client
          .from('interviews')
          .insert({
            'id_application': idApplication,
            'interview_date': dateTime.toUtc().toIso8601String(),
            'meeting_link': meetingLink.trim(),
            if (_clean(notes) != null) 'notes': _clean(notes),
          })
          .select(_select)
          .single();
      return InterviewModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      _log('schedule error: ${e.runtimeType}');
      throw const AppException('Gagal membuat jadwal. Periksa koneksi Anda.');
    }
  }

  /// Hanya field yang diisi (tidak null) yang diubah.
  /// Berlaku selama interview masih Dijadwalkan.
  Future<InterviewModel> reschedule(
    int idInterview, {
    DateTime? dateTime,
    String? meetingLink,
    String? notes,
  }) async {
    _requireUid();
    if (dateTime != null) _validateDate(dateTime);
    if (meetingLink != null) _validateLink(meetingLink);
    _validateNotes(notes);
    final changes = <String, dynamic>{
      if (dateTime != null)
        'interview_date': dateTime.toUtc().toIso8601String(),
      if (meetingLink != null) 'meeting_link': meetingLink.trim(),
      if (notes != null) 'notes': _clean(notes),
    };
    if (changes.isEmpty) {
      throw const AppException('Tidak ada data yang diubah.');
    }
    return _update(idInterview, changes);
  }

  Future<InterviewModel> cancel(int idInterview) =>
      _update(idInterview, {'status': InterviewStatus.dibatalkan});

  Future<InterviewModel> complete(int idInterview) =>
      _update(idInterview, {'status': InterviewStatus.selesai});

  // ------------------------------------------------- RECRUITER DAN JOB SEEKER

  /// Interview sesuai hak akses akun (RLS): milik pelamar sendiri,
  /// atau pada lowongan milik recruiter.
  Future<List<InterviewModel>> getInterviews({
    String? status,
    int page = 0,
    int pageSize = 10,
  }) async {
    _requireUid();
    _validatePaging(page, pageSize);
    if (status != null && !InterviewStatus.all.contains(status)) {
      throw const AppException('Status filter tidak valid.');
    }
    try {
      var q = _client.from('interviews').select(_select);
      if (status != null) q = q.eq('status', status);
      final from = page * pageSize;
      final rows = await q
          .order('interview_date', ascending: false)
          .range(from, from + pageSize - 1);
      return rows.map((r) => InterviewModel.fromMap(r)).toList();
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getInterviews error: ${e.runtimeType}');
      throw const AppException('Gagal memuat interview. Periksa koneksi Anda.');
    }
  }

  Future<List<InterviewModel>> getByApplication(int idApplication) async {
    _requireUid();
    try {
      final rows = await _client
          .from('interviews')
          .select(_select)
          .eq('id_application', idApplication)
          .order('interview_date', ascending: false);
      return rows.map((r) => InterviewModel.fromMap(r)).toList();
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getByApplication error: ${e.runtimeType}');
      throw const AppException('Gagal memuat interview. Periksa koneksi Anda.');
    }
  }

  /// Interview aktif (Dijadwalkan) pada satu lamaran, atau null jika belum ada.
  /// Dipakai halaman "link meeting" milik job seeker.
  Future<InterviewModel?> getActiveForApplication(int idApplication) async {
    _requireUid();
    try {
      final row = await _client
          .from('interviews')
          .select(_select)
          .eq('id_application', idApplication)
          .eq('status', InterviewStatus.dijadwalkan)
          .maybeSingle();
      return row == null ? null : InterviewModel.fromMap(row);
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getActiveForApplication error: ${e.runtimeType}');
      throw const AppException('Gagal memuat interview. Periksa koneksi Anda.');
    }
  }

  // ------------------------------------------------------------------- HELPERS

  /// Filter status Dijadwalkan membuat perubahan atomik: baris yang sudah
  /// Selesai/Dibatalkan tidak tersentuh.
  Future<InterviewModel> _update(
    int idInterview,
    Map<String, dynamic> changes,
  ) async {
    _requireUid();
    try {
      final row = await _client
          .from('interviews')
          .update(changes)
          .eq('id_interview', idInterview)
          .eq('status', InterviewStatus.dijadwalkan)
          .select(_select)
          .maybeSingle();
      if (row == null) {
        throw const AppException(
          'Interview tidak ditemukan, bukan milik lowongan Anda, atau sudah '
          'selesai/dibatalkan.',
          code: 'not_found',
        );
      }
      return InterviewModel.fromMap(row);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _mapError(e);
    } catch (e) {
      _log('update error: ${e.runtimeType}');
      throw const AppException('Gagal menyimpan jadwal. Periksa koneksi Anda.');
    }
  }

  AppException _mapError(PostgrestException e) {
    _log('PostgrestException code=${e.code}');
    if (e.code == 'P0001') {
      final msg = e.message;
      if (msg.contains('INTERVIEW_APP_NOT_INTERVIEW')) {
        return const AppException(
          'Jadwal hanya bisa dibuat untuk lamaran berstatus Interview.',
          code: 'app_not_interview',
        );
      }
      if (msg.contains('INTERVIEW_PAST_DATE')) {
        return const AppException(
          'Tanggal interview harus di masa depan.',
          code: 'past_date',
        );
      }
      if (msg.contains('INTERVIEW_BAD_LINK')) {
        return const AppException(
          'Link meeting harus berupa link Google Meet yang valid.',
          code: 'bad_link',
        );
      }
      if (msg.contains('INTERVIEW_LOCKED') ||
          msg.contains('INTERVIEW_BAD_TRANSITION')) {
        return const AppException(
          'Interview ini sudah selesai/dibatalkan dan tidak dapat diubah.',
          code: 'locked',
        );
      }
    }
    if (e.code == '23505') {
      return const AppException(
        'Lamaran ini sudah punya jadwal interview aktif. Ubah atau batalkan '
        'jadwal yang ada.',
        code: 'duplicate_schedule',
      );
    }
    if (e.code == '42501') {
      return const AppException(
        'Anda tidak berwenang mengatur interview untuk lamaran ini.',
        code: 'forbidden',
      );
    }
    return mapPostgrestError(e);
  }

  void _validateDate(DateTime dateTime) {
    if (!dateTime.isAfter(DateTime.now())) {
      throw const AppException(
        'Tanggal interview harus di masa depan.',
        code: 'past_date',
      );
    }
  }

  void _validateLink(String link) {
    final error = MeetingRules.validateLink(link);
    if (error != null) throw AppException(error, code: 'bad_link');
  }

  void _validateNotes(String? notes) {
    if (notes != null && notes.trim().length > MeetingRules.maxNotesLength) {
      throw const AppException('Catatan maksimal 1000 karakter.');
    }
  }

  void _validatePaging(int page, int pageSize) {
    if (page < 0 || pageSize < 1 || pageSize > _maxPageSize) {
      throw const AppException('Parameter halaman tidak valid.');
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
    if (kDebugMode) debugPrint('[InterviewService] $text');
  }
}
