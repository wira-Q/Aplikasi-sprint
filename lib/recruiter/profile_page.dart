import 'package:flutter/material.dart';

import 'login_page.dart';

// Halaman Profil (konten saja).
// Bottom navigation dipegang oleh DashboardPage.
class ProfilePage extends StatefulWidget {
  // Dipanggil saat tombol panah kembali ditekan (balik ke Home).
  final VoidCallback? onBack;

  const ProfilePage({super.key, this.onBack});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color bgBlue = Color(0xFF1C3B8B);

  String name = 'PT XYZ';
  String industry = 'Teknologi informasi';
  String location = 'Malang, Jawa Timur';
  String email = 'hr@ptxyz.com';
  String website = 'www.ptxyz.com';
  String description =
      'Perusahaan yang bergerak di bidang pengembangan teknologi dan software';

  // Dialog logout "Already Leaving?" sesuai desain Figma
  void _confirmLogout() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF2D2D),
                  size: 52,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Already Leaving?',
                  style: TextStyle(
                    color: Color(0xFF17233D),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Are you sure that want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF17233D),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4B4B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Yes, I want to logout',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B72B8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "No, I'm Staying",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
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

  void _editProfile() {
    final nameC = TextEditingController(text: name);
    final industryC = TextEditingController(text: industry);
    final locationC = TextEditingController(text: location);
    final emailC = TextEditingController(text: email);
    final websiteC = TextEditingController(text: website);
    final descC = TextEditingController(text: description);

    Widget field(String label, TextEditingController c, {int lines = 1}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          maxLines: lines,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field('Nama Perusahaan', nameC),
                field('Bidang', industryC),
                field('Lokasi', locationC),
                field('Email', emailC),
                field('Website', websiteC),
                field('Deskripsi', descC, lines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (nameC.text.trim().isNotEmpty) name = nameC.text.trim();
                  industry = industryC.text.trim();
                  location = locationC.text.trim();
                  email = emailC.text.trim();
                  website = websiteC.text.trim();
                  description = descC.text.trim();
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ).then((_) {
      nameC.dispose();
      industryC.dispose();
      locationC.dispose();
      emailC.dispose();
      websiteC.dispose();
      descC.dispose();
    });
  }

  Widget _logo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Image.asset(
          'assets/images/logo_company.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF3858A2),
              child: const Icon(
                Icons.business,
                color: Colors.white,
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _companyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _logo(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  industry,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: _editProfile,
              child: const Padding(
                padding: EdgeInsets.only(top: 28),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 6),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Colors.white.withOpacity(0.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgBlue,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: panah kembali + judul + tombol keluar
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 14, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Profil anda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _confirmLogout,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _companyCard(),
              ),
              const SizedBox(height: 22),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Informasi Perusahaan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _infoRow(Icons.location_on_outlined, 'Lokasi', location),
                    _infoRow(Icons.mail_outline_rounded, 'Email', email),
                    _infoRow(Icons.language_rounded, 'Website', website),
                    _infoRow(
                      Icons.description_outlined,
                      'Deskripsi',
                      description,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}