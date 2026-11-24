import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailDiTolak extends StatelessWidget {
  const DetailDiTolak({super.key});

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
                  Text(
                    'Lihat Desain lamaran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // KETERANGAN JUDUL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. KARTU INFORMASI PERUSAHAAN & POSISI (Status Ditolak / Merah)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/p2.png', // Sesuaikan asset logo perusahaan
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.business, color: Colors.black54),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DB klik',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Position : UI/UX Designer',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.red, // Indikator merah untuk Ditolak
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ditolak',
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
                      ),

                      const SizedBox(height: 20),

                      // 2. JADWAL INTERVIEW SECTION (Strip '-')
                      Text(
                        'Jadwal Interview',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black87),
                                const SizedBox(width: 12),
                                Text(
                                  '-',
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 20, color: Colors.black87),
                                const SizedBox(width: 12),
                                Text(
                                  '-',
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.black87),
                                const SizedBox(width: 12),
                                Text(
                                  '-',
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. LINK GOOGLE MEET SECTION (Strip '-')
                      Text(
                        'Link Google meet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.video_call_rounded,
                              color: Color.fromARGB(255, 255, 238, 49),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '-',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 4. RECRUITER MESSAGE SECTION
                      Row(
                        children: [
                          const Text(
                            '*',
                            style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'recruiter message',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Kepada Mas Hendry silahkan berusaha kembali anda kurang memenuhi standar dari perusahaan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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