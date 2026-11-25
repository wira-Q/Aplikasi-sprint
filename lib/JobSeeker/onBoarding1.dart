import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/services/user_service.dart';
import 'onBoarding2.dart';

class OnBoarding1 extends StatefulWidget {
  const OnBoarding1({super.key});

  @override
  State<OnBoarding1> createState() => _OnBoarding1State();
}

class _OnBoarding1State extends State<OnBoarding1> {
  // Mengatur warna utama halaman
  final Color primaryColor = const Color(0xFF203F8B);

  final UserService _users = UserService();

  // State untuk menyimpan pilihan jenis kelamin ('laki-laki' atau 'perempuan')
  String _selectedGender = 'laki-laki';

  // State untuk menyimpan tanggal lahir yang dipilih
  DateTime? _selectedDate;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _selectDate(BuildContext context) async {
    // Rentang usia 15 sampai 80 tahun, sama dengan aturan di database.
    final now = DateTime.now();
    final latest = DateTime(now.year - ProfileRules.minAge, now.month, now.day);
    final earliest = DateTime(
      now.year - ProfileRules.maxAge,
      now.month,
      now.day,
    );

    var initial = _selectedDate ?? DateTime(now.year - 25, now.month, now.day);
    if (initial.isAfter(latest)) initial = latest;
    if (initial.isBefore(earliest)) initial = earliest;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest,
      lastDate: latest,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _next() async {
    if (_isLoading) return;

    final date = _selectedDate;
    if (date == null) {
      setState(() => _errorMessage = 'Pilih tanggal lahir terlebih dahulu.');
      return;
    }
    final dateError = ProfileRules.validateBirthDate(date);
    if (dateError != null) {
      setState(() => _errorMessage = dateError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _users.updateProfile(
        birthDate: date,
        gender: _selectedGender == 'perempuan' ? 'Perempuan' : 'Laki-laki',
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Navigasi ke OnBoarding 2
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnBoarding2()),
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
                  // Tombol Kembali (hanya tampil jika ada halaman sebelumnya)
                  Navigator.canPop(context)
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        )
                      : const SizedBox(width: 48, height: 48),
                  // Indikator Halaman 01 / 03
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '01 / 03',
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

            // KONTEN HEADER (Ikon Roket & Teks)
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ikon Roket
                      const Icon(
                        Icons.rocket_launch_outlined,
                        size: 70,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 15),

                      // Judul
                      Text(
                        'Sedikit lagi!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Deskripsi
                      Text(
                        'Kami butuh beberapa informasi tambahan untuk\nrekomendasi lowongan yang lebih tepat untuk kamu.',
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
                      // LABEL TANGGAL LAHIR
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Tanggal Lahir',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // INPUT / DROPDOWN TANGGAL LAHIR
                      GestureDetector(
                        onTap: _isLoading ? null : () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Pilih tanggal lahirmu'
                                    : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _selectedDate == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // LABEL JENIS KELAMIN
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Jenis Kelamin',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // PILIHAN TOMBOL JENIS KELAMIN (Laki-laki / Perempuan)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedGender = 'laki-laki';
                                      });
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'laki-laki'
                                      ? primaryColor.withOpacity(0.05)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedGender == 'laki-laki'
                                        ? primaryColor
                                        : Colors.grey.shade300,
                                    width: _selectedGender == 'laki-laki'
                                        ? 1.5
                                        : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.male,
                                      color: _selectedGender == 'laki-laki'
                                          ? primaryColor
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Laki-laki',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _selectedGender == 'laki-laki'
                                            ? primaryColor
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedGender = 'perempuan';
                                      });
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'perempuan'
                                      ? primaryColor.withOpacity(0.05)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedGender == 'perempuan'
                                        ? primaryColor
                                        : Colors.grey.shade300,
                                    width: _selectedGender == 'perempuan'
                                        ? 1.5
                                        : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.female,
                                      color: _selectedGender == 'perempuan'
                                          ? primaryColor
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Perempuan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _selectedGender == 'perempuan'
                                            ? primaryColor
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
}
