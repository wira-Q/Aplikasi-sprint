import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterLowongan extends StatefulWidget {
  const FilterLowongan({super.key});

  @override
  State<FilterLowongan> createState() => _FilterLowonganState();
}

class _FilterLowonganState extends State<FilterLowongan> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Menyimpan status pilihan kota / jenis pekerjaan yang sedang aktif
  String? _selectedLocationType = 'Malang'; 

  final List<String> _locations = ['Surabaya', 'Malang', 'Pasuruan'];

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Fungsi untuk mereset form filter
  void _resetFilter() {
    setState(() {
      _keywordController.clear();
      _locationController.clear();
      _selectedLocationType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF2862E8); // Warna biru tombol/tema

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (TOMBOL KEMBALI & JUDUL)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Pekerjaan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 2. KATA KUNCI & TOMBOL RESET
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kata kunci',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: _resetFilter,
                    child: Text(
                      'Reset',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    hintText: 'Cari HRD, Lowongan, atau Perusahaan',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. LOKASI
              Text(
                'Lokasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Semua Kota',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. JENIS PEKERJAAN (CHIP PILIHAN KOTA)
              Text(
                'Jenis Pekerjaan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _locations.map((loc) {
                  final isSelected = _selectedLocationType == loc;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(loc),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : primaryColor,
                      ),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: primaryColor,
                          width: 1,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedLocationType = selected ? loc : null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // 5. TOMBOL FILTER DI BAGIAN BAWAH
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Aksi ketika tombol FILTER ditekan (kembali ke halaman sebelumnya)
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'FILTER',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}