import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../services/company_service.dart';
import '../../services/logo_service.dart';
import 'app_exception.dart';

class LogoDebugPage extends StatefulWidget {
  const LogoDebugPage({super.key});

  @override
  State<LogoDebugPage> createState() => _LogoDebugPageState();
}

class _LogoDebugPageState extends State<LogoDebugPage> {
  final _logos = LogoService();
  final _companies = CompanyService();

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
    final storage = SupabaseConfig.client.storage.from(LogoRules.bucket);
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
      appBar: AppBar(title: const Text('Uji Logo Perusahaan (sementara)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Recruiter'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Upload PNG uji (1x1)', () async {
                final c = await _logos.uploadLogo(_validPng());
                return 'Logo tersimpan.\nPath: ${c.logo}\n'
                    'URL: ${LogoService.publicUrl(c.logo)}';
              }, filled: true),
              _btn('Upload > 2 MB (harus ditolak)', () async {
                await _logos.uploadLogo(_fakePng(LogoRules.maxBytes + 1));
                return 'BAHAYA: file > 2 MB lolos validasi!';
              }),
              _btn('Upload bukan gambar (harus ditolak)', () async {
                await _logos.uploadLogo(
                  Uint8List.fromList('bukan gambar'.codeUnits),
                );
                return 'BAHAYA: file non-gambar lolos validasi!';
              }),
              _btn('Lihat logo saya', () async {
                final c = await _companies.getMyCompany();
                if (c == null) return 'Belum punya profil perusahaan.';
                if (c.logo == null) return 'Perusahaan belum punya logo.';
                return 'Path: ${c.logo}\nURL: ${LogoService.publicUrl(c.logo)}\n'
                    '(Salin URL, buka di tab baru tanpa login.)';
              }),
              _btn('Hapus logo', () async {
                final c = await _logos.removeLogo();
                return 'Logo dihapus. Kolom logo sekarang: ${c.logo ?? "(kosong)"}';
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
              _btn('Serang: upload ke folder sendiri (job seeker)', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                return _directUpload(
                  '$uid/serang_js.png',
                  _validPng(),
                  'image/png',
                );
              }),
              _btn('Serang: isi kolom logo dengan URL luar', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('companies')
                      .update({'logo': 'https://contoh-jahat.example/x.png'})
                      .eq('id_user', uid)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: kolom logo BERHASIL diisi URL luar!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(_output),
        ],
      ),
    );
  }
}
