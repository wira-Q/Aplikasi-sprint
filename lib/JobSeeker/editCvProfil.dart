import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart'; // Pastikan package ini sudah ada di pubspec.yaml

class EditCvProfil extends StatefulWidget {
  const EditCvProfil({super.key});

  @override
  State<EditCvProfil> createState() => _EditCvProfilState();
}

class _EditCvProfilState extends State<EditCvProfil> {
  // Nama file CV yang sedang dipilih/diunggah (default: CV_User.pdf)
  String? _fileName = 'CV_User.pdf';

  // Fungsi untuk memilih file PDF dari perangkat
  Future<void> _pickCvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
          _fileName = result.files.single.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File berhasil dipilih: $_fileName')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih file: $e')),
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
            // BAGIAN ATAS: App Bar (Back, Title, Check Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Tombol Simpan (Centang)
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.white, size: 24),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('CV / Resume berhasil diperbarui!')),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // KETERANGAN ATAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CV / RESUME',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unggah file CV atau resume kamu dalam format PDF.\nPastikan ukuran file tidak terlalu besar!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KOTAK KARTU CV YANG SUDAH DIUNGGAH (JIKA ADA)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.description_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CV / Resume',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fileName ?? 'Belum ada file dipilih',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 20),
                      onPressed: () {
                        setState(() {
                          _fileName = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('CV dihapus. Silakan unggah baru.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // KONTEN UTAMA BAWAH: KOTAK PUTIH MELENGKUNG
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ikon Upload Besar di Tengah
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tambahkan CV / Resume',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Klik tombol di bawah untuk mengunggah\nfile CV dalam format PDF.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Tombol Pilih File PDF
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _pickCvFile,
                        icon: const Icon(Icons.upload_file, color: Colors.white, size: 20),
                        label: Text(
                          'Pilih File PDF',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}