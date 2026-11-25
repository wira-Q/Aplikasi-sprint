import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/models/job_filter.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';

class FilterLowongan extends StatefulWidget {
  const FilterLowongan({super.key, this.initial = const JobFilter()});

  /// Filter yang sedang aktif di halaman pencarian.
  final JobFilter initial;

  @override
  State<FilterLowongan> createState() => _FilterLowonganState();
}

class _FilterLowonganState extends State<FilterLowongan> {
  late final TextEditingController _keywordController;

  // Filter utama: satu lokasi dan satu jenis pekerjaan (null = semua).
  String? _selectedLocation;
  String? _selectedJobType;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(
      text: widget.initial.keyword ?? '',
    );
    _selectedLocation = widget.initial.location;
    _selectedJobType = widget.initial.jobType;
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  // Fungsi untuk mereset form filter
  void _resetFilter() {
    setState(() {
      _keywordController.clear();
      _selectedLocation = null;
      _selectedJobType = null;
    });
  }

  void _apply() {
    final keyword = _keywordController.text.trim();
    Navigator.pop(
      context,
      JobFilter(
        keyword: keyword.isEmpty ? null : keyword,
        location: _selectedLocation,
        jobType: _selectedJobType,
      ),
    );
  }

  Widget _buildChips({
    required List<String> values,
    required String? selected,
    required String Function(String) label,
    required void Function(String?) onChanged,
    required Color primaryColor,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: values.map((value) {
        final isSelected = selected == value;
        return ChoiceChip(
          label: Text(label(value)),
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
            side: BorderSide(color: primaryColor, width: 1),
          ),
          onSelected: (isNowSelected) {
            setState(() => onChanged(isNowSelected ? value : null));
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(
      0xFF2862E8,
    ); // Warna biru tombol/tema

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
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _apply(),
                  decoration: InputDecoration(
                    hintText: 'Cari lowongan atau keahlian',
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

              // 3. LOKASI (satu pilihan)
              Text(
                'Lokasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildChips(
                values: JobOptions.locations,
                selected: _selectedLocation,
                label: (v) => v,
                onChanged: (v) => _selectedLocation = v,
                primaryColor: primaryColor,
              ),

              const SizedBox(height: 20),

              // 4. JENIS PEKERJAAN (satu pilihan)
              Text(
                'Jenis Pekerjaan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildChips(
                values: JobOptions.jobTypes,
                selected: _selectedJobType,
                label: JobTypeLabels.of,
                onChanged: (v) => _selectedJobType = v,
                primaryColor: primaryColor,
              ),

              const Spacer(),

              // 5. TOMBOL FILTER DI BAGIAN BAWAH
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _apply,
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
