import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sprint/JobSeeker/login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Controller Animasi (Durasi 1.5 detik agar smooth)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 2. Efek Transparansi (Fade In dari 0 ke 1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // 3. Efek Skala/Zoom (Dari agak kecil 0.8 ke ukuran normal 1.0)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    // Mulai jalankan animasi
    _controller.forward();

    // 4. Timer navigasi tetap 5 detik sesuai kode aslimu
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    });
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}