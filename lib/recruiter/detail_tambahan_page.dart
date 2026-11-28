import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/services/company_service.dart';
import 'package:sprint/services/job_service.dart';

import 'dasboard_page.dart';
import 'deadline_picker.dart';
import 'job_draft.dart';
import 'lowongan_saya_page.dart';

// Buat Lowongan - tahap 2 (Jenis Pekerjaan, Sistem Kerja, Gaji, Tanggal tutup)
// + popup "Lowongan Berhasil di Publikasikan!"
class DetailTambahanPage extends StatefulWidget {
  /// Isian dari halaman Buat Lowongan tahap 1.
  final JobDraft draft;

  const DetailTambahanPage({super.key, required this.draft});

  @override
  State<DetailTambahanPage> createState() => _DetailTambahanPageState();
}

class _DetailTambahanPageState extends State<DetailTambahanPage> {
  static const Color _blue = Color(0xFF2863E9);
  static const Color _dark = Color(0xFF17233D);
  static const int _maxSalary = 999999999;

  final JobService _jobService = JobService();
  final CompanyService _companies = CompanyService();

  String? jobType;
  String? workSystem;
  DateTime? _deadline;
  String _companyName = '-';

  bool _isSaving = false;
  String? _errorMessage;

  final TextEditingController salaryC = TextEditingController();
  final TextEditingController deadlineC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  @override
  void dispose() {
    salaryC.dispose();
    deadlineC.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyName() async {
    try {
      final company = await _companies.getMyCompany();
      if (!mounted || company == null) return;
      setState(() => _companyName = company.companyName);
    } catch (_) {
      // Nama perusahaan di pratinjau boleh kosong.
    }
  }

  int? get _salaryValue => int.tryParse(salaryC.text.trim());

  // 5000000 -> "5jt"
  String _salaryShort() {
    final n = _salaryValue;
    if (n == null || n <= 0) return '-';
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}jt';
    }
    return '$n';
  }

  Future<void> _pickDeadline() async {
    if (_isSaving) return;
    final picked = await pickJobDeadline(context, initial: _deadline);
    if (picked != null && mounted) {
      setState(() {
        _deadline = picked;
        deadlineC.text = DateFormatId.date(picked);
        _errorMessage = null;
      });
    }
  }

  Future<void> _publish() async {
    if (_isSaving) return;
    if (jobType == null || workSystem == null) {
      setState(() => _errorMessage = 'Pilih jenis pekerjaan dan sistem kerja.');
      return;
    }
    if (_deadline == null) {
      setState(() => _errorMessage = 'Pilih tanggal lowongan ditutup.');
      return;
    }
    final salary = _salaryValue;
    if (salaryC.text.trim().isNotEmpty && (salary == null || salary < 0)) {
      setState(() => _errorMessage = 'Gaji tidak valid.');
      return;
    }
    if (salary != null && salary > _maxSalary) {
      setState(() => _errorMessage = 'Gaji terlalu besar.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final d = widget.draft;
      await _jobService.createJob(
        title: d.title,
        description: d.fullDescription,
        location: d.location,
        jobType: jobType!,
        workSystem: workSystem,
        skills: d.skillsText,
        education: d.education,
        salary: (salary != null && salary > 0) ? salary : null,
        deadline: _deadline,
      );
      if (!mounted) return;
      setState(() => _isSaving = false);
      // Langsung tampilkan popup "Lowongan Berhasil di Publikasikan!"
      _showSuccess();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Periksa koneksi Anda.';
        _isSaving = false;
      });
    }
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
                Text(
                  'Lowongan kamu sekarang sudah dapat dilihat oleh job '
                  'seeker sampai ${DateFormatId.date(_deadline!)}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _dark,
                    fontSize: 9,
                    height: 1.4,
                  ),
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

  Widget _label(String text, {bool required = true}) {
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
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : null,
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
    String Function(String)? labelOf,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
      decoration: _decoration(hint, icon),
      style: const TextStyle(fontSize: 11, color: _dark),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(labelOf == null ? e : labelOf(e)),
            ),
          )
          .toList(),
      onChanged: _isSaving ? null : onChanged,
    );
  }

  Widget _previewCard() {
    final type = jobType == null ? '-' : JobTypeLabels.of(jobType!);
    final deadline = _deadline;

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
                      widget.draft.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _companyName,
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
                  widget.draft.location,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _blue, fontSize: 10),
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.schedule_rounded, size: 13, color: _blue),
              const SizedBox(width: 3),
              Text(type, style: const TextStyle(color: _blue, fontSize: 10)),
              const SizedBox(width: 14),
              const Icon(Icons.monetization_on_rounded, size: 13, color: _blue),
              const SizedBox(width: 3),
              Text(
                _salaryShort(),
                style: const TextStyle(color: _blue, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 13, color: _blue),
              const SizedBox(width: 3),
              Text(
                deadline == null
                    ? 'Tanggal tutup belum dipilih'
                    : 'Ditutup ${DateFormatId.date(deadline)}',
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
          onPressed: _isSaving ? null : () => Navigator.pop(context),
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
              hint: 'Pilih jenis pekerjaan',
              icon: Icons.work_outline_rounded,
              items: JobOptions.jobTypes,
              value: jobType,
              labelOf: JobTypeLabels.of,
              onChanged: (v) => setState(() {
                jobType = v;
                _errorMessage = null;
              }),
            ),
            const SizedBox(height: 16),
            _label('Sistem Kerja'),
            _dropdown(
              hint: 'Pilih sistem kerja',
              icon: Icons.schedule_rounded,
              items: JobOptions.workSystems,
              value: workSystem,
              onChanged: (v) => setState(() {
                workSystem = v;
                _errorMessage = null;
              }),
            ),
            const SizedBox(height: 16),
            _label('Gaji per bulan (opsional)', required: false),
            TextField(
              controller: salaryC,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              onChanged: (_) => setState(() => _errorMessage = null),
              style: const TextStyle(fontSize: 11, color: _dark),
              decoration: _decoration(
                'Contoh: 5000000 (angka saja, tanpa titik)',
                Icons.monetization_on_rounded,
              ),
            ),
            const SizedBox(height: 16),
            _label('Tanggal Lowongan Ditutup'),
            TextField(
              controller: deadlineC,
              readOnly: true,
              onTap: _pickDeadline,
              style: const TextStyle(fontSize: 11, color: _dark),
              decoration: _decoration(
                'Pilih tanggal (maksimal 365 hari ke depan)',
                Icons.calendar_today_outlined,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 2),
              child: Text(
                'Setelah tanggal ini, lowongan otomatis nonaktif dan tidak '
                'bisa dilamar lagi.',
                style: TextStyle(fontSize: 9, color: Color(0xFF8290A7)),
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
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 11, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _publish,
        backgroundColor: _blue,
        elevation: 4,
        label: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
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
