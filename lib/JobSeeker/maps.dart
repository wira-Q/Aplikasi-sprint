import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/services/user_service.dart';

/// Pilihan kota untuk rekomendasi di dashboard. Hasilnya disimpan di profil
/// (preferred_locations). Mengembalikan true jika berhasil disimpan.
class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // Warna utama halaman (biru tua)
  final Color primaryColor = const Color(0xFF203F8B);

  final UserService _users = UserService();
  final TextEditingController _searchController = TextEditingController();

  // Daftar kota yang tersedia (sama dengan aturan di database)
  final List<String> _recommendationCities = JobOptions.locations;

  // State untuk daftar kota yang dipilih
  List<String> _selectedCities = [];

  String _query = '';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  int get _maxCities => _recommendationCities.length;
  bool get _allSelected =>
      _selectedCities.length == _recommendationCities.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final profile = await _users.getCurrentProfile();
      if (!mounted) return;
      setState(() {
        _selectedCities = (profile?.preferredLocations ?? const <String>[])
            .where(_recommendationCities.contains)
            .toList();
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat pilihan kota. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving || _isLoading) return;
    if (_selectedCities.isEmpty) {
      setState(() => _errorMessage = 'Pilih minimal satu kota.');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await _users.updatePreferences(locations: _selectedCities);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Lokasi berhasil dipilih!')),
      );
      Navigator.pop(context, true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Periksa koneksi Anda.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleCities = _recommendationCities
        .where((c) => c.toLowerCase().contains(_query.toLowerCase().trim()))
        .toList();
    final remaining = _maxCities - _selectedCities.length;

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

                  // Search Bar (menyaring daftar kota di bawah)
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Cari kota',
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
                    remaining > 0
                        ? 'kamu bisa pilih $remaining lagi!'
                        : 'semua kota sudah dipilih',
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
                        onDeleted: _isSaving
                            ? null
                            : () {
                                setState(() {
                                  _selectedCities.remove(city);
                                  _errorMessage = null;
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
                    'Lowongan saat ini tersedia di Malang, Surabaya,\ndan Pasuruan. Pilihanmu dipakai untuk rekomendasi di beranda.',
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
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
                                    value: _allSelected,
                                    activeColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: _isSaving
                                        ? null
                                        : (bool? value) {
                                            setState(() {
                                              _selectedCities = (value ?? false)
                                                  ? List.of(
                                                      _recommendationCities,
                                                    )
                                                  : <String>[];
                                              _errorMessage = null;
                                            });
                                          },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Daftar Tombol Pilihan Kota
                          if (visibleCities.isEmpty)
                            Text(
                              'Kota tidak ditemukan. Saat ini tersedia '
                              '${_recommendationCities.join(', ')}.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: visibleCities.map((city) {
                                bool isSelected = _selectedCities.contains(
                                  city,
                                );
                                return GestureDetector(
                                  onTap: _isSaving
                                      ? null
                                      : () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedCities.remove(city);
                                            } else {
                                              _selectedCities.add(city);
                                            }
                                            _errorMessage = null;
                                          });
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
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

                          // PESAN ERROR (hanya muncul jika ada)
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ],

                          const Spacer(),

                          // TOMBOL DONE
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD6E4FF),
                                foregroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
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
