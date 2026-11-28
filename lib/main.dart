import 'package:flutter/material.dart';
import 'package:sprint/JobSeeker/login.dart';
import 'package:sprint/JobSeeker/signUp.dart';
import 'package:sprint/JobSeeker/splashScreen.dart';
import 'core/utils/app_scroll_behavior.dart';
import 'config/supabase_config.dart';
import 'core/utils/applications_debug_page.dart';
import 'core/utils/auth_debug_page.dart';
import 'core/utils/avatar_debug_page.dart';
import 'core/utils/connection_tester.dart';
import 'core/utils/interviews_debug_page.dart';
import 'core/utils/jobs_debug_page.dart';
import 'core/utils/logo_debug_page.dart';
import 'core/utils/profile_debug_page.dart';
import 'recruiter/dasboard_page.dart';
import 'recruiter/onboarding1_page.dart';
import 'recruiter/onboarding2_page.dart';
import 'recruiter/onboarding3_page.dart';

/// Menu uji sementara hanya tampil jika dijalankan dengan:
/// flutter run --dart-define-from-file=env.json --dart-define=DEBUG_MENU=true
/// Hapus bagian ini saat penyambungan selesai.
const bool _showDebugMenu = String.fromEnvironment('DEBUG_MENU') == 'true';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    initError = e is StateError ? e.message : 'Gagal inisialisasi Supabase.';
  }

  runApp(SprintApp(initError: initError));
}

class SprintApp extends StatelessWidget {
  const SprintApp({super.key, this.initError});
  final String? initError;

  @override
  Widget build(BuildContext context) {
    final Widget home;
    if (initError != null) {
      home = _InitErrorPage(message: initError!);
    } else if (_showDebugMenu) {
      home = const _ConnectionTestPage();
    } else {
      home = const Splashscreen();
    }

    return MaterialApp(
      title: 'Sprint',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      home: home,
      // Rute bernama yang dipakai halaman recruiter (Navigator.pushNamed).
      // Login dan register diarahkan ke halaman bersama milik Feriska.
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const SignUp(),
        '/onboarding1': (context) => const Onboarding1Page(),
        '/onboarding2': (context) => const Onboarding2Page(),
        '/onboarding3': (context) => const Onboarding3Page(),
        '/dasboard': (context) => const DashboardPage(),
      },
    );
  }
}

class _InitErrorPage extends StatelessWidget {
  const _InitErrorPage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

// SEMENTARA: menu uji backend. Hapus saat penyambungan selesai.
class _ConnectionTestPage extends StatefulWidget {
  const _ConnectionTestPage();

  @override
  State<_ConnectionTestPage> createState() => _ConnectionTestPageState();
}

class _ConnectionTestPageState extends State<_ConnectionTestPage> {
  ConnectionTestResult? _result;
  bool _loading = false;

  Future<void> _runTest() async {
    setState(() => _loading = true);
    final result = await ConnectionTester.run();
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Widget _open(String label, Widget page) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: OutlinedButton(
      onPressed: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
      child: Text(label),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sprint - Menu Uji (sementara)')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FilledButton(
            onPressed: _loading ? null : _runTest,
            child: Text(_loading ? 'Menguji...' : 'Uji koneksi Supabase'),
          ),
          _open('Uji Auth (sementara)', const AuthDebugPage()),
          _open('Uji Company & Jobs (sementara)', const JobsDebugPage()),
          _open('Uji CV & Lamaran (sementara)', const ApplicationsDebugPage()),
          _open(
            'Uji Interview & Notifikasi (sementara)',
            const InterviewsDebugPage(),
          ),
          _open('Uji Logo Perusahaan (sementara)', const LogoDebugPage()),
          _open('Uji Foto Profil (sementara)', const AvatarDebugPage()),
          _open(
            'Uji Onboarding & Rekomendasi (sementara)',
            const ProfileDebugPage(),
          ),
          _open('Buka aplikasi (Splashscreen)', const Splashscreen()),
          const SizedBox(height: 16),
          if (_result != null) ...[
            Text(
              'Status: ${_result!.status.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(_result!.message),
          ],
        ],
      ),
    );
  }
}
