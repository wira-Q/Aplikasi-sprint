import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF2454D3);
const Color darkBlue = Color(0xFF203F91);
const Color textDark = Color(0xFF17233D);
const Color textGrey = Color(0xFF8290A7);
const Color borderColor = Color(0xFFE7ECF4);


class JobStore {
  static final List<Map<String, dynamic>> jobs = [
    {
      'title': 'Backend development...',
      'location': 'Malang',
      'type': 'Full-time',
      'applicants': 8,
    },
    {
      'title': 'Frontend Developer',
      'location': 'Surabaya',
      'type': 'Kontrak',
      'applicants': 31,
    },
    {
      'title': 'UI UX Development...',
      'location': 'Surabaya',
      'type': 'Kontrak',
      'applicants': 11,
    },
  ];
}
