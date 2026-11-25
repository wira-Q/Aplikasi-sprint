import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/JobSeeker/signUp.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/backend_validators.dart';
import 'package:sprint/routes/home_destination.dart';
import 'package:sprint/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Mengatur apakah password terlihat atau tersembunyi
  bool _isPasswordVisible = false;

  // Mengatur warna utama halaman
  final Color primaryColor = const Color(0xFF203F8B);

  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _needsConfirmation = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password wajib diisi.';
        _needsConfirmation = false;
      });
      return;
    }
    if (!BackendValidators.isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Format email tidak valid.';
        _needsConfirmation = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _needsConfirmation = false;
    });

    try {
      await _auth.signIn(email: email, password: password);

      final page = await resolveHomeDestination(
        loginBuilder: () => const Login(),
      );
      if (page == null) {
        // Akun ada tetapi profil tidak ada: jangan dibiarkan login.
        try {
          await _auth.signOut();
        } catch (_) {}
        throw const AppException(
          'Profil tidak ditemukan. Hubungi admin.',
          code: 'no_profile',
        );
      }

      if (!mounted) return;
      // Hapus seluruh riwayat halaman agar tombol kembali tidak membuka login.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => page),
        (route) => false,
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _needsConfirmation = e.code == 'email_not_confirmed';
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

  Future<void> _resendConfirmation() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _auth.resendConfirmationEmail(email);
      messenger.showSnackBar(
        const SnackBar(content: Text('Email konfirmasi dikirim ulang.')),
      );
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal mengirim ulang email.')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER BIRU
            Expanded(
              flex: 5,
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
                        'Login',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Deskripsi halaman
                      Text(
                        'Sign in to your account and explore\nour features',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // FORM LOGIN BERWARNA PUTIH
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(36, 35, 36, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),

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
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
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
                        if (_needsConfirmation)
                          GestureDetector(
                            onTap: _resendConfirmation,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Kirim ulang email konfirmasi',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                      ] else
                        const SizedBox(height: 35),

                      // TOMBOL LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2862E8),
                            foregroundColor: Colors.black,
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
                                  'Login',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // LINK SIGN UP
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.poppins(fontSize: 10),
                            ),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      // Navigasi ke halaman SignUp
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SignUp(),
                                        ),
                                      );
                                    },
                              child: Text(
                                'Sign Up here',
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
