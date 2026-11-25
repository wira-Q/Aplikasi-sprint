import 'package:flutter/material.dart';
import 'package:sprint/models/application_model.dart';
import 'detailDiSetujui.dart';
import 'detailDiTolak.dart';
import 'detailDiproses.dart';
import 'detailInterview.dart';

/// Halaman detail yang sesuai status lamaran. Dipakai daftar status lamaran
/// dan notifikasi, supaya aturannya hanya ada di satu tempat.
Widget lamaranDetailPage(ApplicationModel a) {
  switch (a.status) {
    case ApplicationStatus.interview:
      return DetailInterview(idApplication: a.idApplication);
    case ApplicationStatus.diterima:
      return DetailDisetujui(idApplication: a.idApplication);
    case ApplicationStatus.ditolak:
      return DetailDiTolak(idApplication: a.idApplication);
    default:
      return DetailDiproses(idApplication: a.idApplication);
  }
}
