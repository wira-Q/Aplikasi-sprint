import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart'; // Untuk ambil file dari laptop/perangkat
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/models/cv_model.dart';
import 'package:sprint/services/application_service.dart';
import 'package:sprint/services/cv_service.dart';
import 'successScreen.dart'; // Menuju ke halaman sukses

class HalamanLamar extends StatefulWidget {
  const HalamanLamar({super.key, required this.idJob});

  final int idJob;

  @override
  State<HalamanLamar> createState() => _HalamanLamarState();
}

class _HalamanLamarState extends State<HalamanLamar> {
  final Color primaryColor = const Color(0xFF203F8B);
  final TextEditingController _messageController = TextEditingController();

  final CvService _cvService = CvService();
  final ApplicationService _applicationService = ApplicationService();

  // CV yang sudah tersimpan (terbaru dipakai otomatis).
  CvModel? _selectedCv;
  bool _isLoadingCv = true;

  // File PDF baru yang dipilih, baru diunggah saat lamaran dikirim.
  Uint8List? _pickedBytes;
  String? _pickedName;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCv();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadCv() async {
    try {
      final list = await _cvService.getMyCvs();
      if (!mounted) return;
      setState(() {
        _selectedCv = list.isNotEmpty ? list.first : null;
        _isLoadingCv = false;
      });
    } catch (_) {
      // Tanpa daftar CV, pengguna tetap bisa memilih file baru.
      if (!mounted) return;
      setState(() => _isLoadingCv = false);
    }
  }

  // Fungsi untuk membuka folder laptop/perangkat dan memilih file PDF
  Future<void> _pickPDFFile() async {
    if (_isSubmitting) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Hanya mengizinkan file berformat PDF
        withData: true, // Isi file dibutuhkan untuk diunggah
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() {
          _errorMessage = 'File tidak dapat dibaca. Coba pilih file lain.';
        });
        return;
      }
      if (bytes.length > CvRules.maxBytes) {
        setState(() => _errorMessage = 'Ukuran CV maksimal 5 MB.');
        return;
      }
      setState(() {
        _pickedBytes = bytes;
        _pickedName = file.name;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Gagal memilih file. Coba lagi.');
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    // Validasi: Cek apakah ada CV (file baru atau CV tersimpan)
    if (_pickedBytes == null && _selectedCv == null) {
      setState(() => _errorMessage = 'Harap unggah CV terlebih dahulu!');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final int idCv;
      final bytes = _pickedBytes;
      if (bytes != null) {
        final cv = await _cvService.uploadCv(
          bytes: bytes,
          fileName: _pickedName ?? 'cv.pdf',
        );
        idCv = cv.idCv;
        // Jadikan CV terpilih supaya percobaan ulang tidak mengunggah lagi.
        if (mounted) {
          setState(() {
            _selectedCv = cv;
            _pickedBytes = null;
            _pickedName = null;
          });
        }
      } else {
        idCv = _selectedCv!.idCv;
      }

      final application = await _applicationService.apply(
        idJob: widget.idJob,
        idCv: idCv,
        message: _messageController.text,
      );

      if (!mounted) return;
      // Jika sudah, arahkan ke SuccessScreen dengan data lamaran
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(application: application),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Periksa koneksi Anda.';
        _isSubmitting = false;
      });
    }
  }

  String get _fileInfo {
    if (_pickedName != null) {
      return 'File terpilih: $_pickedName (diunggah saat lamaran dikirim)';
    }
    final cv = _selectedCv;
    if (cv != null) return 'CV Anda: ${cv.fileName}';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _pickedName != null || _selectedCv != null;

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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                              text: ' upload CV dalam bentuk pdf (maks. 5 MB)',
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

                      // Tombol Unggah File
                      Center(
                        child: SizedBox(
                          width: 220,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: (_isSubmitting || _isLoadingCv)
                                ? null
                                : _pickPDFFile,
                            icon: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 20,
                            ),
                            label: Text(
                              hasFile ? 'Ganti File PDF' : 'Unggah File',
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

                      // Menampilkan file yang akan dipakai
                      if (_isLoadingCv)
                        const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (_fileInfo.isNotEmpty)
                        Center(
                          child: Text(
                            _fileInfo,
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
                        enabled: !_isSubmitting,
                        maxLines: 5,
                        maxLength: 1000,
                        decoration: InputDecoration(
                          hintText: 'Kirim Pesan',
                          counterText: '',
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

                      // PESAN ERROR (hanya muncul jika ada)
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else
                        const SizedBox(height: 30),

                      // TOMBOL KIRIM LAMARAN (Menuju SuccessScreen)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (_isSubmitting || _isLoadingCv)
                              ? null
                              : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2862E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
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
