import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'detailInterview.dart';
import 'detailDisetujui.dart';
import 'detaildiTolak.dart'; // <-- 1. Import halaman detail ditolak

class StatusLamaran extends StatelessWidget {
  const StatusLamaran({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);

    // Data dummy untuk riwayat status lamaran
    final List lamaranList = [
      {
        'company': 'PT Arina Multikarya',
        'status': 'Interview',
        'statusColor': Colors.amber,
        'date': '22 Januari 2026, 09.00',
      },
      {
        'company': 'PT QLCOM Solusi Bisnis',
        'status': 'Disetujui',
        'statusColor': Colors.green,
        'date': '22 Januari 2026, 09.00',
      },
      {
        'company': 'DB klik',
        'status': 'Ditolak',
        'statusColor': Colors.red,
        'date': '22 Januari 2026, 09.00',
      },
    ];

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
                child: ListView.builder(
                  itemCount: lamaranList.length,
                  itemBuilder: (context, index) {
                    final item = lamaranList[index];
                    
                    // Bungkus Container dengan GestureDetector untuk navigasi
                    return GestureDetector(
                      onTap: () {
                        // 2. Navigasi berdasarkan status lamaran
                        if (item['status'] == 'Interview') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailInterview(),
                            ),
                          );
                        } else if (item['status'] == 'Disetujui') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailDisetujui(),
                            ),
                          );
                        } else if (item['status'] == 'Ditolak') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailDiTolak(),
                            ),
                          );
                        }
                      },
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
                                    item['company'],
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
                                        item['status'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Indikator Titik Warna (Kuning/Hijau/Merah)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: item['statusColor'],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Tanggal di Kanan
                            Text(
                              item['date'],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}