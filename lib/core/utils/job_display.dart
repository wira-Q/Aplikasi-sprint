import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';

/// Pengubah data lowongan menjadi teks tampilan.
class JobDisplay {
  JobDisplay._();

  /// "Rp 6.000.000". String kosong jika gaji tidak dicantumkan.
  static String salary(num? value) {
    if (value == null || value <= 0) return '';
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return 'Rp $buffer';
  }

  /// Kolom skills berisi teks dipisah koma, titik koma, atau baris baru.
  static List<String> skillList(String? skills) {
    if (skills == null) return const [];
    final result = <String>[];
    for (final part in skills.split(RegExp(r'[,;\n]'))) {
      final skill = part.trim();
      if (skill.isNotEmpty && !result.contains(skill)) result.add(skill);
    }
    return result;
  }

  /// Tag di kartu lowongan: jenis, pendidikan, sistem kerja, lalu keahlian.
  static List<String> tags(JobModel job, {int maxSkills = 4}) {
    final education = job.education?.trim();
    final workSystem = job.workSystem?.trim();
    return [
      JobTypeLabels.of(job.jobType),
      if (education != null && education.isNotEmpty) education,
      if (workSystem != null && workSystem.isNotEmpty) workSystem,
      ...skillList(job.skills).take(maxSkills),
    ];
  }
}
