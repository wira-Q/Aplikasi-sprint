import 'package:flutter/material.dart';

import 'config/supabase_config.dart';
import 'core/utils/auth_debug_page.dart';
import 'core/utils/connection_tester.dart';

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
    return MaterialApp(
      title: 'Sprint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: _ConnectionTestPage(initError: initError),
    );
  }
}

// SEMENTARA (FASE 1-2): akan digantikan splash/login page.
class _ConnectionTestPage extends StatefulWidget {
  const _ConnectionTestPage({this.initError});
  final String? initError;

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

  @override
  Widget build(BuildContext context) {
    final error = widget.initError;
    return Scaffold(
      appBar: AppBar(title: const Text('Sprint - Uji Koneksi')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: error != null
            ? Text(error, style: const TextStyle(color: Colors.red))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton(
                    onPressed: _loading ? null : _runTest,
                    child: Text(
                      _loading ? 'Menguji...' : 'Uji koneksi Supabase',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthDebugPage()),
                    ),
                    child: const Text('Uji Auth (sementara)'),
                  ),
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
      ),
    );
  }
}
