/// Hasil dari halaman filter lowongan. Lokasi dan jenis pekerjaan hanya
/// satu pilihan (filter utama), berbeda dengan preferensi rekomendasi.
class JobFilter {
  const JobFilter({this.keyword, this.location, this.jobType});

  final String? keyword;
  final String? location;

  /// Nilai database: Full-time, Part-time, Internship, atau Freelance.
  final String? jobType;

  bool get isEmpty =>
      (keyword == null || keyword!.trim().isEmpty) &&
      location == null &&
      jobType == null;
}
