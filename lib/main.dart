import 'package:flutter/material.dart';
import 'package:sprint/JobSeeker/splashScreen.dart';
import 'package:sprint/JobSeeker/login.dart';
import 'package:sprint/JobSeeker/signUp.dart';
import 'package:sprint/JobSeeker/onBoarding1.dart';
import 'package:sprint/JobSeeker/onBoarding2.dart';
import 'package:sprint/JobSeeker/onBoarding3.dart';
import 'package:sprint/JobSeeker/main_navigation.dart';
import 'package:sprint/JobSeeker/successScreen.dart'; // Sesuaikan foldermu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Splashscreen(), // Mengarahkan ke file induk navigasi
    );
  }
}