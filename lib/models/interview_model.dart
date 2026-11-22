class InterviewStatus {
  InterviewStatus._();

  static const String dijadwalkan = 'Dijadwalkan';
  static const String selesai = 'Selesai';
  static const String dibatalkan = 'Dibatalkan';

  static const List<String> all = [dijadwalkan, selesai, dibatalkan];
}

/// Aturan link meeting. HARUS sama dengan fungsi validate_interview di database.
/// Untuk menambah penyedia lain (mis. Zoom), ubah di dua tempat itu.
class MeetingRules {
  MeetingRules._();

  static const int maxLinkLength = 500;
  static const int maxNotesLength = 1000;

  static final RegExp _meetLink = RegExp(
    r'^https://meet\.google\.com/[A-Za-z0-9_./?=&%-]+$',
  );

  /// Mengembalikan null jika valid, atau pesan error untuk pengguna.
  static String? validateLink(String? raw) {
    final link = raw?.trim() ?? '';
    if (link.isEmpty) return 'Link meeting wajib diisi.';
    if (link.length > maxLinkLength) return 'Link meeting terlalu panjang.';
    if (!_meetLink.hasMatch(link)) {
      return 'Link harus berupa link Google Meet yang diawali '
          'https://meet.google.com/';
    }
    return null;
  }
}

class InterviewModel {
  const InterviewModel({
    required this.idInterview,
    required this.idApplication,
    required this.interviewDate,
    required this.meetingLink,
    required this.status,
    this.notes,
    this.applicationStatus,
    this.jobTitle,
    this.jobLocation,
    this.companyName,
    this.applicantName,
    this.applicantEmail,
  });

  final int idInterview;
  final int idApplication;

  /// Sudah dikonversi ke zona waktu perangkat.
  final DateTime interviewDate;
  final String meetingLink;
  final String status;
  final String? notes;

  // Dari relasi applications, jobs, companies, dan users.
  final String? applicationStatus;
  final String? jobTitle;
  final String? jobLocation;
  final String? companyName;
  final String? applicantName;
  final String? applicantEmail;

  bool get isScheduled => status == InterviewStatus.dijadwalkan;

  factory InterviewModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? sub(Map<String, dynamic>? source, String key) {
      final value = source?[key];
      return value is Map<String, dynamic> ? value : null;
    }

    final app = sub(map, 'applications');
    final job = sub(app, 'jobs');
    final company = sub(job, 'companies');
    final user = sub(app, 'users');

    return InterviewModel(
      idInterview: (map['id_interview'] as num).toInt(),
      idApplication: (map['id_application'] as num).toInt(),
      interviewDate: DateTime.parse(map['interview_date'] as String).toLocal(),
      meetingLink: (map['meeting_link'] as String?) ?? '',
      status: (map['status'] as String?) ?? InterviewStatus.dijadwalkan,
      notes: map['notes'] as String?,
      applicationStatus: app?['status'] as String?,
      jobTitle: job?['title'] as String?,
      jobLocation: job?['location'] as String?,
      companyName: company?['company_name'] as String?,
      applicantName: user?['name'] as String?,
      applicantEmail: user?['email'] as String?,
    );
  }
}
