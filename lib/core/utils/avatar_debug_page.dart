import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../services/avatar_service.dart';
import '../../services/user_service.dart';
import 'app_exception.dart';

class AvatarDebugPage extends StatefulWidget {
  const AvatarDebugPage({super.key});

  @override
  State<AvatarDebugPage> createState() => _AvatarDebugPageState();
}

class _AvatarDebugPageState extends State<AvatarDebugPage> {
  final _avatars = AvatarService();
  final _users = UserService();
  final _path = TextEditingController();

  String _output = 'Belum ada aksi. Login dulu lewat halaman Uji Auth.';
  bool _busy = false;

  // PNG valid 1x1 piksel.
  static const String _pngBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

  Uint8List _validPng() => base64Decode(_pngBase64);

  /// Berisi tanda awal PNG lalu byte kosong, hanya untuk uji ukuran.
  Uint8List _fakePng(int size) {
    final bytes = Uint8List(size);
    bytes.setRange(0, 8, [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    return bytes;
  }

  @override
  void dispose() {
    _path.dispose();
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

  String _errCode(Object e) =>
      e is PostgrestException ? 'kode ${e.code}' : e.runtimeType.toString();

  /// Mengunggah langsung ke Storage, melewati validasi aplikasi.
  Future<String> _directUpload(
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    final storage = SupabaseConfig.client.storage.from(AvatarRules.bucket);
    try {
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: contentType, upsert: false),
      );
    } catch (e) {
      return 'Aman: ditolak server (${e.runtimeType}).';
    }
    try {
      await storage.remove([path]);
    } catch (_) {}
    return 'BAHAYA: upload langsung BERHASIL (aturan bucket/policy bocor!)';
  }

  /// Mengisi kolom photo langsung, melewati service.
  Future<String> _directPhotoUpdate(String value) async {
    final uid = SupabaseConfig.client.auth.currentUser?.id;
    if (uid == null) return 'Login dulu.';
    try {
      final res = await SupabaseConfig.client
          .from('users')
          .update({'photo': value})
          .eq('id_user', uid)
          .select();
      return res.isEmpty
          ? 'Aman: tidak ada baris yang berubah.'
          : 'BAHAYA: kolom photo BERHASIL diisi nilai tidak sah! '
                'Kosongkan lewat SQL Editor.';
    } catch (e) {
      return 'Aman: ditolak (${_errCode(e)}).';
    }
  }

  Widget _btn(
    String label,
    Future<String> Function() action, {
    bool filled = false,
  }) {
    final onPressed = _busy ? null : () => _run(action);
    return filled
        ? FilledButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uji Foto Profil (sementara)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _path,
            decoration: const InputDecoration(
              labelText: 'Path foto (untuk uji akses)',
            ),
          ),
          _section('Job seeker'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Upload PNG uji (1x1)', () async {
                final u = await _avatars.uploadPhoto(_validPng());
                _path.text = u.photo ?? '';
                return 'Foto tersimpan.\nPath: ${u.photo}';
              }, filled: true),
              _btn('Upload > 2 MB (harus ditolak)', () async {
                await _avatars.uploadPhoto(_fakePng(AvatarRules.maxBytes + 1));
                return 'BAHAYA: file > 2 MB lolos validasi!';
              }),
              _btn('Upload bukan gambar (harus ditolak)', () async {
                await _avatars.uploadPhoto(
                  Uint8List.fromList('bukan gambar'.codeUnits),
                );
                return 'BAHAYA: file non-gambar lolos validasi!';
              }),
              _btn('Lihat foto saya (signed URL)', () async {
                final p = await _users.getCurrentProfile();
                if (p == null) return 'Profil tidak ditemukan.';
                if (p.photo == null) return 'Belum punya foto.';
                _path.text = p.photo!;
                final url = await _avatars.signedUrl(p.photo);
                return url == null
                    ? 'Gagal membuat signed URL.'
                    : 'Path: ${p.photo}\nSigned URL (salin, buka di tab baru):\n$url';
              }),
              _btn('URL publik tanpa token (harus gagal dibuka)', () async {
                final p = await _users.getCurrentProfile();
                if (p?.photo == null) return 'Upload foto dulu.';
                final url = SupabaseConfig.client.storage
                    .from(AvatarRules.bucket)
                    .getPublicUrl(p!.photo!);
                return 'Salin URL ini dan buka di tab baru. Hasil yang benar: '
                    'pesan error, BUKAN gambar.\n$url';
              }),
              _btn('Hapus foto', () async {
                final u = await _avatars.removePhoto();
                return 'Foto dihapus. Kolom photo sekarang: ${u.photo ?? "(kosong)"}';
              }),
            ],
          ),
          _section('Uji akses (isi kolom path dulu)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Unduh file (path target)', () async {
                final path = _path.text.trim();
                if (path.isEmpty) return 'Isi path foto dulu.';
                try {
                  final bytes = await SupabaseConfig.client.storage
                      .from(AvatarRules.bucket)
                      .download(path);
                  return 'TERUNDUH: ${bytes.length} byte';
                } catch (e) {
                  return 'DITOLAK/GAGAL: ${e.runtimeType}';
                }
              }),
            ],
          ),
          _section('Serangan (hasil yang benar: "Aman")'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Serang: upload > 2 MB langsung', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                return _directUpload(
                  '$uid/serang_besar.png',
                  _fakePng(3 * 1024 * 1024),
                  'image/png',
                );
              }),
              _btn('Serang: upload text/plain langsung', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                return _directUpload(
                  '$uid/serang_teks.png',
                  Uint8List.fromList('teks biasa'.codeUnits),
                  'text/plain',
                );
              }),
              _btn('Serang: upload ke folder user lain', () async {
                return _directUpload(
                  '00000000-0000-0000-0000-000000000000/serang.png',
                  _validPng(),
                  'image/png',
                );
              }),
              _btn(
                'Serang: upload ke folder sendiri (untuk recruiter)',
                () async {
                  final uid = SupabaseConfig.client.auth.currentUser?.id;
                  if (uid == null) return 'Login dulu.';
                  return _directUpload(
                    '$uid/serang_recruiter.png',
                    _validPng(),
                    'image/png',
                  );
                },
              ),
              _btn(
                'Serang: isi kolom photo dengan URL luar',
                () => _directPhotoUpdate('https://contoh-jahat.example/x.png'),
              ),
              _btn(
                'Serang: isi kolom photo dengan folder user lain',
                () => _directPhotoUpdate(
                  '00000000-0000-0000-0000-000000000000/x.png',
                ),
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
