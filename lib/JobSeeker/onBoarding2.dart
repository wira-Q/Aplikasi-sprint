import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/services/user_service.dart';
import 'onBoarding3.dart';

class OnBoarding2 extends StatefulWidget {
  const OnBoarding2({super.key});

  @override
  State<OnBoarding2> createState() => _OnBoarding2State();
}

class _OnBoarding2State extends State<OnBoarding2> {
  // Mengatur warna utama halaman
  final Color primaryColor = const Color(0xFF203F8B);

  final UserService _users = UserService();

  // State untuk menyimpan pilihan pendidikan terakhir
  String? _selectedEducation;

  // Daftar pilihan pendidikan terakhir (sama dengan aturan di database)
  final List<String> _educationList = EducationOptions.values;

  // State untuk menyimpan jenis pekerjaan yang dipilih (boleh lebih dari satu).
  // Nilainya HARUS nilai database: Full-time, Part-time, Internship, Freelance.
  final Set<String> _selectedJobTypes = {'Part-time'};

  bool _isLoading = false;
  String? _errorMessage;

  IconData _iconFor(String jobType) {
    switch (jobType) {
      case 'Part-time':
        return Icons.work_outline;
      case 'Internship':
        return Icons.person_outline;
      case 'Freelance':
        return Icons.description_outlined;
      default:
        return Icons.business_center_outlined;
    }
  }

  Future<void> _next() async {
    if (_isLoading) return;

    final education = _selectedEducation;
    if (education == null) {
      setState(
        () => _errorMessage = 'Pilih pendidikan terakhir terlebih dahulu.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _users.updateProfile(education: education);
      await _users.updatePreferences(jobTypes: _selectedJobTypes.toList());
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Navigasi ke OnBoarding 3
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnBoarding3()),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                            child: Icon(
                              Icons.menu_book_outlined,
                              size: 16,
                              color: primaryColor,
                            ),
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
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                              size: 20,
                            ),
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
                            onChanged: _isLoading
                                ? null
                                : (String? newValue) {
                                    setState(() {
                                      _selectedEducation = newValue;
                                      _errorMessage = null;
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
                            child: Icon(
                              Icons.work_outline,
                              size: 16,
                              color: primaryColor,
                            ),
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

                      // PILIHAN JENIS PEKERJAAN (mengikuti daftar database)
                      Row(
                        children: [
                          for (
                            var i = 0;
                            i < JobOptions.jobTypes.length;
                            i++
                          ) ...[
                            if (i > 0) const SizedBox(width: 8),
                            _buildJobTypeChip(JobOptions.jobTypes[i]),
                          ],
                        ],
                      ),

                      // PESAN ERROR (hanya muncul jika ada)
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ] else
                        const SizedBox(height: 30),

                      // TOMBOL LANJUTKAN
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2862E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
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

  // Widget helper untuk membuat chip pilihan jenis pekerjaan.
  // [value] adalah nilai database; yang tampil adalah labelnya
  // (Internship tampil sebagai "Magang").
  Widget _buildJobTypeChip(String value) {
    final bool isSelected = _selectedJobTypes.contains(value);
    return Expanded(
      child: GestureDetector(
        onTap: _isLoading
            ? null
            : () {
                setState(() {
                  if (isSelected) {
                    _selectedJobTypes.remove(value);
                  } else {
                    _selectedJobTypes.add(value);
                  }
                });
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.05)
                : Colors.transparent,
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
                _iconFor(value),
                color: isSelected ? primaryColor : Colors.grey,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                JobTypeLabels.of(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
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
