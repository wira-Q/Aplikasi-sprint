import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/application_status_style.dart';
import 'package:sprint/core/widgets/company_logo.dart';
import 'package:sprint/models/application_model.dart';
import 'main_navigation.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.application});

  /// Lamaran yang baru dikirim.
  final ApplicationModel application;

  String get _statusText => application.status == ApplicationStatus.diproses
      ? 'Menunggu Review'
      : ApplicationStatusStyle.label(application.status);

  @override
  Widget build(BuildContext context) {
    // Warna utama latar belakang (biru tua)
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // 1. IKON DOKUMEN & CEKLIST DI ATAS
              const Icon(
                Icons.assignment_turned_in_outlined,
                size: 70,
                color: Colors.white,
              ),

              const SizedBox(height: 20),

              // 2. JUDUL UTAMA
              Text(
                'Lamaran Berhasil Dikirim!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 3. DESKRIPSI
              Text(
                'Terima kasih telah melamar.\nRecruiter akan melihat profil kamu.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 35),

              // 4. KARTU DETAIL LAMARAN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Warna kotak sedikit lebih tua / gelap agar kontras di atas background biru
                  color: const Color(0xFF162D68),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian Atas Kartu (Logo & Info Posisi)
                    Row(
                      children: [
                        CompanyLogo(
                          path: application.companyLogo,
                          size: 42,
                          radius: 10,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.jobTitle ?? '-',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                application.companyName ?? '-',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: Colors.white24, height: 1),
                    ),

                    // Bagian Bawah Kartu (Status Lamaran)
                    Text(
                      'Status Lamaran',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              const SizedBox(height: 20),

              // 6. TOMBOL "Kembali ke Beranda"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    // Mengarahkan kembali ke MainNavigation dan menghapus semua riwayat halaman di belakangnya
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigation(),
                      ),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
