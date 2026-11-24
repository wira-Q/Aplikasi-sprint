import 'package:flutter/material.dart';

import 'recruiter/splash_screen.dart';
import 'recruiter/login_page.dart';
import 'recruiter/register_page.dart';
import 'recruiter/onboarding1_page.dart';
import 'recruiter/onboarding2_page.dart';
import 'recruiter/onboarding3_page.dart';
import 'recruiter/dasboard_page.dart';

void main() {
  runApp(const RecruiterApp());
}

class RecruiterApp extends StatelessWidget {
  const RecruiterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Step',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF243F8F),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF243F8F),
        ),
      ),

      home: const SplashScreen(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/onboarding1': (context) => const Onboarding1Page(),
        '/onboarding2': (context) => const Onboarding2Page(),
        '/onboarding3':(context) => const Onboarding3Page(),
        '/dasboard':(context) => const DashboardPage(),
      },
    );
  }
}