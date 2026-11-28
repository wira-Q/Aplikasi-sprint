import 'package:flutter/material.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/core/utils/job_display.dart';
import 'package:sprint/core/widgets/company_logo.dart';
import 'package:sprint/models/company_model.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/services/company_service.dart';
import 'package:sprint/services/job_service.dart';

import 'applicants_page.dart';
import 'deadline_picker.dart';

// Halaman Detail Lowongan milik recruiter.
// "Lihat Pelamar" -> pelamar lowongan ini saja.
// "Tutup/Buka" -> tutup atau buka kembali. "Ubah Tanggal Tutup" -> perpanjang.
class DetailLowonganPage extends StatefulWidget {
  final JobModel job;

  const DetailLowonganPage({super.key, required this.job});

  @override
  State<DetailLowonganPage> createState() => _DetailLowonganPageState();
}

class _DetailLowonganPageState extends State<DetailLowonganPage> {
  static const Color _blue = Color(0xFF2863E9);
  static const Color _dark = Color(0xFF17233D);
  static const Color _grey = Color(0xFF6B7280);

  final CompanyService _companies = CompanyService();
  final JobService _jobService = JobService();

  int selectedTab = 0;
  static const List<String> _tabs = ['Deskripsi', 'Kualifikasi', 'Perusahaan'];

  late JobModel _job;
  CompanyModel? _company;
  String? _companyError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    setState(() => _companyError = null);
    try {
      final company = await _companies.getMyCompany();
      if (!mounted) return;
      setState(() => _company = company);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _companyError = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _companyError = 'Gagal memuat data perusahaan.');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _applyUpdated(JobModel updated) {
    setState(() {
      _job = updated.withApplicantCount(_job.applicantCount);
      _busy = false;
    });
  }

  // ---------- navigasi dan aksi ----------
  void _openApplicants() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: ApplicantsPage(
              idJob: _job.idJob,
              jobTitle: _job.title,
              onBack: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirm(String title, String message, String ok, bool danger) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              ok,
              style: TextStyle(color: danger ? Colors.red : _blue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatus() async {
    if (_busy) return;
    final job = _job;
    try {
      if (job.isOpen) {
        final ok = await _confirm(
          'Tutup lowongan?',
          'Lowongan tidak akan tampil lagi bagi pencari kerja. Data pelamar '
              'tetap tersimpan.',
          'Tutup',
          true,
        );
        if (ok != true || !mounted) return;
        setState(() => _busy = true);
        _applyUpdated(await _jobService.closeJob(job.idJob));
        _snack('Lowongan ditutup.');
        return;
      }

      DateTime? newDeadline;
      if (job.isExpired) {
        final ok = await _confirm(
          'Buka kembali lowongan?',
          'Tanggal tutup lowongan ini sudah lewat. Pilih tanggal tutup yang '
              'baru untuk membukanya kembali.',
          'Pilih tanggal',
          false,
        );
        if (ok != true || !mounted) return;
        newDeadline = await pickJobDeadline(
          context,
          helpText: 'Tanggal tutup baru',
        );
        if (newDeadline == null || !mounted) return;
      } else {
        final ok = await _confirm(
          'Buka kembali lowongan?',
          'Lowongan akan tampil lagi bagi pencari kerja.',
          'Buka',
          false,
        );
        if (ok != true || !mounted) return;
      }
      setState(() => _busy = true);
      _applyUpdated(
        await _jobService.reopenJob(job.idJob, newDeadline: newDeadline),
      );
      _snack('Lowongan dibuka kembali.');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Gagal mengubah status lowongan.');
    }
  }

  Future<void> _changeDeadline() async {
    if (_busy) return;
    final picked = await pickJobDeadline(context, initial: _job.deadline);
    if (picked == null || !mounted) return;
    setState(() => _busy = true);
    try {
      _applyUpdated(await _jobService.updateJob(_job.idJob, deadline: picked));
      _snack('Tanggal tutup diperbarui: ${DateFormatId.date(picked)}.');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Gagal menyimpan tanggal tutup.');
    }
  }

  // ---------- widget ----------
  Widget _infoItem(IconData icon, String text, {Color color = _grey}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 9, color: color)),
      ],
    );
  }

  Widget _statusBadge() {
    final job = _job;
    Color bg;
    Color fg;
    String label;
    if (job.isOpen) {
      bg = const Color(0xFFD5F7E3);
      fg = const Color(0xFF4CCB84);
      label = 'AKTIF';
    } else if (job.isClosedManually) {
      bg = const Color(0xFFFFD0D4);
      fg = Colors.red;
      label = 'DITUTUP';
    } else {
      bg = const Color(0xFFFFEFC2);
      fg = const Color(0xFFB7791F);
      label = 'BERAKHIR';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 8, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _headerCard() {
    final job = _job;
    final salary = JobDisplay.salary(job.salary);
    final workSystem = job.workSystem?.trim();
    final deadline = job.deadline;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB9BFCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CompanyLogo(path: job.companyLogo, size: 40, radius: 8),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      job.companyName ?? '-',
                      style: const TextStyle(
                        color: _dark,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _infoItem(Icons.location_on_outlined, job.location),
              _infoItem(Icons.schedule_rounded, JobTypeLabels.of(job.jobType)),
              if (workSystem != null && workSystem.isNotEmpty)
                _infoItem(Icons.home_work_outlined, workSystem),
            ],
          ),
          const SizedBox(height: 6),
          _infoItem(
            Icons.monetization_on_rounded,
            salary.isEmpty ? 'Gaji tidak dicantumkan' : salary,
          ),
          const SizedBox(height: 6),
          _infoItem(Icons.people_alt_outlined, '${job.applicantCount} Pelamar'),
          const SizedBox(height: 6),
          _infoItem(
            Icons.event_outlined,
            deadline == null
                ? 'Tanpa tanggal tutup'
                : (job.isExpired
                      ? 'Berakhir ${DateFormatId.date(deadline)}'
                      : 'Ditutup ${DateFormatId.date(deadline)}'),
            color: job.isExpired ? Colors.red : _grey,
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? _blue : Colors.transparent,
                      width: 1.6,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: active ? _blue : _dark,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _dark,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Deskripsi Pekerjaan'),
        Text(
          _job.description,
          style: const TextStyle(color: _dark, fontSize: 11, height: 1.5),
        ),
      ],
    );
  }

  Widget _qualificationSection() {
    final education = _job.education?.trim();
    final items = <String>[
      if (education != null && education.isNotEmpty)
        'Pendidikan minimal $education',
      ...JobDisplay.skillList(_job.skills),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Kualifikasi'),
        if (items.isEmpty)
          const Text(
            'Belum ada kualifikasi yang dicantumkan.',
            style: TextStyle(color: _grey, fontSize: 11),
          )
        else
          ...items.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(fontSize: 11, color: _grey),
                  ),
                  Expanded(
                    child: Text(
                      q,
                      style: const TextStyle(
                        color: _grey,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _companySection() {
    Widget row(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 15, color: _blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: _dark, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }

    String valueOf(String? v) =>
        (v == null || v.trim().isEmpty) ? '-' : v.trim();

    if (_companyError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _companyError!,
            style: const TextStyle(color: _grey, fontSize: 11),
          ),
          TextButton(onPressed: _loadCompany, child: const Text('Coba lagi')),
        ],
      );
    }
    final c = _company;
    if (c == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Tentang Perusahaan'),
        row(Icons.business, c.companyName),
        row(Icons.category_outlined, valueOf(c.industry)),
        row(Icons.location_on_outlined, valueOf(c.location)),
        row(Icons.mail_outline_rounded, valueOf(c.email)),
        row(Icons.language_rounded, valueOf(c.website)),
      ],
    );
  }

  Widget _tabContent() {
    switch (selectedTab) {
      case 1:
        return _qualificationSection();
      case 2:
        return _companySection();
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _descriptionSection(),
            const SizedBox(height: 24),
            _qualificationSection(),
          ],
        );
    }
  }

  Widget _spinner() => const SizedBox(
    width: 16,
    height: 16,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    final job = _job;
    // Lowongan yang berakhir otomatis dibuka lewat "ubah tanggal tutup".
    final showToggle = job.isOpen || job.isClosedManually;

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
          'Detail Lowongan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerCard(),
                    const SizedBox(height: 16),
                    _tabBar(),
                    const SizedBox(height: 18),
                    _tabContent(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 6, 40, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      onPressed: _openApplicants,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Lihat Pelamar [${job.applicantCount}]',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      onPressed: _busy ? null : _changeDeadline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        job.isExpired
                            ? 'Perpanjang (Ubah Tanggal Tutup)'
                            : 'Ubah Tanggal Tutup',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (showToggle) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _toggleStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: job.isOpen ? _blue : Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _busy
                            ? _spinner()
                            : Text(
                                job.isOpen ? 'Tutup Lowongan' : 'Buka Kembali',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
