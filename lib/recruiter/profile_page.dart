import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/logout_helper.dart';
import 'package:sprint/core/widgets/company_logo.dart';
import 'package:sprint/models/company_model.dart';
import 'package:sprint/services/company_service.dart';
import 'package:sprint/services/logo_service.dart';

// Halaman Profil perusahaan (konten saja).
// Bottom navigation dipegang oleh DashboardPage.
class ProfilePage extends StatefulWidget {
  // Dipanggil saat tombol panah kembali ditekan (balik ke Home).
  final VoidCallback? onBack;

  const ProfilePage({super.key, this.onBack});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color bgBlue = Color(0xFF1C3B8B);

  final CompanyService _companies = CompanyService();
  final LogoService _logos = LogoService();
  final ImagePicker _picker = ImagePicker();

  CompanyModel? _company;
  bool _isLoading = true;
  bool _isUploadingLogo = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final company = await _companies.getMyCompany();
      if (company == null) {
        throw const AppException('Profil perusahaan belum dibuat.');
      }
      if (!mounted) return;
      setState(() {
        _company = company;
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
        _errorMessage = 'Gagal memuat profil. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Dialog logout "Already Leaving?" sesuai desain Figma
  void _confirmLogout() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF2D2D),
                  size: 52,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Already Leaving?',
                  style: TextStyle(
                    color: Color(0xFF17233D),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Are you sure that want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF17233D), fontSize: 11),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            // Keluar sungguhan, lalu ke halaman login bersama.
                            signOutAndGoToLogin(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4B4B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Yes, I want to logout',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B72B8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            "No, I'm Staying",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editProfile() async {
    final company = _company;
    if (company == null) return;
    final updated = await showDialog<CompanyModel>(
      context: context,
      builder: (_) => _EditCompanyDialog(company: company),
    );
    if (updated != null && mounted) {
      setState(() => _company = updated);
      _snack('Profil perusahaan diperbarui.');
    }
  }

  // ---------- logo ----------
  void _logoActions() {
    final hasLogo = _company?.logo != null && _company!.logo!.isNotEmpty;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(hasLogo ? 'Ganti logo' : 'Unggah logo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickLogo();
                },
              ),
              if (hasLogo)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Hapus logo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removeLogo();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickLogo() async {
    if (_isUploadingLogo) return;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();

      setState(() => _isUploadingLogo = true);
      final updated = await _logos.uploadLogo(bytes);
      if (!mounted) return;
      setState(() {
        _company = updated;
        _isUploadingLogo = false;
      });
      _snack('Logo diperbarui.');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingLogo = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingLogo = false);
      _snack('Gagal memilih atau mengunggah logo.');
    }
  }

  Future<void> _removeLogo() async {
    if (_isUploadingLogo) return;
    setState(() => _isUploadingLogo = true);
    try {
      final updated = await _logos.removeLogo();
      if (!mounted) return;
      setState(() {
        _company = updated;
        _isUploadingLogo = false;
      });
      _snack('Logo dihapus.');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingLogo = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingLogo = false);
      _snack('Gagal menghapus logo.');
    }
  }

  Widget _logo() {
    return GestureDetector(
      onTap: _company == null ? null : _logoActions,
      child: Stack(
        children: [
          _isUploadingLogo
              ? Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3858A2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : CompanyLogo(path: _company?.logo, size: 50, radius: 10),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 9, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _value(String? v) {
    if (_isLoading) return '...';
    final t = v?.trim();
    return (t == null || t.isEmpty) ? '-' : t;
  }

  Widget _companyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _logo(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _value(_company?.companyName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _value(_company?.industry),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: _editProfile,
              child: const Padding(
                padding: EdgeInsets.only(top: 28),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 6),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Colors.white.withOpacity(0.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _company;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgBlue,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: panah kembali + judul + tombol keluar
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 14, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Profil anda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _confirmLogout,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _companyCard(),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _load,
                        child: const Text(
                          'Coba lagi',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 22),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Informasi Perusahaan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _infoRow(
                      Icons.location_on_outlined,
                      'Lokasi',
                      _value(c?.location),
                    ),
                    _infoRow(
                      Icons.mail_outline_rounded,
                      'Email',
                      _value(c?.email),
                    ),
                    _infoRow(
                      Icons.language_rounded,
                      'Website',
                      _value(c?.website),
                    ),
                    _infoRow(
                      Icons.description_outlined,
                      'Deskripsi',
                      _value(c?.description),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog edit profil perusahaan. Mengembalikan data terbaru jika tersimpan.
class _EditCompanyDialog extends StatefulWidget {
  const _EditCompanyDialog({required this.company});

  final CompanyModel company;

  @override
  State<_EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<_EditCompanyDialog> {
  final CompanyService _service = CompanyService();

  late final TextEditingController _nameC;
  late final TextEditingController _industryC;
  late final TextEditingController _locationC;
  late final TextEditingController _emailC;
  late final TextEditingController _websiteC;
  late final TextEditingController _descC;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameC = TextEditingController(text: c.companyName);
    _industryC = TextEditingController(text: c.industry ?? '');
    _locationC = TextEditingController(text: c.location ?? '');
    _emailC = TextEditingController(text: c.email ?? '');
    _websiteC = TextEditingController(text: c.website ?? '');
    _descC = TextEditingController(text: c.description ?? '');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _industryC.dispose();
    _locationC.dispose();
    _emailC.dispose();
    _websiteC.dispose();
    _descC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_descC.text.trim().length > 500) {
      setState(() => _error = 'Deskripsi maksimal 500 karakter.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await _service.updateMyCompany(
        companyName: _nameC.text,
        industry: _industryC.text,
        location: _locationC.text,
        email: _emailC.text,
        website: _websiteC.text,
        description: _descC.text,
      );
      if (!mounted) return;
      Navigator.pop(context, updated);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _saving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan. Periksa koneksi Anda.';
        _saving = false;
      });
    }
  }

  Widget _field(String label, TextEditingController c, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        enabled: !_saving,
        maxLines: lines,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Nama Perusahaan', _nameC),
            _field('Bidang', _industryC),
            _field('Alamat lengkap', _locationC, lines: 2),
            _field('Email', _emailC),
            _field('Website (https://...)', _websiteC),
            _field('Deskripsi', _descC, lines: 3),
            if (_error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
