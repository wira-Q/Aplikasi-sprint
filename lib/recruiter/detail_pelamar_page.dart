import 'package:flutter/material.dart';

// Halaman Detail Pelamar.
// Data pelamar dikirim dari Daftar Pelamar. Perubahan status (Tolak / Terima /
// pilih status) langsung mengubah data pelamar tersebut, sehingga di Daftar
// Pelamar statusnya ikut berubah.
class DetailPelamarPage extends StatefulWidget {
  final Map<String, dynamic> applicant;

  const DetailPelamarPage({super.key, required this.applicant});

  @override
  State<DetailPelamarPage> createState() => _DetailPelamarPageState();
}

class _DetailPelamarPageState extends State<DetailPelamarPage> {
  static const Color _blue = Color(0xFF2863E9);
  static const Color _dark = Color(0xFF17233D);

  static const List<String> _statuses = ['Diproses', 'Diterima', 'Ditolak'];

  // ---------- data ----------
  String _text(String key, String fallback) {
    final v = widget.applicant[key];
    if (v == null || v.toString().trim().isEmpty) return fallback;
    return v.toString();
  }

  String get name => _text('name', '-');
  String get position => _text('position', '-');
  String get school => _text('school', '-');
  String get major => _text('major', '-');
  String get location => _text('location', 'Malang');
  String get status => _text('status', 'Diproses');
  String get cvSize => _text('cvSize', '2,4 mb');
  String get cvName =>
      _text('cvName', '${name.toLowerCase().replaceAll(' ', ' ')} cv.pdf');

  List<String> get skills {
    final s = widget.applicant['skills'];
    if (s is List && s.isNotEmpty) return s.map((e) => e.toString()).toList();
    return ['Flutter', 'HTML', 'CSS'];
  }

  Color _statusTextColor(String s) {
    switch (s) {
      case 'Diterima':
        return const Color(0xFF159653);
      case 'Ditolak':
        return Colors.red;
      default:
        return _blue;
    }
  }

  // ---------- aksi ----------
  void _setStatus(String newStatus, {bool closePage = false}) {
    setState(() => widget.applicant['status'] = newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status $name diubah menjadi $newStatus'),
        duration: const Duration(seconds: 2),
      ),
    );

    if (closePage) Navigator.pop(context);
  }

  void _pickStatus() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              const Text(
                'Ubah Status Lamaran',
                style: TextStyle(
                  color: _dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ..._statuses.map((s) {
                final selected = s == status;
                return ListTile(
                  title: Text(
                    s,
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusTextColor(s),
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check, color: _blue, size: 18)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _setStatus(s);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showCv() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close, size: 20, color: _dark),
                ),
                const Text(
                  'CV pelamar',
                  style: TextStyle(
                    color: _dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFD9D9D9),
                    alignment: Alignment.center,
                    child: const Text(
                      'tampilan pdf cv',
                      style: TextStyle(fontSize: 9, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mengunduh $cvName ...')),
                    );
                  },
                  child: const Text(
                    'Download cv',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- widget ----------
  Widget _avatar() {
    final photo = widget.applicant['photo'];
    final Color color = widget.applicant['color'] is Color
        ? widget.applicant['color'] as Color
        : Colors.blueGrey;

    return ClipOval(
      child: SizedBox(
        width: 72,
        height: 72,
        child: photo == null
            ? _initialAvatar(color)
            : Image.asset(
                photo.toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _initialAvatar(color),
              ),
      ),
    );
  }

  Widget _initialAvatar(Color color) {
    final initial = _text('initial', name.isNotEmpty ? name[0] : '?');
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: _dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                position,
                style: const TextStyle(color: _dark, fontSize: 9),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  location,
                  style: const TextStyle(color: _dark, fontSize: 9),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.school_outlined, size: 12, color: _dark),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      '$school . $major',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _dark, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skillChips() {
    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: skills
            .map(
              (s) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _statusCard() {
    return GestureDetector(
      onTap: _pickStatus,
      child: Container(
        width: double.infinity,
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE3F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              status.toLowerCase(),
              style: TextStyle(
                color: _statusTextColor(status),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: _dark, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _cvCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E6EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CV pelamar...',
            style: TextStyle(
              color: _dark,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3ECFE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: _blue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cvName,
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                    Text(
                      cvSize,
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _showCv,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFFE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Lihat cv',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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
          'Detail Pelamar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(),
              const SizedBox(height: 14),
              _skillChips(),
              const SizedBox(height: 26),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Status lamaran',
                  style: TextStyle(
                    color: _dark,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _statusCard(),
              const SizedBox(height: 36),
              _cvCard(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    'Tolak',
                    const Color(0xFFFF7F87),
                    () => _setStatus('Ditolak', closePage: true),
                  ),
                  _actionButton(
                    'Terima',
                    _blue,
                    () => _setStatus('Diterima', closePage: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}