import 'package:flutter/material.dart';
import 'package:sprint/models/application_model.dart';

/// Warna dan label status lamaran untuk tampilan.
class ApplicationStatusStyle {
  ApplicationStatusStyle._();

  /// Nilai database Diterima tampil sebagai "Disetujui" (sesuai desain).
  static String label(String status) =>
      status == ApplicationStatus.diterima ? 'Disetujui' : status;

  static Color color(String status) {
    switch (status) {
      case ApplicationStatus.interview:
        return Colors.amber;
      case ApplicationStatus.diterima:
        return Colors.green;
      case ApplicationStatus.ditolak:
        return Colors.red;
      default:
        return const Color(0xFF2862E8);
    }
  }
}
