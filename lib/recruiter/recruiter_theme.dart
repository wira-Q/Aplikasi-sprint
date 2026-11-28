import 'package:flutter/material.dart';

// Warna bersama halaman recruiter (menggantikan job_store.dart).
const Color primaryBlue = Color(0xFF2454D3);
const Color darkBlue = Color(0xFF203F91);
const Color textDark = Color(0xFF17233D);
const Color textGrey = Color(0xFF8290A7);
const Color borderColor = Color(0xFFE7ECF4);

/// Inisial untuk avatar: huruf pertama dari dua kata pertama.
String initialsOf(String? name) {
  final parts = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  final first = parts.first.substring(0, 1);
  final second = parts.length > 1 ? parts[1].substring(0, 1) : '';
  return (first + second).toUpperCase();
}
