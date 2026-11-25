import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sprint/JobSeeker/login.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/routes/home_destination.dart';
import 'package:sprint/services/auth_service.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  /// Lama minimal splash tampil (sama seperti kode asli: 5 detik).
  static const Duration _minimumDisplay = Duration(seconds: 5);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final AuthService _auth = AuthService();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Controller Animasi (Durasi 1.5 detik agar smooth)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 2. Efek Transparansi (Fade In dari 0 ke 1)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // 3. Efek Skala/Zoom (Dari agak kecil 0.8 ke ukuran normal 1.0)
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Mulai jalankan animasi
    _controller.forward();

    // 4. Cek session dan tentukan halaman tujuan
    _goToNextPage();
  }

  /// Menunggu animasi (minimal 5 detik) sambil memeriksa session.
  Future<void> _goToNextPage() async {
    if (mounted) setState(() => _errorMessage = null);
    final minimumDelay = Future<void>.delayed(_minimumDisplay);

    Widget page;
    try {
      page = await _resolveDestination();
    } on AppException catch (e) {
      await minimumDelay;
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
      return;
    } catch (_) {
      await minimumDelay;
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Terjadi kesalahan. Periksa koneksi Anda.',
      );
      return;
    }

    await minimumDelay;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// - tanpa session        -> Login
  /// - ada session          -> ditentukan resolveHomeDestination (role)
  /// - profil tidak ada     -> keluarkan akun, lalu Login
  Future<Widget> _resolveDestination() async {
    if (_auth.currentSession == null) return const Login();

    final page = await resolveHomeDestination(
      loginBuilder: () => const Login(),
    );
    if (page == null) {
      try {
        await _auth.signOut();
      } catch (_) {
        // Tetap lanjut ke login walaupun keluar gagal.
      }
      return const Login();
    }
    return page;
  }

  Future<void> _signOutAndGoToLogin() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Tetap lanjut ke login walaupun keluar gagal.
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Wajib di-dispose untuk mencegah memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        // Menerapkan animasi Fade & Scale pada konten tanpa mengubah desain
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 5),
                const Text(
                  "Career Step",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Hanya muncul jika pemeriksaan session gagal.
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _goToNextPage,
                    child: const Text(
                      'Coba lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _signOutAndGoToLogin,
                    child: const Text(
                      'Masuk ulang',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
