import 'package:flutter/material.dart';
import 'package:sprint/JobSeeker/main_navigation.dart';
import 'package:sprint/JobSeeker/onBoarding1.dart';
import 'package:sprint/models/user_model.dart';
import 'package:sprint/recruiter/dasboard_page.dart';
import 'package:sprint/recruiter/onboarding1_page.dart';
import 'package:sprint/recruiter/onboarding_draft.dart';
import 'package:sprint/services/auth_service.dart';
import 'package:sprint/services/company_service.dart';
import 'package:sprint/services/user_service.dart';

/// Menentukan halaman beranda untuk pengguna yang SUDAH login.
/// Role SELALU dibaca dari database, bukan dari data di perangkat.
/// Mengembalikan null jika profil tidak ditemukan (pemanggil harus
/// mengeluarkan akun dan kembali ke login).
///
/// [loginBuilder] dipakai halaman "belum tersedia" untuk kembali ke login.
/// Dikirim sebagai parameter agar file ini tidak saling mengimpor dengan
/// halaman login.
Future<Widget?> resolveHomeDestination({
  required Widget Function() loginBuilder,
  UserService? userService,
  CompanyService? companyService,
}) async {
  final profile = await (userService ?? UserService()).getCurrentProfile();
  if (profile == null) return null;

  switch (profile.role) {
    case UserRole.jobSeeker:
      return profile.isJobSeekerOnboardingComplete
          ? const MainNavigation()
          : const OnBoarding1();
    case UserRole.recruiter:
      // Recruiter yang sudah punya perusahaan langsung ke dashboard.
      // Yang belum, mengisi onboarding perusahaan dari halaman 1.
      final company = await (companyService ?? CompanyService()).getMyCompany();
      if (company != null) return const DashboardPage();
      CompanyOnboardingDraft.clear();
      return const Onboarding1Page();
    case UserRole.admin:
      return RoleNotReadyPage(
        message: 'Akun admin tidak memakai aplikasi ini.',
        loginBuilder: loginBuilder,
      );
  }
}

/// Halaman sementara untuk role yang tidak punya tampilan di aplikasi ini.
class RoleNotReadyPage extends StatelessWidget {
  const RoleNotReadyPage({
    super.key,
    required this.message,
    required this.loginBuilder,
  });

  final String message;
  final Widget Function() loginBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await AuthService().signOut();
                  } catch (_) {
                    // Tetap kembali ke login walaupun keluar gagal.
                  }
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => loginBuilder()),
                    (route) => false,
                  );
                },
                child: const Text('Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
