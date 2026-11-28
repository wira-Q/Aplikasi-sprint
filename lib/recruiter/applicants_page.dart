import 'package:flutter/material.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/core/utils/paged_controller.dart';
import 'package:sprint/core/widgets/page_bar.dart';
import 'package:sprint/models/application_model.dart';
import 'package:sprint/services/application_service.dart';

import 'detail_pelamar_page.dart';
import 'recruiter_theme.dart';

// Halaman Daftar Pelamar (konten saja), 5 pelamar per halaman.
// Bottom navigation dipegang oleh DasboardPage.
// Jika [idJob] diisi, hanya pelamar lowongan itu yang tampil.
class ApplicantsPage extends StatefulWidget {
  // Dipanggil saat tombol panah kembali ditekan.
  final VoidCallback? onBack;
  final int? idJob;
  final String? jobTitle;

  const ApplicantsPage({super.key, this.onBack, this.idJob, this.jobTitle});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  static const Color blue = primaryBlue;
  static const List<String> _filters = [
    'Semua',
    'Diproses',
    'Interview',
    'Diterima',
    'Ditolak',
  ];
  static const List<Color> _avatarColors = [
    Colors.brown,
    Colors.pink,
    Colors.blueGrey,
    Colors.teal,
    Colors.indigo,
  ];

  final ApplicationService _service = ApplicationService();
  final ScrollController _scroll = ScrollController();
  late final PagedController<ApplicationModel> _pager;

  String selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _pager = PagedController<ApplicationModel>(
      fetch: (page, size) => _service.getApplicantsPage(
        idJob: widget.idJob,
        status: selectedFilter == 'Semua' ? null : selectedFilter,
        page: page,
        pageSize: size,
      ),
      onChanged: () {
        if (mounted) setState(() {});
      },
      errorText: 'Gagal memuat pelamar. Periksa koneksi Anda.',
      onBackgroundError: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
    _pager.load(page: 0);
  }

  @override
  void dispose() {
    _pager.dispose();
    _scroll.dispose();
    super.dispose();
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

  Color _statusColor(String status) {
    switch (status) {
      case ApplicationStatus.diproses:
        return const Color(0xFFCFE0FF);
      case ApplicationStatus.interview:
        return const Color(0xFFFFEFC2);
      case ApplicationStatus.diterima:
        return const Color(0xFFC9F5DB);
      case ApplicationStatus.ditolak:
        return const Color(0xFFFFD0D4);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case ApplicationStatus.diproses:
        return blue;
      case ApplicationStatus.interview:
        return const Color(0xFFB7791F);
      case ApplicationStatus.diterima:
        return const Color(0xFF159653);
      case ApplicationStatus.ditolak:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _filterButton(String title) {
    final isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        if (selectedFilter == title) return;
        setState(() => selectedFilter = title);
        _pager.load(page: 0);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? blue : const Color(0xFFE8ECF3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _avatar(ApplicationModel a, int index) {
    return ClipOval(
      child: Container(
        width: 48,
        height: 48,
        color: _avatarColors[index % _avatarColors.length],
        alignment: Alignment.center,
        child: Text(
          initialsOf(a.applicantName),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Buka Detail Pelamar, lalu muat ulang daftar (status bisa berubah)
  Future<void> _openDetail(ApplicationModel a) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPelamarPage(idApplication: a.idApplication),
      ),
    );
    if (mounted) _pager.load(spinner: false);
  }

  Widget _applicantCard(ApplicationModel a, int index) {
    final applied = a.appliedAt;
    final education = a.applicantEducation?.trim();
    final city = a.applicantLocation?.trim();

    return GestureDetector(
      onTap: () => _openDetail(a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7EAF0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _avatar(a, index),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.applicantName ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.jobTitle ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 12,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          (education == null || education.isEmpty)
                              ? '-'
                              : education,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (city != null && city.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            city,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(a.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      a.status,
                      style: TextStyle(
                        fontSize: 8,
                        color: _statusTextColor(a.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.black87,
                ),
                const SizedBox(height: 14),
                if (applied != null) ...[
                  Text(
                    DateFormatId.date(applied),
                    style: const TextStyle(fontSize: 7, color: Colors.grey),
                  ),
                  Text(
                    DateFormatId.time(applied),
                    style: const TextStyle(fontSize: 7, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    if (_pager.isLoading) {
      return const [
        SizedBox(
          height: 260,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_pager.error != null && _pager.items.isEmpty) {
      return [
        SizedBox(
          height: 260,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _pager.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
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
        SizedBox(
          height: 260,
          child: Center(
            child: Text(
              'Belum ada pelamar',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ),
      ];
    }
    return [
      for (var i = 0; i < _pager.items.length; i++)
        _applicantCard(_pager.items[i], i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: panah kembali + judul
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Pelamar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    if (widget.jobTitle != null)
                      Text(
                        widget.jobTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: textGrey),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              for (var i = 0; i < _filters.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _filterButton(_filters[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _pager.load(spinner: false),
            child: ListView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ..._buildChildren(),
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
      ],
    );
  }
}
