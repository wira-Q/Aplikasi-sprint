import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'editProfil.dart';
import 'editCvProfil.dart';
import 'statusLamaran.dart';
import 'login.dart'; // Pastikan file halaman login kamu sudah di-import (sesuaikan nama file login-mu jika berbeda, mis. login.dart)

class DashboardProfil extends StatelessWidget {
  const DashboardProfil({super.key});

  // Fungsi untuk menampilkan Pop-up Dialog Logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Logout Merah di Atas Pop-up
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),

                // Judul "Already Leaving?"
                Text(
                  'Already Leaving?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Are you sure that want to logout?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Tombol Aksi (Yes & No)
                Row(
                  children: [
                    // Tombol Merah (Logout ke halaman Login)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Menghapus semua riwayat halaman dan kembali ke halaman Login
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(), // Sesuaikan dengan nama class halaman loginmu
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D4F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Yes, I want to Logout',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Biru (Tetap di halaman profil)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Menutup dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B5B9D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'No, I\'m Staying',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
            // BAGIAN ATAS: Judul & Ikon Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profil anda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.logout_rounded, color: Color.fromARGB(255, 236, 5, 5), size: 20),
                      onPressed: () {
                        // Memanggil fungsi dialog pop-up logout di atas
                        _showLogoutDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // KARTU PROFIL UTAMA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    // Foto Profil
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/profil.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person, size: 30, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Nama & Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aqeela Calista',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.school_outlined, size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                'Fresh Graduate',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 13, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Malang, Jl. Kencana',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Ikon Edit Profil
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color.fromARGB(255, 255, 255, 255), size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfil(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // MENU ITEM (CV / Resume & Status Lamaran)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Menu 1: CV / Resume
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_outlined, color: Colors.white, size: 22),
                    ),
                    title: Text(
                      'CV / Resume',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      'CV_User.pdf',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditCvProfil(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24, height: 20),

                  // Menu 2: Status Lamaran
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 22),
                    ),
                    title: Text(
                      'Status lamaran',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      'Status lamaran',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatusLamaran(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24, height: 20),
                ],
              ),
            ),

            const Spacer(),

            // BAGIAN BAWAH DENGAN SUDUT MELENGKUNG PUTIH
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share profile diklik!')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, color: Colors.black87, size: 20),
                  label: Text(
                    'Share profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBF2FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
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