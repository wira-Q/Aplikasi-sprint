/// Nilai yang diizinkan database (sesuai CHECK constraint).
class JobOptions {
  JobOptions._();

  static const List<String> locations = ['Malang', 'Surabaya', 'Pasuruan'];
  static const List<String> jobTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Freelance',
  ];
  static const List<String> workSystems = ['WFA', 'WFO', 'Hybrid'];
  static const String statusOpen = 'Dibuka';
  static const String statusClosed = 'Ditutup';

  /// Batas tanggal tutup ke depan. Sama dengan trigger di database.
  static const int maxDeadlineDays = 365;
}

class JobModel {
  const JobModel({
    required this.idJob,
    required this.idCompany,
    required this.title,
    required this.description,
    required this.location,
    required this.jobType,
    required this.status,
    this.skills,
    this.education,
    this.workSystem,
    this.salary,
    this.deadline,
    this.companyName,
    this.companyLogo,
    this.companyIndustry,
    this.applicantCount = 0,
  });

  final int idJob;
  final int idCompany;
  final String title;
  final String description;
  final String location;
  final String jobType;
  final String status;
  final String? skills;
  final String? education;
  final String? workSystem;
  final double? salary;

  /// Hari terakhir lamaran diterima (waktu WIB). Null = tanpa batas.
  final DateTime? deadline;

  // Dari relasi companies (jika ikut diambil).
  final String? companyName;
  final String? companyLogo;
  final String? companyIndustry;

  /// Hanya terisi pada daftar lowongan milik recruiter (getMyJobs).
  final int applicantCount;

  /// Tanggal hari ini menurut WIB (tanpa jam). Database memakai zona yang sama.
  static DateTime todayWib() {
    final n = DateTime.now().toUtc().add(const Duration(hours: 7));
    return DateTime(n.year, n.month, n.day);
  }

  /// yyyy-MM-dd, format kolom date di database.
  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Tanggal tutup sudah lewat. Lowongan berakhir otomatis.
  bool get isExpired {
    final d = deadline;
    if (d == null) return false;
    return todayWib().isAfter(DateTime(d.year, d.month, d.day));
  }

  bool get isClosedManually => status == JobOptions.statusClosed;

  /// Dibuka dan belum lewat tanggal tutup.
  bool get isOpen => status == JobOptions.statusOpen && !isExpired;

  /// Sisa hari sampai tanggal tutup (0 = hari terakhir). Null jika tanpa
  /// batas atau sudah lewat.
  int? get daysLeft {
    final d = deadline;
    if (d == null) return null;
    final diff = DateTime(d.year, d.month, d.day).difference(todayWib()).inDays;
    return diff < 0 ? null : diff;
  }

  String get statusLabel =>
      isOpen ? 'Aktif' : (isClosedManually ? 'Ditutup' : 'Berakhir');

  JobModel withApplicantCount(int count) => JobModel(
    idJob: idJob,
    idCompany: idCompany,
    title: title,
    description: description,
    location: location,
    jobType: jobType,
    status: status,
    skills: skills,
    education: education,
    workSystem: workSystem,
    salary: salary,
    deadline: deadline,
    companyName: companyName,
    companyLogo: companyLogo,
    companyIndustry: companyIndustry,
    applicantCount: count,
  );

  factory JobModel.fromMap(Map<String, dynamic> map) {
    final company = map['companies'];
    final companyMap = company is Map<String, dynamic> ? company : null;
    final rawDeadline = map['deadline'];
    return JobModel(
      idJob: (map['id_job'] as num).toInt(),
      idCompany: (map['id_company'] as num).toInt(),
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      skills: map['skills'] as String?,
      education: map['education'] as String?,
      location: (map['location'] as String?) ?? '',
      jobType: (map['job_type'] as String?) ?? '',
      workSystem: map['work_system'] as String?,
      salary: (map['salary'] as num?)?.toDouble(),
      deadline: rawDeadline is String ? DateTime.tryParse(rawDeadline) : null,
      status: (map['status'] as String?) ?? JobOptions.statusOpen,
      companyName: companyMap?['company_name'] as String?,
      companyLogo: companyMap?['logo'] as String?,
      companyIndustry: companyMap?['industry'] as String?,
      applicantCount: _count(map['applications']),
    );
  }

  /// Hasil select "applications(count)" berbentuk [{count: n}].
  static int _count(Object? value) {
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map && first['count'] is num) {
        return (first['count'] as num).toInt();
      }
    }
    return 0;
  }
}
