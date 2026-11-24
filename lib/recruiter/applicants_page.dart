import 'package:flutter/material.dart';

import 'detail_pelamar_page.dart';

// Halaman Daftar Pelamar (konten saja).
// Bottom navigation dipegang oleh DasboardPage.
class ApplicantsPage extends StatefulWidget {
  // Dipanggil saat tombol panah kembali ditekan (balik ke Home).
  final VoidCallback? onBack;

  const ApplicantsPage({super.key, this.onBack});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  static const Color blue = Color(0xFF2454D3);
  static const Color textDark = Color(0xFF17233D);

  String selectedFilter = 'Semua';

  // Taruh foto di assets/images/ lalu daftarkan di pubspec.yaml.
  // Kalau foto belum ada, otomatis tampil inisial.
  final List<Map<String, dynamic>> applicants = [
    {
      'name': 'Wisnu Nugroho',
      'position': 'Backend developer',
      'school': 'SMKN 8 Malang',
      'major': 'RPL',
      'status': 'Diproses',
      'date': 'Sunday, 20 Sept 2026',
      'time': '13.55 WIB',
      'photo': 'assets/images/wisnu.jpg',
      'initial': 'W',
      'color': Colors.brown,
    },
    {
      'name': 'Dinda Kirana',
      'position': 'Frontend developer',
      'school': 'Universitas Bali',
      'major': 'Teknik Informatika',
      'status': 'Diterima',
      'date': '21 Sept 2026,',
      'time': '11.15 WIB',
      'photo': 'assets/images/dinda.jpg',
      'initial': 'D',
      'color': Colors.pink,
    },
    {
      'name': 'Claudia Tiara',
      'position': 'Frontend developer',
      'school': 'SMKN 1 Bandung',
      'major': 'RPL',
      'status': 'Ditolak',
      'date': 'Sunday, 20 Sept 2026',
      'time': '10.55 WIB',
      'photo': 'assets/images/claudia.jpg',
      'initial': 'C',
      'color': Colors.blueGrey,
    },
  ];

  List<Map<String, dynamic>> get filteredApplicants {
    if (selectedFilter == 'Semua') return applicants;
    return applicants.where((a) => a['status'] == selectedFilter).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Diproses':
        return const Color(0xFFCFE0FF);
      case 'Diterima':
        return const Color(0xFFC9F5DB);
      case 'Ditolak':
        return const Color(0xFFFFD0D4);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Diproses':
        return blue;
      case 'Diterima':
        return const Color(0xFF159653);
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _filterButton(String title) {
    final isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? blue : const Color(0xFFE8ECF3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _avatar(Map<String, dynamic> applicant) {
    return ClipOval(
      child: SizedBox(
        width: 48,
        height: 48,
        child: Image.asset(
          applicant['photo'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: applicant['color'],
              alignment: Alignment.center,
              child: Text(
                applicant['initial'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Buka Detail Pelamar, lalu refresh daftar (status bisa berubah)
  Future<void> _openDetail(Map<String, dynamic> applicant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPelamarPage(applicant: applicant),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _applicantCard(Map<String, dynamic> applicant) {
    final String status = applicant['status'];

    return GestureDetector(
      onTap: () => _openDetail(applicant),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7EAF0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _avatar(applicant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applicant['name'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  applicant['position'],
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 12,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        applicant['school'],
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        '•',
                        style: TextStyle(fontSize: 9, color: Colors.black54),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        applicant['major'],
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 8,
                      color: _statusTextColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chevron_right, size: 20, color: Colors.black87),
              const SizedBox(height: 14),
              Text(
                applicant['date'],
                style: const TextStyle(fontSize: 7, color: Colors.grey),
              ),
              if ((applicant['time'] as String).isNotEmpty)
                Text(
                  applicant['time'],
                  style: const TextStyle(fontSize: 7, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: panah kembali + judul
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              const Text(
                'Daftar Pelamar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _filterButton('Semua'),
              _filterButton('Diproses'),
              _filterButton('Diterima'),
              _filterButton('Ditolak'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: filteredApplicants.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada pelamar',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredApplicants.length,
                  itemBuilder: (context, index) {
                    return _applicantCard(filteredApplicants[index]);
                  },
                ),
        ),
      ],
    );
  }
}