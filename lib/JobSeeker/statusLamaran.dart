import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/application_status_style.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/models/application_model.dart';
import 'package:sprint/services/application_service.dart';
import 'lamaran_page_resolver.dart';

class StatusLamaran extends StatefulWidget {
  const StatusLamaran({super.key});

  @override
  State<StatusLamaran> createState() => _StatusLamaranState();
}

class _StatusLamaranState extends State<StatusLamaran> {
  static const int _pageSize = 10;

  final ApplicationService _service = ApplicationService();

  List<ApplicationModel> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _errorMessage;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final list = await _service.getMyApplications(
        page: 0,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items = list;
        _page = 0;
        _hasMore = list.length == _pageSize;
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
        _errorMessage = 'Gagal memuat lamaran. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final list = await _service.getMyApplications(
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _page += 1;
        _items = [..._items, ...list];
        _hasMore = list.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      final message = e is AppException
          ? e.message
          : 'Gagal memuat lamaran. Periksa koneksi Anda.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Halaman detail sesuai status lamaran.
  /// Halaman detail sesuai status lamaran.
  Widget _pageFor(ApplicationModel a) => lamaranDetailPage(a);

  Future<void> _open(ApplicationModel a) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pageFor(a)),
    );
    // Muat ulang diam-diam: status mungkin berubah sejak daftar dimuat.
    if (mounted) _loadFirstPage(showSpinner: false);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // BAGIAN ATAS: App Bar (Back & Title)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),

            // KETERANGAN JUDUL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lamaran Saya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat status lamaran dari rekruitmen untuk dirimu!',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // KONTEN UTAMA: KOTAK PUTIH MELENGKUNG BERISI LIST LAMARAN
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            TextButton(
              onPressed: _loadFirstPage,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'Belum ada lamaran',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadFirstPage(showSpinner: false),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: _loadMore,
                        child: const Text('Muat lebih banyak'),
                      ),
              ),
            );
          }
          return _buildItem(_items[index]);
        },
      ),
    );
  }

  Widget _buildItem(ApplicationModel item) {
    final appliedAt = item.appliedAt;
    return GestureDetector(
      onTap: () => _open(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6), // Warna abu-abu terang sesuai desain
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Ikon Dokumen di Kiri
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Colors.black87,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Informasi Perusahaan & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.companyName ?? '-',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        ApplicationStatusStyle.label(item.status),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Indikator Titik Warna
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ApplicationStatusStyle.color(item.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tanggal di Kanan
            if (appliedAt != null)
              Text(
                DateFormatId.dateTime(appliedAt),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
