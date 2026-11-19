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
    this.createdAt,
  });

  final String idUser;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? location;
  final String? education;
  final String? gender;
  final DateTime? createdAt;

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    idUser: map['id_user'] as String,
    name: (map['name'] as String?) ?? '',
    email: (map['email'] as String?) ?? '',
    role: UserRole.fromValue(map['role'] as String?),
    phone: map['phone'] as String?,
    location: map['location'] as String?,
    education: map['education'] as String?,
    gender: map['gender'] as String?,
    createdAt: map['created_at'] == null
        ? null
        : DateTime.parse(map['created_at'] as String).toLocal(),
  );
}
