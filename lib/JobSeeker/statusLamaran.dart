import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/application_status_style.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/core/utils/paged_controller.dart';
import 'package:sprint/core/widgets/page_bar.dart';
import 'package:sprint/models/application_model.dart';
import 'package:sprint/services/application_service.dart';
import 'lamaran_page_resolver.dart';

class StatusLamaran extends StatefulWidget {
  const StatusLamaran({super.key});

  @override
  State<StatusLamaran> createState() => _StatusLamaranState();
}

class _StatusLamaranState extends State<StatusLamaran> {
  final ApplicationService _service = ApplicationService();
  final ScrollController _scroll = ScrollController();
  late final PagedController<ApplicationModel> _pager;

  @override
  void initState() {
    super.initState();
    _pager = PagedController<ApplicationModel>(
      fetch: (page, size) =>
          _service.getMyApplicationsPage(page: page, pageSize: size),
      onChanged: () {
        if (mounted) setState(() {});
      },
      errorText: 'Gagal memuat lamaran. Periksa koneksi Anda.',
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

  Future<void> _open(ApplicationModel a) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => lamaranDetailPage(a)),
    );
    // Muat ulang diam-diam: status mungkin berubah sejak daftar dimuat.
    if (mounted) _pager.load(spinner: false);
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
                child: RefreshIndicator(
                  onRefresh: () => _pager.load(spinner: false),
                  child: ListView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
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
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
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
      return [
        SizedBox(
          height: 260,
          child: Center(
            child: Text(
              'Belum ada lamaran',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ];
    }
    return _pager.items.map(_buildItem).toList();
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
