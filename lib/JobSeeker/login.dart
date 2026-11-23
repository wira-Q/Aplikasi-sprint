
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/JobSeeker/signUp.dart';
import 'onBoarding1.dart';

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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),

                      // INPUT USERNAME
                      Text(
                        'Username',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),

                      const SizedBox(height: 5),

                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Fill your username',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            size: 17,
                            color: Colors.black,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
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
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // INPUT EMAIL
                      Text(
                        'Email',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),

                      const SizedBox(height: 5),

                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Fill your email',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            size: 16,
                            color: Colors.black,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
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
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
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
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(
                            Icons.vpn_key,
                            size: 16,
                            color: Colors.black,
                          ),
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
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
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // TOMBOL LOGIN
                     SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigasi ke halaman OnBoarding1
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnBoarding1(), // Pastikan nama class-nya sesuai
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2862E8),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
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
                              onTap: () {
                                // Navigasi ke halaman SignUp
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUp(), // Ganti dengan nama class SignUp Anda
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
