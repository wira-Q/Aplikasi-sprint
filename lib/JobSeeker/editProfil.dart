import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/models/profile_options.dart';
import 'package:sprint/models/user_model.dart';
import 'package:sprint/services/avatar_service.dart';
import 'package:sprint/services/user_service.dart';

class EditProfil extends StatefulWidget {
  const EditProfil({super.key});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  final UserService _users = UserService();
  final AvatarService _avatars = AvatarService();
  final ImagePicker _picker = ImagePicker();

  // Controller untuk setiap form input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Variabel pilihan Gender dan Pendidikan
  String? _selectedGender;
  final List<String> _genderOptions = ['Perempuan', 'Laki-laki'];
  String? _selectedEducation;

  DateTime? _birthDate;
  UserModel? _profile;
  String? _photoUrl;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _loadError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day}, ${_months[d.month - 1]} ${d.year}';

  bool _sameDay(DateTime? a, DateTime? b) =>
      a != null &&
      b != null &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final profile = await _users.getCurrentProfile();
      if (profile == null) {
        throw const AppException('Profil tidak ditemukan.');
      }
      final photoUrl = await _avatars.signedUrl(profile.photo);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _photoUrl = photoUrl;
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        _phoneController.text = profile.phone ?? '';
        _addressController.text = profile.location ?? '';
        _birthDate = profile.birthDate;
        _dateController.text = profile.birthDate == null
            ? ''
            : _formatDate(profile.birthDate!);
        _selectedGender = _genderOptions.contains(profile.gender)
            ? profile.gender
            : null;
        _selectedEducation = EducationOptions.isValid(profile.education)
            ? profile.education
            : null;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Gagal memuat profil. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk memilih tanggal lahir interaktif (usia 15 sampai 80 tahun)
  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final latest = DateTime(now.year - ProfileRules.minAge, now.month, now.day);
    final earliest = DateTime(
      now.year - ProfileRules.maxAge,
      now.month,
      now.day,
    );

    var initial = _birthDate ?? DateTime(now.year - 25, now.month, now.day);
    if (initial.isAfter(latest)) initial = latest;
    if (initial.isBefore(earliest)) initial = earliest;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: earliest,
      lastDate: latest,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dateController.text = _formatDate(picked);
        _formError = null;
      });
    }
  }

  Future<void> _pickPhoto() async {
    if (_isUploadingPhoto || _isSaving) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();

      setState(() => _isUploadingPhoto = true);
      final updated = await _avatars.uploadPhoto(bytes);
      final url = await _avatars.signedUrl(updated.photo);
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _photoUrl = url;
        _isUploadingPhoto = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Foto profil diperbarui.')),
      );
    } on AppException catch (e) {
      if (mounted) setState(() => _isUploadingPhoto = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) setState(() => _isUploadingPhoto = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal memilih atau mengunggah foto.')),
      );
    }
  }

  /// Mengembalikan pesan error, atau null jika semua isian valid.
  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'Nama wajib diisi.';
    if (_nameController.text.trim().length > 100) {
      return 'Nama terlalu panjang.';
    }
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty && !RegExp(r'^\+?[0-9\s\-]{8,20}$').hasMatch(phone)) {
      return 'Nomor telepon tidak valid.';
    }
    if (_addressController.text.trim().length > 200) {
      return 'Alamat terlalu panjang.';
    }
    final date = _birthDate;
    if (date != null && !_sameDay(date, _profile?.birthDate)) {
      return ProfileRules.validateBirthDate(date);
    }
    return null;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final error = _validate();
    if (error != null) {
      setState(() => _formError = error);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isSaving = true;
      _formError = null;
    });
    try {
      await _users.updateProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        location: _addressController.text,
        education: _selectedEducation,
        gender: _selectedGender,
        // Hanya dikirim jika diubah, agar data lama tidak ditolak aturan usia.
        birthDate:
            (_birthDate != null && !_sameDay(_birthDate, _profile?.birthDate))
            ? _birthDate
            : null,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
      Navigator.pop(context);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = e.message;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _formError = 'Terjadi kesalahan. Periksa koneksi Anda.';
        _isSaving = false;
      });
    }
  }

  Widget _buildPhoto() {
    Widget fallback() => Image.asset(
      'assets/profil.png', // Foto bawaan jika belum ada foto
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade300,
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        );
      },
    );
    final url = _photoUrl;
    if (url == null) return fallback();
    return Image.network(
      url,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF203F8B);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // BAGIAN ATAS: App Bar (Back & Title & Check Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Tombol Simpan (Centang)
                  _isSaving
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: (_isLoading || _profile == null)
                              ? null
                              : _save,
                        ),
                ],
              ),
            ),

            // FOTO PROFIL & KETERANGAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: _isUploadingPhoto
                              ? Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.white24,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : _buildPhoto(),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubah Data?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ubah data diri mu sebaik dan sedetail mungkin dengan 100% data diri asli!',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KONTEN UTAMA: KOTAK FORM PUTIH DENGAN SUDUT MELENGKUNG
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _buildForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Name
          _buildInputField(
            label: 'Name',
            controller: _nameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          // 2. Email (hanya tampil, tidak bisa diubah)
          _buildInputField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // 3. Telephone
          _buildInputField(
            label: 'Telephone',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // 4. Date (Tanggal Lahir dengan DatePicker)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Pilih tanggal lahir',
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.blue.shade100,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF203F8B),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Address
          _buildInputField(
            label: 'Address',
            controller: _addressController,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),

          // 6. Pendidikan (dropdown dari daftar tetap)
          _buildDropdown(
            label: 'Pendidikan',
            value: _selectedEducation,
            hint: 'Pilih pendidikan terakhir',
            options: EducationOptions.values,
            onChanged: (v) => setState(() => _selectedEducation = v),
          ),
          const SizedBox(height: 16),

          // 7. Gender (Dropdown)
          _buildDropdown(
            label: 'Gender',
            value: _selectedGender,
            hint: 'Pilih jenis kelamin',
            options: _genderOptions,
            onChanged: (v) => setState(() => _selectedGender = v),
          ),

          // PESAN ERROR (hanya muncul jika ada)
          if (_formError != null) ...[
            const SizedBox(height: 16),
            Text(
              _formError!,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget helper untuk dropdown
  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue.shade100, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: options.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _isSaving ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Widget helper untuk merapikan text field input
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          enabled: !_isSaving,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: readOnly ? Colors.grey.shade600 : Colors.black87,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.blue.shade100, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF203F8B),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
