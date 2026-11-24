/// Pilihan pendidikan. HARUS sama dengan CHECK users_education_check dan
/// jobs_education_check di database. Dipakai dropdown di onboarding job
/// seeker dan form buat lowongan recruiter.
class EducationOptions {
  EducationOptions._();

  static const List<String> values = ['SMA/SMK', 'D3', 'D4', 'S1', 'S2', 'S3'];

  static bool isValid(String? value) => value != null && values.contains(value);
}

/// Label tampilan jenis pekerjaan. Nilai yang disimpan tetap nilai database
/// (Full-time, Part-time, Internship, Freelance); hanya tampilannya yang
/// berbeda, misalnya Internship tampil sebagai "Magang".
class JobTypeLabels {
  JobTypeLabels._();

  static const Map<String, String> _labels = {'Internship': 'Magang'};

  static String of(String value) => _labels[value] ?? value;
}

class ProfileRules {
  ProfileRules._();

  /// Harus sama dengan trigger validate_user_profile di database.
  static const int minAge = 15;
  static const int maxAge = 80;

  /// Mengembalikan null jika valid, atau pesan error untuk pengguna.
  static String? validateBirthDate(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final latest = DateTime(today.year - minAge, today.month, today.day);
    final earliest = DateTime(today.year - maxAge, today.month, today.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day.isAfter(latest)) return 'Usia minimal $minAge tahun.';
    if (day.isBefore(earliest)) return 'Tanggal lahir tidak valid.';
    return null;
  }
}
