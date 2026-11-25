import 'package:flutter/material.dart';
import 'package:sprint/services/logo_service.dart';

/// Logo perusahaan dari bucket logos (public). Jika belum ada atau gagal
/// dimuat, tampil ikon gedung.
class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
    required this.path,
    this.size = 40,
    this.radius = 10,
  });

  final String? path;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = LogoService.publicUrl(path);
    final fallback = Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: Icon(Icons.business, size: size * 0.5, color: Colors.grey),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }
}
