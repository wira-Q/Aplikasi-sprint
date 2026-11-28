import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/widgets/company_logo.dart';
import 'package:sprint/core/widgets/notification_sheet.dart';
import 'package:sprint/models/application_model.dart';
import 'package:sprint/models/company_model.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/services/application_service.dart';
import 'package:sprint/services/company_service.dart';
import 'package:sprint/services/job_service.dart';
import 'package:sprint/services/notification_service.dart';

import 'applicants_page.dart';
import 'detail_pelamar_page.dart';
import 'lowongan_saya_page.dart';
import 'profile_page.dart';
import 'recruiter_theme.dart';

class DashboardPage extends StatefulWidget {
  // 0 = Home, 1 = Applicants, 2 = Profile
  final int initialIndex;

  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Ringkasan dihitung dari sampai sebanyak ini lowongan.
  static const int _summaryLimit = 50;

  final CompanyService _companies = CompanyService();
  final JobService _jobService = JobService();
  final ApplicationService _applications = ApplicationService();
  final NotificationService _notifications = NotificationService();

  late int selectedIndex;

  CompanyModel? _company;
  List<JobModel> _jobs = [];
  List<ApplicationModel> _recent = [];
  bool _isLoading = true;
  String? _errorMessage;

  Timer? _unreadTimer;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _load();
    _loadUnread();
    _unreadTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _loadUnread(),
    );
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final company = await _companies.getMyCompany();
      if (company == null) {
        throw const AppException('Profil perusahaan belum dibuat.');
      }
      final jobs = await _jobService.getMyJobs(pageSize: _summaryLimit);
      final recent = await _applications.getApplicants(page: 0, pageSize: 3);
      if (!mounted) return;
      setState(() {
        _company = company;
        _jobs = jobs;
        _recent = recent;
        _errorMessage = null;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat dashboard. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnread() async {
    try {
      final count = await _notifications.getUnreadCount();
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (_) {
      // Lencana tidak diperbarui bila gagal; tidak mengganggu dashboard.
    }
  }

  Future<void> _openNotifications() async {
    await showNotificationSheet(context, onOpenApplication: _openApplicant);
    if (mounted) _loadUnread();
  }

  /// Dipanggil popup notifikasi (setelah popup tertutup) dan baris
  /// "Pelamar Terbaru".
  Future<void> _openApplicant(int idApplication) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPelamarPage(idApplication: idApplication),
      ),
    );
    if (mounted) {
      _load(showSpinner: false);
      _loadUnread();
    }
  }

  List<JobModel> get _openJobs => _jobs.where((j) => j.isOpen).toList();

  int get _totalApplicants =>
      _jobs.fold<int>(0, (sum, j) => sum + j.applicantCount);

  /// Jika lowongan melebihi batas ringkasan, angka dianggap sebagian.
  bool get _capped => _jobs.length >= _summaryLimit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: selectedIndex == 2
          ? ProfilePage(onBack: () => setState(() => selectedIndex = 0))
          : SafeArea(
              child: selectedIndex == 0
                  ? _dashboardContent()
                  : ApplicantsPage(
                      onBack: () => setState(() => selectedIndex = 0),
                    ),
            ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _dashboardContent() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _load(showSpinner: false);
              await _loadUnread();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 30),
                  ..._bodySections(),
                ],
              ),
            ),
          ),
        ),
        _createJobButton(),
      ],
    );
  }

  List<Widget> _bodySections() {
    if (_isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_errorMessage != null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textGrey, fontSize: 11),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: _load, child: const Text('Coba lagi')),
              ],
            ),
          ),
        ),
      ];
    }

    final activeJobs = _openJobs.take(2).toList();
    return [
      _sectionTitle('Ringkasan', 'Semua waktu', null),
      const SizedBox(height: 12),
      _summaryCards(),
      const SizedBox(height: 23),
      _sectionTitle('Lowongan Aktif', 'Lihat semua', _openLowongan),
      const SizedBox(height: 12),
      if (activeJobs.isEmpty)
        _emptyText('Belum ada lowongan aktif')
      else
        for (var i = 0; i < activeJobs.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _dashboardJobCard(activeJobs[i]),
        ],
      const SizedBox(height: 22),
      _sectionTitle(
        'Pelamar Terbaru',
        'Lihat semua',
        () => setState(() => selectedIndex = 1),
      ),
      const SizedBox(height: 12),
      _applicantCard(),
    ];
  }

  Widget _emptyText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: textGrey, fontSize: 10),
        ),
      ),
    );
  }

  // Dashboard menuju halaman Lowongan Saya
  Future<void> _openLowongan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LowonganSayaPage()),
    );
    // Muat ulang diam-diam: lowongan mungkin berubah di halaman itu.
    if (mounted) _load(showSpinner: false);
  }

  Widget _header() {
    final company = _company;
    final hasLogo = company?.logo != null && company!.logo!.isNotEmpty;
    final industry = company?.industry?.trim();

    return Row(
      children: [
        if (hasLogo)
          CompanyLogo(path: company.logo, size: 53, radius: 13)
        else
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.business_center_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (industry == null || industry.isEmpty) ? 'Recruiter' : industry,
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _company == null ? 'Halo!' : 'Halo, ${_company!.companyName}!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Siap temukan talenta terbaik?',
                style: TextStyle(color: textGrey, fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildBell(),
      ],
    );
  }

  // Lonceng dengan lencana jumlah belum dibaca, sama seperti job seeker.
  Widget _buildBell() {
    final label = _unreadCount > 99 ? '99+' : '$_unreadCount';
    return GestureDetector(
      onTap: _openNotifications,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: textDark,
              size: 23,
            ),
          ),
          if (_unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String action, VoidCallback? onTap) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                action,
                style: TextStyle(
                  color: onTap == null ? textGrey : primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: primaryBlue,
                  size: 17,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCards() {
    final suffix = _capped ? '+' : '';
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 108,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Active Jobs',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    _summaryIcon(
                      Icons.business_center_outlined,
                      Colors.white,
                      const Color(0xFF3858A2),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_openJobs.length}$suffix',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'lowongan dibuka',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 108,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFE),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Applicants',
                        style: TextStyle(color: textGrey, fontSize: 10),
                      ),
                    ),
                    _summaryIcon(
                      Icons.people_alt_outlined,
                      primaryBlue,
                      const Color(0xFFEAF1FF),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_totalApplicants$suffix',
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'semua lowongan',
                        style: TextStyle(color: textGrey, fontSize: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryIcon(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: iconColor, size: 17),
    );
  }

  Widget _dashboardJobCard(JobModel job) {
    return GestureDetector(
      onTap: _openLowongan,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Manage',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: textGrey,
                  size: 12,
                ),
                const SizedBox(width: 3),
                Text(
                  job.location,
                  style: const TextStyle(color: textGrey, fontSize: 9),
                ),
                const SizedBox(width: 8),
                const Text(
                  '•',
                  style: TextStyle(color: textGrey, fontSize: 10),
                ),
                const SizedBox(width: 8),
                Text(
                  JobTypeLabels.of(job.jobType),
                  style: const TextStyle(color: textGrey, fontSize: 9),
                ),
                const Spacer(),
                const Icon(
                  Icons.people_alt_rounded,
                  color: primaryBlue,
                  size: 13,
                ),
                const SizedBox(width: 3),
                Text(
                  '${job.applicantCount}',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const List<Color> _avatarColors = [
    Color(0xFFDDEBFF),
    Color(0xFFFFF1C9),
    Color(0xFFD9F9E7),
  ];

  Widget _applicantCard() {
    if (_recent.isEmpty) return _emptyText('Belum ada pelamar');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _recent.length; i++)
            _applicantRow(_recent[i], _avatarColors[i % _avatarColors.length]),
        ],
      ),
    );
  }

  String _statusBadge(String status) =>
      status == ApplicationStatus.diproses ? 'Baru' : status;

  Widget _applicantRow(ApplicationModel a, Color avatarColor) {
    return InkWell(
      onTap: () => _openApplicant(a.idApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: avatarColor,
              child: Text(
                initialsOf(a.applicantName),
                style: const TextStyle(
                  color: darkBlue,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
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
                      color: textDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    a.jobTitle ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: textGrey, fontSize: 9),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusBadge(a.status),
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tombol Dashboard membuka Lowongan Saya terlebih dahulu
  Widget _createJobButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 7),
      child: SizedBox(
        width: double.infinity,
        height: 43,
        child: ElevatedButton.icon(
          onPressed: _openLowongan,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
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
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F2F6))),
      ),
      child: Row(
        children: [
          _navItem(Icons.home_outlined, 'Home', 0),
          _navItem(Icons.people_outline_rounded, 'Applicants', 1),
          _navItem(Icons.person_outline_rounded, 'Profile', 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? primaryBlue : const Color(0xFFAAB3C2),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: active ? primaryBlue : textGrey,
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
