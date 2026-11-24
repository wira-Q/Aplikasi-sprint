import 'dart:typed_data';

class ImageKind {
  const ImageKind(this.ext, this.mime);
  final String ext;
  final String mime;
}

class ImageSignature {
  ImageSignature._();

  /// Mengenali PNG, JPG, atau WebP dari ISI file (bukan nama).
  /// Null jika bukan ketiganya.
  static ImageKind? detect(Uint8List b) {
    if (_isPng(b)) return const ImageKind('png', 'image/png');
    if (_isJpeg(b)) return const ImageKind('jpg', 'image/jpeg');
    if (_isWebp(b)) return const ImageKind('webp', 'image/webp');
    return null;
  }

  static bool _isPng(Uint8List b) =>
      b.length >= 8 &&
      b[0] == 0x89 &&
      b[1] == 0x50 &&
      b[2] == 0x4E &&
      b[3] == 0x47 &&
      b[4] == 0x0D &&
      b[5] == 0x0A &&
      b[6] == 0x1A &&
      b[7] == 0x0A;

  static bool _isJpeg(Uint8List b) =>
      b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;

  static bool _isWebp(Uint8List b) =>
      b.length >= 12 &&
      b[0] == 0x52 && // R
      b[1] == 0x49 && // I
      b[2] == 0x46 && // F
      b[3] == 0x46 && // F
      b[8] == 0x57 && // W
      b[9] == 0x45 && // E
      b[10] == 0x42 && // B
      b[11] == 0x50; // P
}
