import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/core/utils/paged_controller.dart';
import 'package:sprint/core/widgets/page_bar.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/services/job_service.dart';

import 'buat_lowongan_page.dart';
import 'dasboard_page.dart';
import 'deadline_picker.dart';
import 'detail_lowongan_page.dart';
import 'recruiter_theme.dart';

class LowonganSayaPage extends StatefulWidget {
  const LowonganSayaPage({super.key});

  @override
  State<LowonganSayaPage> createState() => _LowonganSayaPageState();
}

class _LowonganSayaPageState extends State<LowonganSayaPage> {
  final JobService _jobService = JobService();
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late final PagedController<JobModel> _pager;
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _pager = PagedController<JobModel>(
      fetch: (page, size) => _jobService.getMyJobsPage(
        query: _query.isEmpty ? null : _query,
        page: page,
        pageSize: size,
      ),
      onChanged: () {
        if (mounted) setState(() {});
      },
      errorText: 'Gagal memuat lowongan. Periksa koneksi Anda.',
      onBackgroundError: _snack,
    );
    _pager.load(page: 0);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pager.dispose();
    searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();
      if (query == _query) return;
      _query = query;
      _pager.load(page: 0);
    });
  }

  Future<void> _goToPage(int page) async {
    await _pager.goTo(page);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _replaceJob(JobModel updated) {
    setState(() {
      _pager.items = [
        for (final j in _pager.items)
          j.idJob == updated.idJob
              // Jumlah pelamar tidak ikut dikembalikan saat ubah data.
              ? updated.withApplicantCount(j.applicantCount)
              : j,
      ];
    });
  }

  Future<void> _addJob() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BuatLowonganPage()),
    );
    if (mounted) _pager.load(page: 0, spinner: false);
  }

  Future<bool?> _confirm(
    String title,
    String message,
    String okLabel, {
    bool danger = false,
  }) {
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
              okLabel,
              style: TextStyle(color: danger ? Colors.red : primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _editJob(JobModel job) {
    final controller = TextEditingController(text: job.title);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Lowongan'),
          content: TextField(
            controller: controller,
            maxLength: 150,
            decoration: const InputDecoration(labelText: 'Nama Lowongan'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final title = controller.text.trim();
                if (title.isEmpty) return;
                Navigator.pop(dialogContext);
                try {
                  final updated = await _jobService.updateJob(
                    job.idJob,
                    title: title,
                  );
                  if (mounted) _replaceJob(updated);
                } on AppException catch (e) {
                  _snack(e.message);
                } catch (_) {
                  _snack('Gagal menyimpan lowongan.');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  /// Mengubah tanggal tutup. Pada lowongan yang sudah berakhir, ini
  /// memperpanjangnya sehingga aktif lagi.
  Future<void> _changeDeadline(JobModel job) async {
    final picked = await pickJobDeadline(
      context,
      initial: job.deadline,
      helpText: 'Tanggal lowongan ditutup',
    );
    if (picked == null || !mounted) return;
    try {
      final updated = await _jobService.updateJob(job.idJob, deadline: picked);
      if (!mounted) return;
      _replaceJob(updated);
      _snack('Tanggal tutup diperbarui: ${DateFormatId.date(picked)}.');
    } on AppException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Gagal menyimpan tanggal tutup.');
    }
  }

  Future<void> _toggleStatus(JobModel job) async {
    try {
      if (job.isOpen) {
        final ok = await _confirm(
          'Tutup Lowongan?',
          'Lowongan ini tidak akan tampil lagi bagi pencari kerja. Data '
              'pelamar tetap tersimpan.',
          'Tutup',
          danger: true,
        );
        if (ok != true || !mounted) return;
        final updated = await _jobService.closeJob(job.idJob);
        if (mounted) _replaceJob(updated);
        return;
      }

      // Dibuka kembali. Jika tanggal tutupnya sudah lewat, wajib memilih
      // tanggal tutup yang baru.
      DateTime? newDeadline;
      if (job.isExpired) {
        final ok = await _confirm(
          'Buka Kembali?',
          'Tanggal tutup lowongan ini sudah lewat. Pilih tanggal tutup yang '
              'baru untuk membukanya kembali.',
          'Pilih tanggal',
        );
        if (ok != true || !mounted) return;
        newDeadline = await pickJobDeadline(
          context,
          helpText: 'Tanggal tutup baru',
        );
        if (newDeadline == null || !mounted) return;
      } else {
        final ok = await _confirm(
          'Buka Kembali?',
          'Lowongan ini akan tampil lagi bagi pencari kerja.',
          'Buka',
        );
        if (ok != true || !mounted) return;
      }
      final updated = await _jobService.reopenJob(
        job.idJob,
        newDeadline: newDeadline,
      );
      if (mounted) _replaceJob(updated);
    } on AppException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Gagal mengubah status lowongan.');
    }
  }

  Future<void> _openDetail(JobModel job) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailLowonganPage(job: job)),
    );
    if (mounted) _pager.load(spinner: false);
  }

  // Buka Dashboard langsung di tab tertentu (1 = Applicants, 2 = Profile)
  void _openDashboardTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => DashboardPage(initialIndex: index)),
      (route) => false,
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
          'Lowongan saya',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _pager.load(spinner: false),
              child: ListView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
                children: [
                  // PENCARIAN
                  Container(
                    height: 42,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Cari Lowongan',
                        hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: primaryBlue,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Lowongan',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ..._buildList(),

                  PageBar(
                    page: _pager.page,
                    totalPages: _pager.totalPages,
                    enabled: !_pager.isLoading,
                    onPageSelected: _goToPage,
                  ),
                ],
              ),
            ),
          ),

          // TOMBOL BUAT LOWONGAN
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 7),
            child: SizedBox(
              width: double.infinity,
              height: 43,
              child: ElevatedButton.icon(
                onPressed: _addJob,
                icon: const Icon(Icons.add, color: Colors.white, size: 17),
                label: const Text(
                  'Buat Lowongan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  List<Widget> _buildList() {
    if (_pager.isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.all(30),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_pager.error != null && _pager.items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
            child: Column(
              children: [
                Text(
                  _pager.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textGrey, fontSize: 11),
                ),
                TextButton(
                  onPressed: () => _pager.load(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    if (_pager.items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(25),
          child: Center(
            child: Text(
              'Lowongan tidak ditemukan',
              style: TextStyle(color: textGrey, fontSize: 11),
            ),
          ),
        ),
      ];
    }
    return _pager.items.map(_jobCard).toList();
  }

  Color _statusColor(JobModel job) =>
      job.isClosedManually ? Colors.red : const Color(0xFFB7791F);

  Widget _jobCard(JobModel job) {
    final deadline = job.deadline;
    return GestureDetector(
      onTap: () => _openDetail(job),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!job.isOpen) ...[
                        const SizedBox(width: 6),
                        Text(
                          job.statusLabel,
                          style: TextStyle(
                            fontSize: 8,
                            color: _statusColor(job),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  height: 25,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            'Manage',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.tune_rounded, color: primaryBlue, size: 15),
                        SizedBox(width: 5),
                      ],
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editJob(job);
                      } else if (value == 'deadline') {
                        _changeDeadline(job);
                      } else if (value == 'toggle') {
                        _toggleStatus(job);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'Edit',
                          style: TextStyle(color: primaryBlue, fontSize: 11),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'deadline',
                        child: Text(
                          job.isExpired
                              ? 'Perpanjang (ubah tanggal tutup)'
                              : 'Ubah tanggal tutup',
                          style: const TextStyle(
                            color: primaryBlue,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (job.isOpen || job.isClosedManually)
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            job.isOpen ? 'Tutup lowongan' : 'Buka kembali',
                            style: TextStyle(
                              color: job.isOpen ? Colors.red : primaryBlue,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 11,
                  color: textGrey,
                ),
                const SizedBox(width: 3),
                Text(
                  job.location,
                  style: const TextStyle(color: textGrey, fontSize: 9),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: textGrey, fontSize: 9)),
                const SizedBox(width: 8),
                Text(
                  JobTypeLabels.of(job.jobType),
                  style: const TextStyle(color: textGrey, fontSize: 9),
                ),
                const Spacer(),
                const Icon(
                  Icons.people_alt_rounded,
                  color: primaryBlue,
                  size: 12,
                ),
                const SizedBox(width: 3),
                Text(
                  '${job.applicantCount}',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (deadline != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 11,
                    color: job.isExpired ? Colors.red : textGrey,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    job.isExpired
                        ? 'Berakhir ${DateFormatId.date(deadline)}'
                        : 'Tutup ${DateFormatId.date(deadline)}',
                    style: TextStyle(
                      color: job.isExpired ? Colors.red : textGrey,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 57,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F2F6))),
      ),
      child: Row(
        children: [
          _navItem(Icons.home_outlined, 'Home', () => Navigator.pop(context)),
          _navItem(
            Icons.people_outline_rounded,
            'Applicants',
            () => _openDashboardTab(1),
          ),
          _navItem(
            Icons.person_outline_rounded,
            'Profile',
            () => _openDashboardTab(2),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: primaryBlue),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 8, color: textGrey)),
          ],
        ),
      ),
    );
  }
}
