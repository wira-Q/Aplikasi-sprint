import 'package:flutter/material.dart';
import 'package:sprint/models/job_model.dart';
import 'package:sprint/models/profile_options.dart';

import 'detail_tambahan_page.dart';
import 'job_draft.dart';
import 'recruiter_theme.dart';

class BuatLowonganPage extends StatefulWidget {
  const BuatLowonganPage({super.key});

  @override
  State<BuatLowonganPage> createState() => _BuatLowonganPageState();
}

class _BuatLowonganPageState extends State<BuatLowonganPage> {
  static const int _maxSkills = 15;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();

  final List<String> _skills = [];

  String? _pendidikan;
  String? _pengalaman;
  String? _lokasi;
  String? _errorMessage;

  static const List<String> _pengalamanList = [
    'Fresh Graduate',
    'Kurang dari 1 tahun',
    '1 - 2 tahun',
    '3 - 5 tahun',
    'Lebih dari 5 tahun',
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    // Koma dipakai sebagai pemisah di database, jadi diganti spasi.
    final skill = _skillController.text.replaceAll(',', ' ').trim();
    if (skill.isEmpty) return;
    if (skill.length > 40) {
      setState(() => _errorMessage = 'Nama skill maksimal 40 karakter.');
      return;
    }
    if (_skills.length >= _maxSkills) {
      setState(() => _errorMessage = 'Maksimal $_maxSkills skill.');
      return;
    }
    if (_skills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
      _skillController.clear();
      return;
    }
    setState(() {
      _skills.add(skill);
      _skillController.clear();
      _errorMessage = null;
    });
  }

  // LANJUT KE HALAMAN DETAIL TAMBAHAN
  void _lanjutkan() {
    if (!_formKey.currentState!.validate()) return;
    if (_pendidikan == null || _pengalaman == null || _lokasi == null) {
      setState(() => _errorMessage = 'Lengkapi semua isian bertanda *.');
      return;
    }
    setState(() => _errorMessage = null);

    final draft = JobDraft(
      title: _judulController.text.trim(),
      description: _deskripsiController.text.trim(),
      skills: List<String>.from(_skills),
      education: _pendidikan!,
      experience: _pengalaman!,
      location: _lokasi!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailTambahanPage(draft: draft)),
    );
  }

  Widget _label(String tulisan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFF263247),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(text: tulisan),
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFFAAAAAA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: primaryBlue, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    String Function(String)? labelOf,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFAAAAAA)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: textGrey),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  hint,
                  style: const TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 11,
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(labelOf == null ? item : labelOf(item)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 19),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Buat Lowongan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF202020),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Judul posisi'),
                      TextFormField(
                        controller: _judulController,
                        maxLength: 150,
                        style: const TextStyle(fontSize: 11),
                        decoration: _inputDecoration(
                          'Masukkan judul posisi',
                        ).copyWith(counterText: ''),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul posisi wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      _label('Deskripsi Pekerjaan'),
                      TextFormField(
                        controller: _deskripsiController,
                        maxLines: 4,
                        maxLength: 1000,
                        style: const TextStyle(fontSize: 11),
                        decoration:
                            _inputDecoration(
                              'Masukkan deskripsi pekerjaan',
                            ).copyWith(
                              counterStyle: const TextStyle(
                                fontSize: 8,
                                color: Colors.grey,
                              ),
                            ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Deskripsi pekerjaan wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 5),

                      _label('Skill yang dibutuhkan'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _skillController,
                              style: const TextStyle(fontSize: 11),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addSkill(),
                              decoration: _inputDecoration('Contoh: Flutter'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _addSkill,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 7,
                        children: [
                          ..._skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 5,
                                top: 5,
                                bottom: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCE7FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    skill,
                                    style: const TextStyle(
                                      color: Color(0xFF2454D3),
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _skills.remove(skill));
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Color(0xFF2454D3),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 13),

                      _label('Pendidikan Minimum'),
                      _dropdown(
                        hint: 'Pilih pendidikan minimum',
                        value: _pendidikan,
                        items: EducationOptions.values,
                        icon: Icons.school_outlined,
                        onChanged: (value) {
                          setState(() {
                            _pendidikan = value;
                            _errorMessage = null;
                          });
                        },
                      ),

                      const SizedBox(height: 13),

                      _label('Pengalaman'),
                      _dropdown(
                        hint: 'Pilih pengalaman',
                        value: _pengalaman,
                        items: _pengalamanList,
                        icon: Icons.work_outline,
                        onChanged: (value) {
                          setState(() {
                            _pengalaman = value;
                            _errorMessage = null;
                          });
                        },
                      ),

                      const SizedBox(height: 13),

                      _label('Lokasi'),
                      _dropdown(
                        hint: 'Pilih kota',
                        value: _lokasi,
                        items: JobOptions.locations,
                        icon: Icons.location_on_outlined,
                        onChanged: (value) {
                          setState(() {
                            _lokasi = value;
                            _errorMessage = null;
                          });
                        },
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                      ],

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _lanjutkan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lanjutkan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 9),
                        Icon(Icons.arrow_forward, size: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
