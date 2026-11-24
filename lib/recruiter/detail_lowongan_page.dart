import 'package:flutter/material.dart';

import 'dasboard_page.dart';

// Halaman Detail Lowongan.
// "Lihat Pelamar" dan "Kelola Lowongan" -> halaman Daftar Pelamar.
class DetailLowonganPage extends StatefulWidget {
  final Map<String, dynamic> job;
  final String company;

  const DetailLowonganPage({
    super.key,
    required this.job,
    this.company = 'PT XYZ',
  });

  @override
  State<DetailLowonganPage> createState() => _DetailLowonganPageState();
}

class _DetailLowonganPageState extends State<DetailLowonganPage> {
  static const Color _blue = Color(0xFF2863E9);
  static const Color _dark = Color(0xFF17233D);
  static const Color _grey = Color(0xFF6B7280);

  int selectedTab = 0;
  static const List<String> _tabs = ['Deskripsi', 'Kualifikasi', 'Perusahaan'];

  // ---------- data dari job ----------
  String _text(String key, String fallback) {
    final v = widget.job[key];
    if (v == null || v.toString().trim().isEmpty) return fallback;
    return v.toString();
  }

  String get title => _text('title', 'Backend Developer');
  String get location => _text('location', 'Malang');
  String get type => _text('type', 'Full Time');
  String get salary => _text('salary', 'Rp 4.000.000- Rp 6.000.000');
  String get applicants => _text('applicants', '0');
  String get description => _text(
        'description',
        'Bertanggung jawab untuk pengembangan antarmuka pengguna (UI)',
      );

  List<String> get qualifications {
    final education = _text('education', 'SI');
    final experience = _text('experience', '1 tahun');
    final skills = widget.job['skills'];

    String skillText = 'Java dan Java Scribe';
    if (skills is List && skills.isNotEmpty) {
      skillText = skills.join(', ');
    }

    return [
      'Pendidikan minimal $education',
      'Menguasai $skillText',
      'Memahami konsep REST API',
      'Pengalaman minimal $experience (Lebih diutamakan)',
    ];
  }

  // ---------- navigasi ----------
  void _openApplicants() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(initialIndex: 1),
      ),
      (route) => false,
    );
  }

  // ---------- widget ----------
  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 9, color: _grey)),
      ],
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB9BFCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: _blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _dark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.company,
                      style: const TextStyle(
                        color: _dark,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD5F7E3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'AKTIF',
                  style: TextStyle(
                    color: Color(0xFF4CCB84),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _infoItem(Icons.location_on_outlined, location),
              _infoItem(Icons.schedule_rounded, type),
            ],
          ),
          const SizedBox(height: 6),
          _infoItem(Icons.monetization_on_rounded, salary),
          const SizedBox(height: 6),
          _infoItem(Icons.people_alt_outlined, '$applicants Pelamar'),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? _blue : Colors.transparent,
                      width: 1.6,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: active ? _blue : _dark,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _dark,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Deskripsi Pekerjaan'),
        Text(
          description,
          style: const TextStyle(color: _dark, fontSize: 11, height: 1.5),
        ),
      ],
    );
  }

  Widget _qualificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Kualifikasi'),
        ...qualifications.map(
          (q) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(fontSize: 11, color: _grey)),
                Expanded(
                  child: Text(
                    q,
                    style: const TextStyle(
                      color: _grey,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _companySection() {
    Widget row(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 15, color: _blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: _dark, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Tentang Perusahaan'),
        row(Icons.business, widget.company),
        row(Icons.category_outlined, 'Teknologi informasi'),
        row(Icons.location_on_outlined, 'Malang, Jawa Timur'),
        row(Icons.mail_outline_rounded, 'hr@ptxyz.com'),
        row(Icons.language_rounded, 'www.ptxyz.com'),
      ],
    );
  }

  Widget _tabContent() {
    switch (selectedTab) {
      case 1:
        return _qualificationSection();
      case 2:
        return _companySection();
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _descriptionSection(),
            const SizedBox(height: 24),
            _qualificationSection(),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 21),
        ),
        title: const Text(
          'Detail Lowongan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerCard(),
                    const SizedBox(height: 16),
                    _tabBar(),
                    const SizedBox(height: 18),
                    _tabContent(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 6, 40, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      onPressed: _openApplicants,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _blue,
                        side: const BorderSide(color: _blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Lihat Pelamar [$applicants]',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _openApplicants,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Kelola Lowongan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}