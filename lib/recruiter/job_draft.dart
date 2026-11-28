/// Isian langkah 1 (Buat Lowongan) yang dibawa ke langkah 2.
class JobDraft {
  const JobDraft({
    required this.title,
    required this.description,
    required this.skills,
    required this.education,
    required this.experience,
    required this.location,
  });

  final String title;
  final String description;
  final List<String> skills;
  final String education;
  final String experience;
  final String location;

  /// Pengalaman tidak punya kolom sendiri; ditambahkan ke deskripsi.
  String get fullDescription =>
      '${description.trim()}\n\nPengalaman: $experience';

  /// Kolom skills berisi teks dipisah koma.
  String? get skillsText => skills.isEmpty ? null : skills.join(', ');
}
