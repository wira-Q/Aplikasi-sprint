import 'package:flutter/material.dart';

import '../../config/supabase_config.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'app_exception.dart';

class AuthDebugPage extends StatefulWidget {
  const AuthDebugPage({super.key});

  @override
  State<AuthDebugPage> createState() => _AuthDebugPageState();
}

class _AuthDebugPageState extends State<AuthDebugPage> {
  final _auth = AuthService();
  final _users = UserService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.jobSeeker;
  String _output = 'Belum ada aksi.';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() => _busy = true);
    String result;
    try {
      result = await action();
    } on AppException catch (e) {
      result = 'GAGAL: ${e.message} (code: ${e.code})';
    } catch (e) {
      result = 'GAGAL tak terduga: ${e.runtimeType}';
    }
    if (!mounted) return;
    setState(() {
      _output = result;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uji Auth (sementara)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nama'),
          ),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          DropdownButton<UserRole>(
            value: _role,
            items: const [
              DropdownMenuItem(
                value: UserRole.jobSeeker,
                child: Text('job_seeker'),
              ),
              DropdownMenuItem(
                value: UserRole.recruiter,
                child: Text('recruiter'),
              ),
            ],
            onChanged: (v) => setState(() => _role = v ?? _role),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        final r = await _auth.signUp(
                          name: _name.text,
                          email: _email.text,
                          password: _password.text,
                          role: _role,
                        );
                        return 'Register OK. Perlu konfirmasi email: ${r.needsEmailConfirmation}';
                      }),
                child: const Text('Register'),
              ),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        await _auth.signIn(
                          email: _email.text,
                          password: _password.text,
                        );
                        return 'Login OK.';
                      }),
                child: const Text('Login'),
              ),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        final p = await _users.getCurrentProfile();
                        return p == null
                            ? 'Profil KOSONG (trigger belum jalan?)'
                            : 'Profil: ${p.name} | ${p.email} | role=${p.role.value}';
                      }),
                child: const Text('Profil saya'),
              ),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        await _auth.signOut();
                        return 'Logout OK. Session: ${_auth.hasValidSession}';
                      }),
                child: const Text('Logout'),
              ),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        await _auth.resendConfirmationEmail(_email.text);
                        return 'Email konfirmasi dikirim ulang.';
                      }),
                child: const Text('Kirim ulang email'),
              ),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        // Serangan sungguhan ke Supabase: mengubah role sendiri.
                        final uid = _auth.currentUser?.id;
                        if (uid == null) return 'Login dulu.';
                        try {
                          await SupabaseConfig.client
                              .from('users')
                              .update({'role': 'admin'})
                              .eq('id_user', uid);
                          return 'BAHAYA: update role BERHASIL (RLS/grant bocor!)';
                        } catch (e) {
                          return 'Aman: update role ditolak (${e.runtimeType}).';
                        }
                      }),
                child: const Text('Coba ubah role jadi admin'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(_output),
        ],
      ),
    );
  }
}
