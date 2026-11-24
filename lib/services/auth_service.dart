import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../models/user_model.dart';

class SignUpResult {
  const SignUpResult({required this.needsEmailConfirmation});

  /// true = pengguna harus membuka email konfirmasi dulu (belum ada session).
  final bool needsEmailConfirmation;
}

class AuthService {
  AuthService({SupabaseClient? client})
    : _auth = (client ?? SupabaseConfig.client).auth;

  final GoTrueClient _auth;

  User? get currentUser => _auth.currentUser;
  Session? get currentSession => _auth.currentSession;
  bool get hasValidSession =>
      currentSession != null && !currentSession!.isExpired;

  /// Dengarkan untuk mendeteksi login, logout, dan session berakhir.
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// gender dan education hanya dikirim untuk role job_seeker.
  /// Untuk recruiter, keduanya diabaikan walaupun diisi.
  Future<SignUpResult> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? gender,
    String? phone,
    String? location,
    String? education,
    String? emailRedirectTo,
  }) async {
    if (role == UserRole.admin) {
      throw const AppException('Peran tidak valid untuk pendaftaran.');
    }
    final isJobSeeker = role == UserRole.jobSeeker;
    try {
      final res = await _auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: emailRedirectTo,
        data: {
          'name': name.trim(),
          'role': role.value,
          if (isJobSeeker && gender != null) 'gender': gender,
          if (phone != null) 'phone': phone,
          if (location != null) 'location': location,
          if (isJobSeeker && education != null) 'education': education,
        },
      );
      final user = res.user;
      if (user == null) {
        throw const AppException('Pendaftaran gagal. Silakan coba lagi.');
      }
      // Dengan verifikasi email aktif, email yang sudah terdaftar tidak
      // melempar error; Supabase mengembalikan user tanpa identities.
      if (user.identities != null && user.identities!.isEmpty) {
        throw const AppException(
          'Email sudah terdaftar.',
          code: 'email_exists',
        );
      }
      return SignUpResult(needsEmailConfirmation: res.session == null);
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      _log('signUp error: ${e.runtimeType}');
      throw const AppException(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
        code: 'network',
      );
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      final res = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const AppException('Login gagal. Silakan coba lagi.');
      }
      return user;
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      _log('signIn error: ${e.runtimeType}');
      throw const AppException(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
        code: 'network',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      _log('signOut error: ${e.runtimeType}');
      throw const AppException('Logout gagal. Silakan coba lagi.');
    }
  }

  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _auth.resend(type: OtpType.signup, email: email.trim());
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      _log('resend error: ${e.runtimeType}');
      throw const AppException('Gagal mengirim ulang email konfirmasi.');
    }
  }

  AppException _mapAuthError(AuthException e) {
    final code = e.code ?? '';
    final msg = e.message.toLowerCase();
    _log('AuthException code=$code status=${e.statusCode}');

    if (code == 'email_not_confirmed' || msg.contains('not confirmed')) {
      return const AppException(
        'Email belum diverifikasi. Cek kotak masuk Anda.',
        code: 'email_not_confirmed',
      );
    }
    if (code == 'invalid_credentials' || msg.contains('invalid login')) {
      return const AppException(
        'Email atau password salah.',
        code: 'invalid_credentials',
      );
    }
    if (code == 'user_already_exists' || msg.contains('already registered')) {
      return const AppException('Email sudah terdaftar.', code: 'email_exists');
    }
    if (code == 'weak_password' || msg.contains('password should')) {
      return const AppException(
        'Password terlalu lemah. Gunakan minimal 6 karakter.',
      );
    }
    if (code == 'email_address_invalid' || msg.contains('invalid email')) {
      return const AppException('Format email tidak valid.');
    }
    if (code.contains('rate_limit') || msg.contains('rate limit')) {
      return const AppException(
        'Terlalu banyak percobaan. Tunggu beberapa saat lalu coba lagi.',
        code: 'rate_limit',
      );
    }
    if (msg.contains('database error')) {
      return const AppException(
        'Pendaftaran tidak dapat diproses. Hubungi admin.',
        code: 'profile_failed',
      );
    }
    if (code == 'session_expired' || msg.contains('refresh token')) {
      return const AppException(
        'Sesi berakhir. Silakan login kembali.',
        code: 'session_expired',
      );
    }
    return const AppException('Terjadi kesalahan autentikasi. Coba lagi.');
  }

  void _log(String text) {
    if (kDebugMode) debugPrint('[AuthService] $text');
  }
}
