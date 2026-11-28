import 'package:flutter/material.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/services/auth_service.dart';

/// Keluar dari akun, lalu kembali ke halaman login bersama (rute '/login'
/// di main.dart) dengan semua riwayat halaman dihapus. Jika keluar gagal,
/// pengguna tetap di halaman ini dan melihat pesan error.
Future<void> signOutAndGoToLogin(BuildContext context) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await AuthService().signOut();
  } on AppException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return;
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Logout gagal. Silakan coba lagi.')),
    );
    return;
  }
  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
}
