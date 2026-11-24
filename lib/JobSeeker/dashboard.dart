import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'maps.dart';
import 'detailLowongan.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();

  // 1. Pindahkan data lowongan ke dalam List agar mudah difilter
  final List _allJobs = [
    {
      'title': 'AI Engineering',
      'salary': 'Rp 1–1,2jt/bulan',
      'company': 'DB Klik',
      'location': 'Surabaya, Jawa Timur',
      'status': 'Aktif',
      'tags': ['Magang', '<1 Tahun', 'S1', 'Acara kantor & tim', 'Uang makan', 'Jenjang karir'],
      'companyLogo': 'assets/p1.png',
    },
    {
      'title': 'IT Programmer - Odoo',
      'salary': 'Rp 6–8jt/bulan',
      'company': 'PT Arina Multikarya',
      'location': 'Surabaya, Jawa Timur',
      'status': 'Online 7m lalu',
      'tags': ['Kontrak', '1–3 thn', 'S1', 'Uang Transport', 'Bonus Kinerja', 'Komisi Penjualan', 'BPJS Tenaga Kerja', 'BPJS Kesehatan'],
      'companyLogo': 'assets/p2.png',
    },
    {
      'title': 'Magang Programmer / Software Developer Intern',
      'salary': '',
      'company': 'PT QLCOM Solusi Bisnis',
      'location': 'Surabaya, Jawa Timur',
      'status': 'Online 4jm lalu',
      'tags': ['Magang', '1–3 thn', 'D1–D4', 'Makan Gratis'],
      'companyLogo': 'assets/p3.png',
    },
  ];

  // List penampung hasil filter
  List _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    // Awal buka halaman, tampilkan semua lowongan
    _filteredJobs = _allJobs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 2. Fungsi untuk memfilter lowongan berdasarkan kata kunci
  void _filterJobs(String query) {
    final keyword = query.toLowerCase().trim();

    setState(() {
      if (keyword.isEmpty) {
        _filteredJobs = _allJobs;
      } else {
        _filteredJobs = _allJobs.where((job) {
          final titleMatch = job['title'].toString().toLowerCase().contains(keyword);
          final companyMatch = job['company'].toString().toLowerCase().contains(keyword);
          final tagsMatch = (job['tags'] as List<String>).any(
            (tag) => tag.toLowerCase().contains(keyword),
          );

          return titleMatch || companyMatch || tagsMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BAGIAN HEADER (SAPAAN & IKON LOKASI)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Halo, hildan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapsPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. SEARCH BAR DENGAN FILTER REAL-TIME
              TextField(
                controller: _searchController,
                onChanged: _filterJobs, // Memanggil fungsi filter setiap kali mengetik
                decoration: InputDecoration(
                  hintText: 'Cari HRD, Lowongan, atau Perusahaan',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  // Tombol hapus (X) muncul otomatis saat kolom pencarian terisi
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filterJobs('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  filled: true,
                  fillColor: const Color(0xFFF0F4FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. JUDUL REKOMENDASI
              Text(
                'Rekomendasi untuk mu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // 4. KARTU DAFTAR LOWONGAN (DINAMIS SESUAI HASIL FILTER)
              if (_filteredJobs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Lowongan tidak ditemukan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredJobs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final job = _filteredJobs[index];
                    return _buildJobCard(
                      context: context,
                      title: job['title'],
                      salary: job['salary'],
                      company: job['company'],
                      location: job['location'],
                      status: job['status'],
                      tags: List<String>.from(job['tags']),
                      companyLogo: job['companyLogo'],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk membuat Card Lowongan Kerja
  Widget _buildJobCard({
    required BuildContext context,
    required String title,
    required String salary,
    required String company,
    required String location,
    required String status,
    required List<String> tags,
    required String companyLogo,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DetailLowongan(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (salary.isNotEmpty)
                  Text(
                    salary,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2862E8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.business_center_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      company,
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                Text(
                  location,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset(
                  companyLogo,
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.business, size: 16, color: Colors.grey);
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  company,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Premium',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  $status',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}