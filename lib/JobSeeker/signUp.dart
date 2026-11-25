import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/backend_validators.dart';
import 'package:sprint/models/user_model.dart';
import 'package:sprint/services/auth_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Mengatur apakah password utama terlihat atau tersembunyi
  bool _isPasswordVisible = false;

  // Mengatur apakah confirm password terlihat atau tersembunyi
  bool _isConfirmPasswordVisible = false;

  // Mengatur warna utama halaman
  final Color primaryColor = const Color(0xFF203F8B);

  final AuthService _auth = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  /// Role yang dipilih. Admin tidak bisa dipilih dari aplikasi.
  UserRole _role = UserRole.jobSeeker;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Mengembalikan pesan error, atau null jika semua isian valid.
  String? _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) return 'Username wajib diisi.';
    if (name.length > 100) return 'Username terlalu panjang.';
    if (email.isEmpty) return 'Email wajib diisi.';
    if (!BackendValidators.isValidEmail(email)) {
      return 'Format email tidak valid.';
    }
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (password != _confirmController.text) {
      return 'Konfirmasi password tidak sama.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    final error = _validate();
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _auth.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _role,
      );

      // Jika verifikasi email dimatikan, signUp langsung membuat session.
      // Keluarkan agar alurnya sama: pengguna login lewat halaman login.
      if (!result.needsEmailConfirmation) {
        try {
          await _auth.signOut();
        } catch (_) {}
      }

      if (!mounted) return;
      await _showSuccessDialog(
        email: _emailController.text.trim(),
        needsConfirmation: result.needsEmailConfirmation,
      );
      if (!mounted) return;
      Navigator.pop(context); // kembali ke halaman login
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

  Future<void> _showSuccessDialog({
    required String email,
    required bool needsConfirmation,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          needsConfirmation ? 'Cek email Anda' : 'Akun berhasil dibuat',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          needsConfirmation
              ? 'Kami mengirim email konfirmasi ke $email. Buka link di '
                    'email tersebut (cek folder Spam jika tidak ada), lalu '
                    'login.'
              : 'Silakan login dengan akun yang baru dibuat.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    double iconSize = 16,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
      prefixIcon: Icon(icon, size: iconSize, color: Colors.black),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  Widget _roleOption(UserRole role, String label, IconData icon) {
    final bool isSelected = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: _isLoading ? null : () => setState(() => _role = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? primaryColor : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER BIRU
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo aplikasi
                      Image.asset(
                        'assets/icon.png',
                        width: 85,
                        height: 100,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 15),

                      // Judul halaman
                      Text(
                        'Create Account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Deskripsi halaman
                      Text(
                        'Create a new account to get started\nand access our features',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // FORM SIGN UP BERWARNA PUTIH
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(36, 25, 36, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // PILIHAN ROLE
                      Text(
                        'Daftar sebagai',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _roleOption(
                            UserRole.jobSeeker,
                            'Job Seeker',
                            Icons.person_search_outlined,
                          ),
                          const SizedBox(width: 10),
                          _roleOption(
                            UserRole.recruiter,
                            'Recruiter',
                            Icons.business_center_outlined,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // INPUT USERNAME (disimpan sebagai nama profil)
                      Text(
                        'Username',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _nameController,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hint: 'Fill your username',
                          icon: Icons.person,
                          iconSize: 17,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // INPUT EMAIL
                      Text('Email', style: GoogleFonts.poppins(fontSize: 12)),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hint: 'Fill your email',
                          icon: Icons.email,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // INPUT PASSWORD
                      Text(
                        'Password',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _passwordController,
                        enabled: !_isLoading,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          hint: 'Enter your password',
                          icon: Icons.vpn_key,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // INPUT CONFIRM PASSWORD
                      Text(
                        'Confirm Password',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _confirmController,
                        enabled: !_isLoading,
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: _inputDecoration(
                          hint: 'Re-enter your password',
                          icon: Icons.vpn_key,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      // PESAN ERROR (hanya muncul jika ada)
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else
                        const SizedBox(height: 25),

                      // TOMBOL SIGN UP
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2862E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
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
                                  'Sign Up',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // LINK SIGN IN
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: GoogleFonts.poppins(fontSize: 10),
                            ),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      // Kembali ke halaman login
                                      Navigator.pop(context);
                                    },
                              child: Text(
                                'Sign In here',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
