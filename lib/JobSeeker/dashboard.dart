import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/job_display.dart';
import 'package:sprint/core/utils/paged_controller.dart';
import 'package:sprint/core/widgets/company_logo.dart';
import 'package:sprint/core/widgets/notification_sheet.dart';
import 'package:sprint/core/widgets/page_bar.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/paged_result.dart';
import 'package:sprint/models/user_model.dart';
import 'package:sprint/services/application_service.dart';
import 'package:sprint/services/job_service.dart';
import 'package:sprint/services/notification_service.dart';
import 'package:sprint/services/user_service.dart';
import 'lamaran_page_resolver.dart';
import 'maps.dart';
import 'detailLowongan.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  /// Jumlah notifikasi belum dibaca dicek ulang setiap interval ini.
  static const Duration _unreadRefresh = Duration(seconds: 60);

  final JobService _jobService = JobService();
  final UserService _users = UserService();
  final NotificationService _notifications = NotificationService();
  final ApplicationService _applications = ApplicationService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late final PagedController<JobModel> _pager;
  Timer? _debounce;
  Timer? _unreadTimer;
  UserModel? _profile;
  int _unreadCount = 0;

  /// Kata kunci yang sedang dipakai (sudah melewati jeda pengetikan).
  String _query = '';

  /// true = daftar rekomendasi (dari preferensi profil). Jika rekomendasi
  /// kosong, otomatis memakai semua lowongan terbaru.
  bool _recommendMode = true;

  @override
  void initState() {
    super.initState();
    _pager = PagedController<JobModel>(
      fetch: _fetch,
      onChanged: () {
        if (mounted) setState(() {});
      },
      errorText: 'Gagal memuat lowongan. Periksa koneksi Anda.',
      onBackgroundError: _showMessage,
    );
    _init();
    _loadUnread();
    _unreadTimer = Timer.periodic(_unreadRefresh, (_) => _loadUnread());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _unreadTimer?.cancel();
    _pager.dispose();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _init() async {
    try {
      final profile = await _users.getCurrentProfile();
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (_) {
      // Nama kosong tidak menghalangi daftar lowongan.
    }
    await _pager.load(page: 0);
  }

  Future<void> _loadUnread() async {
    try {
      final count = await _notifications.getUnreadCount();
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (_) {
      // Lencana tidak diperbarui bila gagal; tidak mengganggu daftar lowongan.
    }
  }

  Future<void> _openNotifications() async {
    await showNotificationSheet(context, onOpenApplication: _openApplication);
    // Perbarui lencana setelah popup ditutup (sebagian mungkin sudah dibaca).
    if (mounted) _loadUnread();
  }

  /// Dipanggil popup notifikasi (setelah popup tertutup).
  Future<void> _openApplication(int idApplication) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final application = await _applications.getMyApplicationById(
        idApplication,
      );
      if (!mounted) return;
      if (application == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Lamaran tidak ditemukan.')),
        );
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => lamaranDetailPage(application)),
      );
      if (mounted) _loadUnread();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka lamaran. Periksa koneksi Anda.'),
        ),
      );
    }
  }

  Future<PagedResult<JobModel>> _fetch(int page, int size) async {
    if (_query.isEmpty) {
      final p = _profile;
      final rec = await _jobService.getRecommendedJobsPage(
        locations: p?.preferredLocations ?? const [],
        jobTypes: p?.preferredJobTypes ?? const [],
        page: page,
        pageSize: size,
      );
      if (rec.total > 0) {
        _recommendMode = true;
        return rec;
      }
      // Tidak ada yang cocok dengan preferensi: tampilkan semua lowongan.
      _recommendMode = false;
      return _jobService.getJobsPage(page: page, pageSize: size);
    }
    _recommendMode = false;
    return _jobService.getJobsPage(query: _query, page: page, pageSize: size);
  }

  void _onSearchChanged(String value) {
    setState(() {}); // memperbarui tombol hapus (X)
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();
      if (query == _query) return;
      _query = query;
      _pager.load(page: 0);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _query = '';
    _pager.load(page: 0);
  }

  /// Tarik ke bawah: muat ulang halaman yang sedang dibuka.
  Future<void> _refresh() async {
    await Future.wait([_pager.load(spinner: false), _loadUnread()]);
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

  String get _sectionTitle {
    if (_query.isNotEmpty) return 'Hasil pencarian';
    return _recommendMode ? 'Rekomendasi untuk mu' : 'Lowongan terbaru';
  }

  // Tombol lonceng notifikasi dengan lencana jumlah belum dibaca.
  Widget _buildBellButton(Color primaryColor) {
    final label = _unreadCount > 99 ? '99+' : '$_unreadCount';
    return GestureDetector(
      onTap: _openNotifications,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 20,
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
                  style: GoogleFonts.poppins(
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

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);
    final name = _profile?.name.trim() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BAGIAN HEADER (SAPAAN & LONCENG NOTIFIKASI)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name.isEmpty ? 'Halo!' : 'Halo, $name',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildBellButton(primaryColor),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. SEARCH BAR (lebih pendek) + TOMBOL LOKASI DI KANANNYA
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Cari lowongan atau keahlian',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF0F4FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapsPage(),
                          ),
                        );
                        // Kota diubah: muat ulang profil dan rekomendasi.
                        if (changed == true && mounted) _init();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. JUDUL DAFTAR
                Text(
                  _sectionTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // 4. KARTU DAFTAR LOWONGAN (5 per halaman)
                _buildContent(),

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
      ),
    );
  }

  Widget _buildContent() {
    if (_pager.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_pager.error != null && _pager.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Text(
                _pager.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _pager.load(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_pager.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Lowongan tidak ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pager.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildJobCard(_pager.items[index]),
    );
  }

  // Widget Helper untuk membuat Card Lowongan Kerja
  Widget _buildJobCard(JobModel job) {
    final salary = JobDisplay.salary(job.salary);
    final company = job.companyName ?? '-';
    final tags = JobDisplay.tags(job);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailLowongan(idJob: job.idJob),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (salary.isNotEmpty)
                  Text(
                    salary,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2862E8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.business_center_outlined,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          company,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  job.location,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),
            Row(
              children: [
                CompanyLogo(path: job.companyLogo, size: 16, radius: 4),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    company,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
