import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/JobSeeker/main_navigation.dart';
import 'dashboard.dart';

class OnBoarding3 extends StatefulWidget {
  const OnBoarding3({super.key});

  @override
  State<OnBoarding3> createState() => _OnBoarding3State();
}

class _OnBoarding3State extends State<OnBoarding3> {
  // Mengatur warna utama halaman
  final Color primaryColor = const Color(0xFF203F8B);

  // State untuk menyimpan daftar lokasi yang dipilih
  final Set<String> _selectedLocations = {'Surabaya'};

  // Daftar lokasi populer
  final List<String> _popularLocations = ['Malang', 'Surabaya', 'Pasuruhan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER BIRU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Kembali
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Indikator Halaman 03 / 03
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '03 / 03',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 12,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 24,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // KONTEN HEADER (Ikon Lokasi & Teks)
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ikon Pin Lokasi
                      const Icon(
                        Icons.location_on_outlined,
                        size: 70,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 15),

                      // Judul
                      Text(
                        'Lokasi Lowongan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Deskripsi
                      Text(
                        'Pilih lokasi yang ingin kamu cari. Kamu bisa memilih lebih\ndari satu.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // CONTAINER FORM PUTIH
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEARCH BAR LOKASI
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari kota atau daerah...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.grey,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                          filled: true,
                          fillColor: const Color(0xFFF5F6F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // LABEL LOKASI POPULER
                      Text(
                        'Lokasi Populer',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // PILIHAN CHIP LOKASI POPULER
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _popularLocations.map((location) {
                          bool isSelected = _selectedLocations.contains(location);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedLocations.remove(location);
                                } else {
                                  _selectedLocations.add(location);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withOpacity(0.05)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                location,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),

                      // TOMBOL LANJUTKAN (SELESAI)
                     SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigasi ke halaman Dashboard dan menghapus riwayat onboarding dari stack
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainNavigation(), // Pastikan nama class sesuai
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2862E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Lanjutkan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
}