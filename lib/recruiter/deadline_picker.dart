import 'package:flutter/material.dart';
import 'package:sprint/models/job_model.dart';

/// Pemilih tanggal tutup lowongan: dari hari ini (WIB) sampai 365 hari ke
/// depan, sama dengan aturan di database.
Future<DateTime?> pickJobDeadline(
  BuildContext context, {
  DateTime? initial,
  String helpText = 'Tanggal lowongan ditutup',
}) {
  final today = JobModel.todayWib();
  final last = today.add(const Duration(days: JobOptions.maxDeadlineDays));

  var start = initial ?? today.add(const Duration(days: 30));
  if (start.isBefore(today)) start = today.add(const Duration(days: 7));
  if (start.isAfter(last)) start = last;

  return showDatePicker(
    context: context,
    initialDate: start,
    firstDate: today,
    lastDate: last,
    helpText: helpText,
  );
}
