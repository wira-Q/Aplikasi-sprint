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
  static const String statusOpen = 'Dibuka';
  static const String statusClosed = 'Ditutup';
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
    this.companyName,
    this.companyLogo,
    this.companyIndustry,
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

  // Dari relasi companies (jika ikut diambil).
  final String? companyName;
  final String? companyLogo;
  final String? companyIndustry;

  bool get isOpen => status == JobOptions.statusOpen;

  factory JobModel.fromMap(Map<String, dynamic> map) {
    final company = map['companies'];
    final companyMap = company is Map<String, dynamic> ? company : null;
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
      status: (map['status'] as String?) ?? JobOptions.statusOpen,
      companyName: companyMap?['company_name'] as String?,
      companyLogo: companyMap?['logo'] as String?,
      companyIndustry: companyMap?['industry'] as String?,
    );
  }
}
