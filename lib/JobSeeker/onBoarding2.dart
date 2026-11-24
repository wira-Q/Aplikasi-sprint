import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onBoarding3.dart';
class OnBoarding2 extends StatefulWidget {
  const OnBoarding2({super.key});

  @override
  State<OnBoarding2> createState() => _OnBoarding2State();
}

class _OnBoarding2State extends State<OnBoarding2> {
  // Mengatur warna utama halaman
  final Color primaryColor = const Color(0xFF203F8B);

  // State untuk menyimpan pilihan pendidikan terakhir
  String? _selectedEducation;
  
  // Daftar pilihan pendidikan terakhir
  final List<String> _educationList = [
    'SMA / SMK sederajat',
    'Diploma (D3 / D4)',
    'Sarjana (S1)',
    'Magister (S2)',
    'Lainnya'
  ];

  // State untuk menyimpan jenis pekerjaan yang dipilih (bisa multiple atau single, contoh kali ini single/multiple selection)
  final Set<String> _selectedJobTypes = {'Part-time'};

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Kembali
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Indikator Halaman 02 / 03
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '02 / 03',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 24,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 12,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // KONTEN HEADER (Ikon Toga & Teks)
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ikon Topi Toga / Pendidikan
                      const Icon(
                        Icons.school_outlined,
                        size: 70,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 15),

                      // Judul
                      Text(
                        'Pendidikan & Pekerjaan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Deskripsi
                      Text(
                        'Tentukan latar belakang pendidikan dan jenis pekerjaan\nyang kamu cari.',
                        textAlign: TextAlign.center,
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
            ),

            // CONTAINER FORM PUTIH
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LABEL PENDIDIKAN TERAKHIR
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.menu_book_outlined,
                                size: 16, color: primaryColor),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Pendidikan Terakhir',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // DROPDOWN PENDIDIKAN TERAKHIR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedEducation,
                            hint: Text(
                              'Pilih pendidikan terakhir',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey, size: 20),
                            isExpanded: true,
                            items: _educationList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedEducation = newValue;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // LABEL JENIS PEKERJAAN
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.work_outline,
                                size: 16, color: primaryColor),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Jenis Pekerjaan',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // PILIHAN TOMBOL JENIS PEKERJAAN (Part-time, Magang, Kontrak)
                      Row(
                        children: [
                          _buildJobTypeChip('Part-time', Icons.work_outline),
                          const SizedBox(width: 8),
                          _buildJobTypeChip('Magang', Icons.person_outline),
                          const SizedBox(width: 8),
                          _buildJobTypeChip('Kontrak', Icons.description_outlined),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // TOMBOL LANJUTKAN
                    // TOMBOL LANJUTKAN
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigasi ke OnBoarding 2
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnBoarding3(), // Pastikan nama class-nya sesuai
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2862E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Lanjutkan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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

  // Widget helper untuk membuat chip pilihan jenis pekerjaan
  Widget _buildJobTypeChip(String title, IconData icon) {
    bool isSelected = _selectedJobTypes.contains(title);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedJobTypes.remove(title);
            } else {
              _selectedJobTypes.add(title);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.05) : Colors.transparent,
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}