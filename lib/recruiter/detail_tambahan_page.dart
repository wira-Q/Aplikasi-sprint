import 'package:flutter/material.dart';

import 'job_store.dart';
import 'dasboard_page.dart';
import 'lowongan_saya_page.dart';

// Buat Lowongan - tahap 2 (Jenis Pekerjaan, Sistem Kerja, Gaji, Deadline)
// + popup "Lowongan Berhasil di Publikasikan!"
class DetailTambahanPage extends StatefulWidget {
  // Data dari halaman Buat Lowongan tahap 1
  // (title, description, skills, education, experience, location, applicants)
  final Map<String, dynamic> jobData;
  final String company;

  const DetailTambahanPage({
    super.key,
    required this.jobData,
    this.company = 'PT XYZ',
  });

  String get title => (jobData['title'] ?? '').toString();
  String get location => (jobData['location'] ?? '').toString();

  @override
  State<DetailTambahanPage> createState() => _DetailTambahanPageState();
}

class _DetailTambahanPageState extends State<DetailTambahanPage> {
  static const Color _blue = Color(0xFF2863E9);
  static const Color _dark = Color(0xFF17233D);

  static const List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Kontrak',
    'Magang',
  ];
  static const List<String> _systems = ['Onsite', 'Hybrid', 'Remote'];
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

  String? jobType;
  String? workSystem;
  DateTime? deadline;

  final TextEditingController salaryC = TextEditingController();
  final TextEditingController deadlineC = TextEditingController();

  @override
  void dispose() {
    salaryC.dispose();
    deadlineC.dispose();
    super.dispose();
  }

  // "Rp 4.000.000 - Rp 6.000.000" -> "4jt - 6jt"
  String _salaryShort() {
    final nums = RegExp(r'\d[\d.]*')
        .allMatches(salaryC.text)
        .map((m) => int.tryParse(m.group(0)!.replaceAll('.', '')) ?? 0)
        .where((n) => n > 0)
        .toList();

    if (nums.isEmpty) return '-';

    String f(int n) {
      if (n >= 1000000) {
        return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}jt';
      }
      return '$n';
    }

    return nums.length == 1 ? f(nums[0]) : '${f(nums[0])} - ${f(nums[1])}';
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: deadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        deadline = picked;
        deadlineC.text =
            '${picked.day} ${_months[picked.month - 1].toLowerCase()} ${picked.year}';
      });
    }
  }

  void _publish() {
    // Simpan lowongan ke JobStore supaya muncul di Lowongan Saya
    JobStore.jobs.insert(0, {
      ...widget.jobData,
      'type': jobType ?? 'Full-time',
      'applicants': '0',
      'system': workSystem ?? 'Hybrid',
      'salary': salaryC.text.trim(),
      'deadline': deadlineC.text,
    });

    // Langsung tampilkan popup "Lowongan Berhasil di Publikasikan!"
    _showSuccess();
  }

  void _showSuccess() {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF22C55E).withOpacity(0.12),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF22C55E),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Lowongan Berhasil\ndi Publikasikan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lowongan kamu sekarang sudah\ndapat dilihat oleh job seeker',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _dark, fontSize: 9, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(),
                        ),
                        (route) => false,
                      );
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => const LowonganSayaPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lihat lowongan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const DashboardPage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blue,
                      side: const BorderSide(color: _blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Dashboard',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- UI ----------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            color: _dark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          children: const [
            TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _dark, width: 1.1),
      );

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
      prefixIcon: Icon(icon, size: 16, color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: _border,
      enabledBorder: _border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _blue, width: 1.4),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
      decoration: _decoration(hint, icon),
      style: const TextStyle(fontSize: 11, color: _dark),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _previewCard() {
    final type = jobType ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFCADBFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3ECFE),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: _blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.company,
                      style: const TextStyle(color: _dark, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: _blue),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  widget.location,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _blue, fontSize: 10),
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.schedule_rounded, size: 13, color: _blue),
              const SizedBox(width: 3),
              Text(
                type,
                style: const TextStyle(color: _blue, fontSize: 10),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.monetization_on_rounded,
                  size: 13, color: _blue),
              const SizedBox(width: 3),
              Text(
                _salaryShort(),
                style: const TextStyle(color: _blue, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 21),
        ),
        title: const Text(
          'Buat Lowongan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Jenis Pekerjaan'),
            _dropdown(
              hint: 'Full-time',
              icon: Icons.work_outline_rounded,
              items: _jobTypes,
              value: jobType,
              onChanged: (v) => setState(() => jobType = v),
            ),
            const SizedBox(height: 16),
            _label('Sistem Kerja'),
            _dropdown(
              hint: 'Hybrid',
              icon: Icons.schedule_rounded,
              items: _systems,
              value: workSystem,
              onChanged: (v) => setState(() => workSystem = v),
            ),
            const SizedBox(height: 16),
            _label('Gaji'),
            TextField(
              controller: salaryC,
              keyboardType: TextInputType.text,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 11, color: _dark),
              decoration: _decoration(
                'Rp 4.000.000- Rp 6.000.000',
                Icons.monetization_on_rounded,
              ),
            ),
            const SizedBox(height: 16),
            _label('Deadline Lamaran'),
            TextField(
              controller: deadlineC,
              readOnly: true,
              onTap: _pickDeadline,
              style: const TextStyle(fontSize: 11, color: _dark),
              decoration: _decoration(
                '30 oktober 2026',
                Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Preview',
              style: TextStyle(
                color: _dark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _previewCard(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _publish,
        backgroundColor: _blue,
        elevation: 4,
        label: const Text(
          'Publikasikan Lowongan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}