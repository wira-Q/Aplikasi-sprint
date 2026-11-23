import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filterLowongan.dart';
import 'detailLowongan.dart'; // <-- 1. Import halaman detail lowongan

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Data Dummy Lowongan
  final List _allJobs = [
    {
      'title': 'Backend Developer',
      'company': 'PT XYZ',
      'location': 'Malang',
      'type': 'Magang',
      'logo': 'assets/search.png', 
    },
    {
      'title': 'Frontend Developer',
      'company': 'PT ABC',
      'location': 'Jakarta',
      'type': 'Fulltime',
      'logo': 'assets/search.png',
    },
    {
      'title': 'UI/UX Designer',
      'company': 'PT Kreatif Digital',
      'location': 'Bandung',
      'type': 'Freelance',
      'logo': 'assets/search.png',
    },
    {
      'title': 'Data Scientist',
      'company': 'PT Data Indo',
      'location': 'Surabaya',
      'type': 'Magang',
      'logo': 'assets/search.png',
    },
  ];

  List _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _filteredJobs = _allJobs;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final title = job['title']!.toLowerCase();
        final company = job['company']!.toLowerCase();
        final location = job['location']!.toLowerCase();

        return title.contains(query) || company.contains(query) || location.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // 1. SEARCH BAR & FILTER BUTTON
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari HRD, Lowongan, atau Perusahaan',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: primaryColor,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FilterLowongan(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. LIST KARTU LOWONGAN (REAL-TIME)
              Expanded(
                child: _filteredJobs.isEmpty
                    ? Center(
                        child: Text(
                          'Lowongan tidak ditemukan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          // 2. Bungkus Container dengan GestureDetector agar bisa diklik
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DetailLowongan(), // Sesuaikan nama class jika berbeda
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        job['logo']!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: Center(
                                              child: Icon(
                                                Icons.business,
                                                color: primaryColor,
                                                size: 24,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job['title']!,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          job['company']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 13,
                                              color: Colors.grey.shade500,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              job['location']!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                job['type']!,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey.shade400,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}