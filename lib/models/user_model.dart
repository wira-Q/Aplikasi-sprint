enum UserRole {
  jobSeeker('job_seeker'),
  recruiter('recruiter'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  /// Nilai tak dikenal diperlakukan sebagai hak paling rendah.
  static UserRole fromValue(String? value) => UserRole.values.firstWhere(
    (r) => r.value == value,
    orElse: () => UserRole.jobSeeker,
  );
}

class UserModel {
  const UserModel({
    required this.idUser,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.location,
    this.education,
    this.gender,
    this.photo,
    this.birthDate,
    this.preferredLocations = const [],
    this.preferredJobTypes = const [],
    this.createdAt,
  });

  final String idUser;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? location;

  /// Kolom di bawah ini hanya dipakai role job_seeker.
  final String? education;
  final String? gender;

  /// Path foto di Storage (bucket avatars), BUKAN URL.
  /// Ubah jadi URL dengan AvatarService.signedUrl(photo).
  final String? photo;
  final DateTime? birthDate;

  /// Untuk halaman rekomendasi (boleh lebih dari satu). Filter utama
  /// pencarian tetap satu lokasi.
  final List<String> preferredLocations;
  final List<String> preferredJobTypes;
  final DateTime? createdAt;

  /// Aturan "onboarding job seeker selesai". Halaman terakhir (lokasi)
  /// dianggap wajib. Ubah di sini jika aturannya berbeda.
  bool get isJobSeekerOnboardingComplete =>
      birthDate != null &&
      gender != null &&
      education != null &&
      preferredLocations.isNotEmpty;

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    idUser: map['id_user'] as String,
    name: (map['name'] as String?) ?? '',
    email: (map['email'] as String?) ?? '',
    role: UserRole.fromValue(map['role'] as String?),
    phone: map['phone'] as String?,
    location: map['location'] as String?,
    education: map['education'] as String?,
    gender: map['gender'] as String?,
    photo: map['photo'] as String?,
    birthDate: map['birth_date'] == null
        ? null
        : DateTime.parse(map['birth_date'] as String),
    preferredLocations: _stringList(map['preferred_locations']),
    preferredJobTypes: _stringList(map['preferred_job_types']),
    createdAt: map['created_at'] == null
        ? null
        : DateTime.parse(map['created_at'] as String).toLocal(),
  );

  static List<String> _stringList(Object? value) =>
      value is List ? value.map((e) => e.toString()).toList() : const [];
}
