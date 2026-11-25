/// Format tanggal bahasa Indonesia. Terima DateTime lokal (model sudah
/// memanggil toLocal), jadi jam mengikuti zona waktu perangkat.
class DateFormatId {
  DateFormatId._();

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// 22 Januari 2026
  static String date(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// Senin 22 Januari 2026
  static String dayDate(DateTime d) => '${_days[d.weekday - 1]} ${date(d)}';

  /// 09.00
  static String time(DateTime d) => '${_two(d.hour)}.${_two(d.minute)}';

  /// 22 Januari 2026, 09.00
  static String dateTime(DateTime d) => '${date(d)}, ${time(d)}';
}
