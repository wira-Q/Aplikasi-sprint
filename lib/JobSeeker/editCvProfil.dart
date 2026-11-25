import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/models/cv_model.dart';
import 'package:sprint/services/cv_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EditCvProfil extends StatefulWidget {
  const EditCvProfil({super.key});

  @override
  State<EditCvProfil> createState() => _EditCvProfilState();
}

class _EditCvProfilState extends State<EditCvProfil> {
  final CvService _service = CvService();

  List<CvModel> _cvs = [];
  bool _isLoading = true;
  bool _isUploading = false;
  int? _deletingId;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final list = await _service.getMyCvs();
      if (!mounted) return;
      setState(() {
        _cvs = list;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Gagal memuat CV. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  // Fungsi untuk memilih file PDF dari perangkat lalu mengunggahnya
  Future<void> _pickCvFile() async {
    if (_isUploading) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        _snack('File tidak dapat dibaca. Coba pilih file lain.', error: true);
        return;
      }
      if (bytes.length > CvRules.maxBytes) {
        _snack('Ukuran CV maksimal 5 MB.', error: true);
        return;
      }

      setState(() => _isUploading = true);
      await _service.uploadCv(bytes: bytes, fileName: file.name);
      if (!mounted) return;
      setState(() => _isUploading = false);
      _snack('CV berhasil diunggah.');
      _load();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      _snack(e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      _snack('Gagal mengunggah CV. Coba lagi.', error: true);
    }
  }

  Future<void> _confirmDelete(CvModel cv) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus CV?'),
        content: Text('${cv.fileName} akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _deletingId = cv.idCv);
    try {
      await _service.deleteCv(cv.idCv);
      if (!mounted) return;
      setState(() => _deletingId = null);
      _snack('CV dihapus.');
      _load();
    } on AppException catch (e) {
      // Termasuk pesan "CV sedang dipakai pada lamaran".
      if (!mounted) return;
      setState(() => _deletingId = null);
      _snack(e.message, error: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _deletingId = null);
      _snack('Gagal menghapus CV. Coba lagi.', error: true);
    }
  }

  Future<void> _openCv(CvModel cv) async {
    try {
      final url = await _service.createSignedUrl(cv.idCv);
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) _snack('Tidak dapat membuka CV.', error: true);
    } on AppException catch (e) {
      if (mounted) _snack(e.message, error: true);
    } catch (_) {
      if (mounted) _snack('Tidak dapat membuka CV.', error: true);
    }
  }

  String _sizeText(int? bytes) {
    if (bytes == null) return '';
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).ceil()} KB';
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
                        'CV / Resume',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Tombol Selesai (Centang): CV tersimpan saat diunggah
                  IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // KETERANGAN ATAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
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
                      'Unggah file CV atau resume kamu dalam format PDF.\nUkuran file maksimal 5 MB.',
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

            const SizedBox(height: 20),

            // DAFTAR CV YANG SUDAH DIUNGGAH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCvList(),
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
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ikon Upload Besar di Tengah
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBF2FF),
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
                            onPressed: _isUploading ? null : _pickCvFile,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.upload_file,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            label: Text(
                              _isUploading ? 'Mengunggah...' : 'Pilih File PDF',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCvList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_loadError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _loadError!,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: _load,
            child: Text(
              'Coba lagi',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      );
    }
    if (_cvs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          'Belum ada CV. Unggah CV pertama Anda di bawah.',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _cvs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildCvCard(_cvs[index]),
      ),
    );
  }

  Widget _buildCvCard(CvModel cv) {
    final uploaded = cv.uploadedAt;
    final info = [
      if (uploaded != null) DateFormatId.date(uploaded),
      if (_sizeText(cv.fileSize).isNotEmpty) _sizeText(cv.fileSize),
    ].join(' • ');

    return GestureDetector(
      onTap: () => _openCv(cv),
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
              child: const Icon(
                Icons.description_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cv.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            _deletingId == cv.idCv
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () => _confirmDelete(cv),
                  ),
          ],
        ),
      ),
    );
  }
}
