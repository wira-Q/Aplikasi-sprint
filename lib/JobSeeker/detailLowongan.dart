import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'halamanLamar.dart';

class DetailLowongan extends StatelessWidget {
  const DetailLowongan({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna utama aplikasi (biru)
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU UTAMA INFO LOWONGAN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Logo & Nama Perusahaan
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/p1.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'DB Klik',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Judul Posisi Pekerjaan
                  Text(
                    'AI Enginering',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Chip Atribut (Lokasi, Full Time, Uang Makan)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.location_on_outlined, 'Malang'),
                      _buildInfoChip(Icons.work_outline, 'Full Time'),
                      _buildInfoChip(Icons.restaurant_outlined, 'Uang makan'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Kotak Gaji
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Rp. 4.000.000 - Rp. 8.000.000',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TENTANG PEKERJAAN
            Text(
              'Tentang pekerjaan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'kami mencari ai enginering developer untuk mengembangkan project dan sistem fullstack perusahaan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // KUALIFIKASI
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  'Kualifikasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Daftar Poin Kualifikasi
            _buildQualificationItem('minimal SMK/D1/S1'),
            _buildQualificationItem('menguasi java/node.js'),
            _buildQualificationItem('memahami program/code'),
            _buildQualificationItem('usia 18 - 30 tahun'),

            const SizedBox(height: 40),
          ],
        ),
      ),

     // TOMBOL LAMAR PEKERJAAN DI BAWAH
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // Menambahkan navigasi untuk pindah ke halaman UploadCv
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HalamanLamar(),
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
              'Lamar pekerjaan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper untuk chip informasi di kartu
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk poin kualifikasi
  Widget _buildQualificationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}