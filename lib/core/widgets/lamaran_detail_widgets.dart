import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/application_status_style.dart';
import 'package:sprint/core/widgets/company_logo.dart';
import 'package:sprint/models/application_model.dart';
import 'package:sprint/models/interview_model.dart';
import 'package:sprint/services/application_service.dart';
import 'package:sprint/services/interview_service.dart';

const Color _primaryColor = Color(0xFF203F8B);

/// Kerangka halaman detail lamaran: latar biru, tombol kembali, judul,
/// dan kotak putih melengkung berisi [child].
class LamaranDetailScaffold extends StatelessWidget {
  const LamaranDetailScaffold({
    super.key,
    required this.child,
    this.title = 'Detail Lamaran',
  });

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
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
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KONTEN UTAMA: KOTAK PUTIH MELENGKUNG
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Memuat satu lamaran milik pengguna beserta riwayat interviewnya, lalu
/// memanggil [builder] untuk mengisi isi halaman. Menangani loading, error,
/// dan tombol "Coba lagi".
class LamaranDetailLoader extends StatefulWidget {
  const LamaranDetailLoader({
    super.key,
    required this.idApplication,
    required this.builder,
  });

  final int idApplication;
  final List<Widget> Function(
    BuildContext context,
    ApplicationModel application,
    List<InterviewModel> interviews,
  )
  builder;

  @override
  State<LamaranDetailLoader> createState() => _LamaranDetailLoaderState();
}

class _LamaranDetailLoaderState extends State<LamaranDetailLoader> {
  final ApplicationService _applications = ApplicationService();
  final InterviewService _interviewService = InterviewService();

  ApplicationModel? _application;
  List<InterviewModel> _interviewList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final application = await _applications.getMyApplicationById(
        widget.idApplication,
      );
      if (application == null) {
        throw const AppException('Lamaran tidak ditemukan.');
      }
      final interviews = await _interviewService.getByApplication(
        widget.idApplication,
      );
      if (!mounted) return;
      setState(() {
        _application = application;
        _interviewList = interviews;
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

  @override
  Widget build(BuildContext context) {
    final application = _application;

    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (application == null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage ?? 'Lamaran tidak ditemukan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    } else {
      body = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.builder(context, application, _interviewList),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return LamaranDetailScaffold(child: body);
  }
}

/// Kartu perusahaan, posisi, dan status lamaran.
class LamaranCompanyCard extends StatelessWidget {
  const LamaranCompanyCard({super.key, required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    final status = application.status;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CompanyLogo(path: application.companyLogo, size: 48, radius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.companyName ?? '-',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Position : ${application.jobTitle ?? '-'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ApplicationStatusStyle.color(status),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ApplicationStatusStyle.label(status),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Judul bagian. [requiredMark] menambah tanda * merah di depan judul.
class LamaranSectionTitle extends StatelessWidget {
  const LamaranSectionTitle(this.text, {super.key, this.requiredMark = false});

  final String text;
  final bool requiredMark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (requiredMark) ...[
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// Kotak abu-abu berisi beberapa baris [LamaranInfoRow].
class LamaranInfoBox extends StatelessWidget {
  const LamaranInfoBox({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Satu baris: ikon, teks, dan (opsional) widget di ujung kanan.
class LamaranInfoRow extends StatelessWidget {
  const LamaranInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = Colors.black87,
    this.textColor = Colors.black87,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
