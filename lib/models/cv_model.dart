/// Aturan CV. Nilainya HARUS sama dengan pengaturan bucket di database.
class CvRules {
  CvRules._();

  static const String bucket = 'cvs';
  static const String mimeType = 'application/pdf';
  static const int maxBytes = 5 * 1024 * 1024; // 5 MB
  static const int signedUrlSeconds = 300; // 5 menit
}

class CvModel {
  const CvModel({
    required this.idCv,
    required this.idUser,
    required this.fileName,
    required this.filePath,
    this.fileSize,
    this.uploadedAt,
  });

  final int idCv;
  final String idUser;
  final String fileName;

  /// Path objek di Storage (kolom file_url). BUKAN URL publik.
  final String filePath;
  final int? fileSize;
  final DateTime? uploadedAt;

  factory CvModel.fromMap(Map<String, dynamic> map) => CvModel(
    idCv: (map['id_cv'] as num).toInt(),
    idUser: map['id_user'] as String,
    fileName: (map['file_name'] as String?) ?? '',
    filePath: (map['file_url'] as String?) ?? '',
    fileSize: (map['file_size'] as num?)?.toInt(),
    uploadedAt: map['uploaded_at'] == null
        ? null
        : DateTime.parse(map['uploaded_at'] as String).toLocal(),
  );
}
