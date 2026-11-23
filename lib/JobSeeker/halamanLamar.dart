import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart'; // Untuk ambil file dari laptop/perangkat
import 'successScreen.dart'; // Menuju ke halaman sukses

class HalamanLamar extends StatefulWidget {
  const HalamanLamar({super.key});

  @override
  State<HalamanLamar> createState() => _HalamanLamarState();
}

class _HalamanLamarState extends State<HalamanLamar> {
  final Color primaryColor = const Color(0xFF203F8B);
  final TextEditingController _messageController = TextEditingController();

  // Variabel untuk menyimpan nama file PDF yang dipilih
  String? _fileName;

  // Fungsi untuk membuka folder laptop/perangkat dan memilih file PDF
  Future<void> _pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Hanya mengizinkan file berformat PDF
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name; // Simpan nama file
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil memilih: $_fileName')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Melamar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Halo!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lengkapi data diri anda terlebih dahulu untuk\nmelamar pekerjaan yang sesuai',
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

            // CONTAINER PUTIH BAWAH
            Expanded(
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
                      // Instruksi Upload CV
                      RichText(
                        text: TextSpan(
                          text: '*',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: ' upload CV dalam bentuk pdf',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tombol Unggah File (Terhubung ke folder laptop/perangkat)
                      Center(
                        child: SizedBox(
                          width: 220,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: _pickPDFFile, // Memanggil fungsi pilih file PDF
                            icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                            label: Text(
                              _fileName == null ? 'Unggah File' : 'Ganti File PDF',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF93C5FD),
                              foregroundColor: primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Menampilkan nama file jika sudah dipilih
                      if (_fileName != null)
                        Center(
                          child: Text(
                            'File terpilih: $_fileName',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Label Pesan untuk Recruiter
                      Text(
                        'Pesan untuk Recruiter',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Text Field untuk Pesan
                      TextField(
                        controller: _messageController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Kirim Pesan',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEBF2FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // TOMBOL KIRIM LAMARAN (Menuju SuccessScreen)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Validasi: Cek apakah file sudah diunggah
                            if (_fileName == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Harap unggah CV terlebih dahulu!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Jika sudah, arahkan ke SuccessScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SuccessScreen(),
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
                            'Kirim Lamaran',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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