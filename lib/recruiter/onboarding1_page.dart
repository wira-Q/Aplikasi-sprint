import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sprint/recruiter/onboarding_draft.dart';

// Onboarding 1 (1/3): Kenalan dengan perusahaan kamu
// Upload logo -> membuka galeri. Logo baru diunggah di halaman 3.
class Onboarding1Page extends StatefulWidget {
  const Onboarding1Page({super.key});

  @override
  State<Onboarding1Page> createState() => _Onboarding1PageState();
}

class _Onboarding1PageState extends State<Onboarding1Page> {
  static const Color _navy = Color(0xFF1E3A8A);
  static const Color _blue = Color(0xFF2863E9);
  static const Color _fieldBg = Color(0xFFF0F2F6);
  static const int _maxLogoBytes = 2 * 1024 * 1024; // 2 MB

  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _namaController;

  Uint8List? _logoBytes;
  String? _logoName;
  String? _industri;

  final List<String> _industries = [
    'Teknologi Informasi',
    'Keuangan',
    'Pendidikan',
    'Kesehatan',
    'Manufaktur',
    'Retail',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    // Isi ulang dari draf, supaya tombol kembali dari halaman 2 tidak
    // mengosongkan isian.
    _namaController = TextEditingController(text: CompanyOnboardingDraft.name);
    _logoBytes = CompanyOnboardingDraft.logoBytes;
    _logoName = CompanyOnboardingDraft.logoName;
    _industri = CompanyOnboardingDraft.industry;
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Buka galeri dan pilih logo
  Future<void> _pickLogo() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (file == null) return; // pengguna membatalkan

      final name = file.name.toLowerCase();
      final hasExtension = name.contains('.');
      final validType =
          name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png') ||
          name.endsWith('.webp');

      if (hasExtension && !validType) {
        _showMessage('Format logo harus JPG, PNG, atau WebP');
        return;
      }

      final bytes = await file.readAsBytes();

      if (bytes.length > _maxLogoBytes) {
        _showMessage('Ukuran logo maksimal 2MB');
        return;
      }

      if (!mounted) return;
      setState(() {
        _logoBytes = bytes;
        _logoName = file.name;
      });
    } catch (e) {
      _showMessage('Gagal membuka galeri');
    }
  }

  void _removeLogo() {
    setState(() {
      _logoBytes = null;
      _logoName = null;
    });
  }

  void _lanjut() {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      _showMessage('Nama perusahaan wajib diisi');
      return;
    }
    if (nama.length > 150) {
      _showMessage('Nama perusahaan terlalu panjang');
      return;
    }
    if (_industri == null) {
      _showMessage('Pilih bidang industri');
      return;
    }

    CompanyOnboardingDraft.name = nama;
    CompanyOnboardingDraft.industry = _industri;
    CompanyOnboardingDraft.logoBytes = _logoBytes;
    CompanyOnboardingDraft.logoName = _logoName;

    Navigator.pushNamed(context, '/onboarding2');
  }

  // ---------- widget ----------
  Widget _header() {
    return Row(
      children: [
        // Halaman 1 bisa menjadi satu-satunya halaman di tumpukan setelah
        // login, jadi panah kembali hanya tampil jika memang ada halaman
        // sebelumnya.
        if (Navigator.canPop(context)) ...[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.chevron_left,
              size: 24,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _navy,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E5EC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          '1/3',
          style: TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _uploadBox() {
    return GestureDetector(
      onTap: _pickLogo,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFF8AA6F5),
          radius: 10,
        ),
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _logoBytes == null ? _uploadPlaceholder() : _logoPreview(),
        ),
      ),
    );
  }

  Widget _uploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFE3ECFE),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.photo_camera_outlined,
            size: 17,
            color: _blue,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Upload Logo',
          style: TextStyle(
            color: _blue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'JPG, PNG, WebP (maks. 2MB)',
          style: TextStyle(color: Colors.black54, fontSize: 8),
        ),
      ],
    );
  }

  Widget _logoPreview() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _logoBytes!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _logoName ?? 'logo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 8),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Ketuk untuk ganti logo',
                style: TextStyle(
                  color: _blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: _removeLogo,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            color: Color(0xFF263247),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 10, color: Colors.black45),
      prefixIcon: Icon(icon, size: 16, color: Colors.black54),
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _formCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Logo Perusahaan'),
          _uploadBox(),
          const SizedBox(height: 18),
          _label('Nama Perusahaan', required: true),
          TextField(
            controller: _namaController,
            style: const TextStyle(fontSize: 11),
            decoration: _decoration(
              'Contoh: PT Teknologi ABC',
              Icons.business_outlined,
            ),
          ),
          const SizedBox(height: 18),
          _label('Bidang Industri', required: true),
          DropdownButtonFormField<String>(
            value: _industri,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            style: const TextStyle(fontSize: 11, color: Colors.black87),
            decoration: _decoration(
              'Pilih bidang industri',
              Icons.grid_view_rounded,
            ),
            items: _industries
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _industri = v),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 22),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3ECFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: _navy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Kenalan dengan perusahaan\nkamu',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lengkapi informasi dasar perusahaan agar\nkandidat lebih mengenal kamu.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _formCard(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _lanjut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lanjut',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward, size: 16),
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

// Garis putus-putus untuk kotak upload
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
