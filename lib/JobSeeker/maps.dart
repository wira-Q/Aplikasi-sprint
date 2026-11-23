import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // Warna utama halaman (biru tua)
  final Color primaryColor = const Color(0xFF203F8B);

  // State untuk daftar kota yang dipilih (contoh awal: Surabaya dan Malang)
   List<String> _selectedCities = ['Surabaya', 'Malang'];

  // Daftar rekomendasi kota
  final List<String> _recommendationCities = ['Surabaya', 'Malang', 'Pasuruan'];

  // State untuk checkbox "Semua"
  bool _selectAll = false;

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
                  // Baris Atas: Tombol Kembali & Judul
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Temukan Loker di Lokasi Pilihanmu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari kota di indonesia',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Info Sisa Pilihan
                  Text(
                    'kamu bisa pilih 15 lagi!',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Chip Kota yang Dipilih (dengan tombol 'x')
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedCities.map((city) {
                      return Chip(
                        label: Text(
                          city,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        deleteIconColor: primaryColor,
                        onDeleted: () {
                          setState(() {
                            _selectedCities.remove(city);
                          });
                        },
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Deskripsi Bawah Header
                  Text(
                    'Temukan banyak pilihan daerah untuk lowongan kerja\ndiberbagai penjuru indonesia!',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // CONTAINER PUTIH BAWAH
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Rekomendasi Kota & Checkbox Semua
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rekomendasi Kota',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Semua',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            Checkbox(
                              value: _selectAll,
                              activeColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectAll = value ?? false;
                                  if (_selectAll) {
                                    _selectedCities = List.from(_recommendationCities);
                                  } else {
                                    _selectedCities.clear();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Daftar Tombol Pilihan Kota
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _recommendationCities.map((city) {
                        bool isSelected = _selectedCities.contains(city);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedCities.remove(city);
                                _selectAll = false;
                              } else {
                                _selectedCities.add(city);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.05)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                                width: isSelected ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              city,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const Spacer(),

                    // TOMBOL DONE
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lokasi berhasil dipilih!'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6E4FF), // Warna biru muda sesuai desain
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}