import 'package:supabase_flutter/supabase_flutter.dart';

/// Konfigurasi terpusat Supabase.
/// Nilai dibaca dari --dart-define-from-file=env.json, bukan dari source code.
class SupabaseConfig {
  SupabaseConfig._();

  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;

  /// Panggil satu kali di main() sebelum runApp().
  static Future<void> initialize() async {
    if (!isConfigured) {
      throw StateError(
        'SUPABASE_URL / SUPABASE_ANON_KEY belum diisi. '
        'Jalankan dengan: flutter run --dart-define-from-file=env.json',
      );
    }
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  /// Satu-satunya pintu akses client untuk seluruh service.
  static SupabaseClient get client => Supabase.instance.client;
}