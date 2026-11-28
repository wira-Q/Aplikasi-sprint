class ApplicationStatus {
  ApplicationStatus._();

  static const String diproses = 'Diproses';
  static const String interview = 'Interview';
  static const String diterima = 'Diterima';
  static const String ditolak = 'Ditolak';

  static const List<String> all = [diproses, interview, diterima, ditolak];

  /// Status tujuan -> status asal yang boleh menuju ke sana.
  static const Map<String, List<String>> allowedFrom = {
    interview: [diproses],
    diterima: [interview],
    ditolak: [diproses, interview],
  };
}

class ApplicationModel {
  const ApplicationModel({
    required this.idApplication,
    required this.idJob,
    required this.idUser,
    required this.idCv,
    required this.status,
    this.message,
    this.appliedAt,
    this.jobTitle,
    this.jobLocation,
    this.jobType,
    this.companyName,
    this.companyLogo,
    this.applicantName,
    this.applicantEmail,
    this.applicantPhone,
    this.applicantEducation,
    this.applicantLocation,
    this.applicantPhoto,
    this.cvFileName,
    this.cvFileSize,
    this.cvPath,
  });

  final int idApplication;
  final int idJob;
  final String idUser;
  final int idCv;
  final String status;
  final String? message;
  final DateTime? appliedAt;

  // Dari relasi jobs dan companies (sisi job seeker).
  final String? jobTitle;
  final String? jobLocation;
  final String? jobType;
  final String? companyName;

  /// Path logo di bucket logos. Ubah jadi URL dengan LogoService.publicUrl.
  final String? companyLogo;

  // Dari relasi users (sisi recruiter).
  final String? applicantName;
  final String? applicantEmail;
  final String? applicantPhone;
  final String? applicantEducation;
  final String? applicantLocation;

  /// Path foto di bucket avatars. Ubah jadi URL dengan
  /// AvatarService.signedUrl.
  final String? applicantPhoto;

  // Dari relasi cvs (sisi recruiter).
  final String? cvFileName;
  final int? cvFileSize;
  final String? cvPath;

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? sub(Map<String, dynamic>? source, String key) {
      final value = source?[key];
      return value is Map<String, dynamic> ? value : null;
    }

    final job = sub(map, 'jobs');
    final company = sub(job, 'companies');
    final user = sub(map, 'users');
    final cv = sub(map, 'cvs');

    return ApplicationModel(
      idApplication: (map['id_application'] as num).toInt(),
      idJob: (map['id_job'] as num).toInt(),
      idUser: map['id_user'] as String,
      idCv: (map['id_cv'] as num).toInt(),
      status: (map['status'] as String?) ?? ApplicationStatus.diproses,
      message: map['message'] as String?,
      appliedAt: map['applied_at'] == null
          ? null
          : DateTime.parse(map['applied_at'] as String).toLocal(),
      jobTitle: job?['title'] as String?,
      jobLocation: job?['location'] as String?,
      jobType: job?['job_type'] as String?,
      companyName: company?['company_name'] as String?,
      companyLogo: company?['logo'] as String?,
      applicantName: user?['name'] as String?,
      applicantEmail: user?['email'] as String?,
      applicantPhone: user?['phone'] as String?,
      applicantEducation: user?['education'] as String?,
      applicantLocation: user?['location'] as String?,
      applicantPhoto: user?['photo'] as String?,
      cvFileName: cv?['file_name'] as String?,
      cvFileSize: (cv?['file_size'] as num?)?.toInt(),
      cvPath: cv?['file_url'] as String?,
    );
  }
}
