import 'dart:typed_data';

/// Isian onboarding perusahaan yang ditahan di memori sampai halaman 3,
/// lalu dikirim sekaligus ke CompanyService dan LogoService.
class CompanyOnboardingDraft {
  CompanyOnboardingDraft._();

  static String name = '';
  static String? industry;
  static Uint8List? logoBytes;
  static String? logoName;
  static String? city;
  static String address = '';
  static String? workSystem;

  /// Dibersihkan setelah tersimpan atau saat onboarding diulang dari awal.
  static void clear() {
    name = '';
    industry = null;
    logoBytes = null;
    logoName = null;
    city = null;
    address = '';
    workSystem = null;
  }
}
