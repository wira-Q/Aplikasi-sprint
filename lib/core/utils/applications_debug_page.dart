import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../models/application_model.dart';
import '../../models/cv_model.dart';
import '../../services/application_service.dart';
import '../../services/cv_service.dart';
import 'app_exception.dart';

class ApplicationsDebugPage extends StatefulWidget {
  const ApplicationsDebugPage({super.key});

  @override
  State<ApplicationsDebugPage> createState() => _ApplicationsDebugPageState();
}

class _ApplicationsDebugPageState extends State<ApplicationsDebugPage> {
  final _cvs = CvService();
  final _apps = ApplicationService();
  final _jobId = TextEditingController();
  final _cvId = TextEditingController();
  final _appId = TextEditingController();
  final _path = TextEditingController();
  final _message = TextEditingController(
    text: 'Saya tertarik dengan posisi ini.',
  );

  String _output = 'Belum ada aksi. Login dulu lewat halaman Uji Auth.';
  bool _busy = false;

  @override
  void dispose() {
    _jobId.dispose();
    _cvId.dispose();
    _appId.dispose();
    _path.dispose();
    _message.dispose();
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

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

  /// PDF uji: hanya berisi tanda awal %PDF- lalu byte kosong.
  Uint8List _pdfBytes(int size) {
    final header = '%PDF-1.4\n%uji sprint\n'.codeUnits;
    final bytes = Uint8List(size);
    bytes.setRange(0, header.length, header);
    return bytes;
  }

  String _fmtCv(CvModel c) =>
      '#${c.idCv} ${c.fileName} | ${c.fileSize ?? "-"} byte | ${c.filePath}';

  String _fmtApp(ApplicationModel a) =>
      '#${a.idApplication} job#${a.idJob} ${a.jobTitle ?? "-"} | ${a.status} '
      '| pelamar: ${a.applicantName ?? "-"} | CV: ${a.cvFileName ?? "-"}';

  /// Mengunggah langsung ke Storage, melewati validasi aplikasi.
  Future<String> _directUpload(
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    final storage = SupabaseConfig.client.storage.from(CvRules.bucket);
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
      appBar: AppBar(title: const Text('Uji CV & Lamaran (sementara)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _jobId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID lowongan'),
          ),
          TextField(
            controller: _cvId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID CV'),
          ),
          TextField(
            controller: _appId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID lamaran'),
          ),
          TextField(
            controller: _path,
            decoration: const InputDecoration(
              labelText: 'Path file CV (untuk uji akses)',
            ),
          ),
          TextField(
            controller: _message,
            decoration: const InputDecoration(labelText: 'Pesan lamaran'),
          ),
          _section('CV (job seeker)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Upload PDF uji (1 KB)', () async {
                final cv = await _cvs.uploadCv(
                  bytes: _pdfBytes(1024),
                  fileName: 'cv_uji.pdf',
                );
                _cvId.text = '${cv.idCv}';
                _path.text = cv.filePath;
                return 'CV tersimpan: ${_fmtCv(cv)}';
              }, filled: true),
              _btn('Upload > 5 MB (harus ditolak)', () async {
                await _cvs.uploadCv(
                  bytes: _pdfBytes(CvRules.maxBytes + 1),
                  fileName: 'besar.pdf',
                );
                return 'BAHAYA: file > 5 MB lolos validasi!';
              }),
              _btn('Upload bukan PDF (harus ditolak)', () async {
                await _cvs.uploadCv(
                  bytes: Uint8List.fromList('bukan pdf'.codeUnits),
                  fileName: 'catatan.txt',
                );
                return 'BAHAYA: file non-PDF lolos validasi!';
              }),
              _btn('Daftar CV saya', () async {
                final list = await _cvs.getMyCvs();
                return 'CV saya (${list.length}):\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmtCv).join("\n")}';
              }),
              _btn('Signed URL (CV target)', () async {
                final id = _int(_cvId);
                if (id == null) return 'Isi ID CV dulu.';
                final url = await _cvs.createSignedUrl(id);
                final shown = url.length > 60
                    ? '${url.substring(0, 60)}...'
                    : url;
                return 'Signed URL dibuat (berlaku ${CvRules.signedUrlSeconds} '
                    'detik, ${url.length} karakter):\n$shown';
              }),
              _btn('Unduh file (path target)', () async {
                final path = _path.text.trim();
                if (path.isEmpty) return 'Isi path file dulu.';
                try {
                  final bytes = await SupabaseConfig.client.storage
                      .from(CvRules.bucket)
                      .download(path);
                  final isPdf =
                      bytes.length >= 5 &&
                      bytes[0] == 0x25 &&
                      bytes[1] == 0x50 &&
                      bytes[2] == 0x44 &&
                      bytes[3] == 0x46;
                  return 'TERUNDUH: ${bytes.length} byte, PDF: $isPdf';
                } catch (e) {
                  return 'DITOLAK/GAGAL: ${e.runtimeType}';
                }
              }),
              _btn('Hapus CV (target)', () async {
                final id = _int(_cvId);
                if (id == null) return 'Isi ID CV dulu.';
                await _cvs.deleteCv(id);
                return 'CV #$id dihapus.';
              }),
            ],
          ),
          _section('Lamaran'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Lamar (lowongan + CV target)', () async {
                final j = _int(_jobId);
                final c = _int(_cvId);
                if (j == null || c == null) return 'Isi ID lowongan dan ID CV.';
                final a = await _apps.apply(
                  idJob: j,
                  idCv: c,
                  message: _message.text,
                );
                _appId.text = '${a.idApplication}';
                return 'Lamaran terkirim: ${_fmtApp(a)}';
              }, filled: true),
              _btn('Lamaran saya', () async {
                final list = await _apps.getMyApplications();
                return 'Lamaran saya (${list.length}):\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmtApp).join("\n")}';
              }),
              _btn('Pelamar (recruiter)', () async {
                final list = await _apps.getApplicants(idJob: _int(_jobId));
                return 'Pelamar (${list.length}):\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmtApp).join("\n")}';
              }),
              for (final s in [
                ApplicationStatus.interview,
                ApplicationStatus.diterima,
                ApplicationStatus.ditolak,
              ])
                _btn('Status -> $s', () async {
                  final id = _int(_appId);
                  if (id == null) return 'Isi ID lamaran dulu.';
                  final a = await _apps.updateStatus(id, s);
                  return 'Status diubah: ${_fmtApp(a)}';
                }),
            ],
          ),
          _section('Serangan (hasil yang benar: "Aman")'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Serang: upload 6 MB langsung', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                return _directUpload(
                  '$uid/serang_besar.pdf',
                  _pdfBytes(6 * 1024 * 1024),
                  CvRules.mimeType,
                );
              }),
              _btn('Serang: upload text/plain langsung', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                return _directUpload(
                  '$uid/serang_teks.pdf',
                  Uint8List.fromList('teks biasa'.codeUnits),
                  'text/plain',
                );
              }),
              _btn('Serang: upload ke folder user lain', () async {
                return _directUpload(
                  '00000000-0000-0000-0000-000000000000/serang.pdf',
                  _pdfBytes(1024),
                  CvRules.mimeType,
                );
              }),
              _btn('Serang: ubah status lamaran sendiri', () async {
                final id = _int(_appId);
                if (id == null) return 'Isi ID lamaran dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('applications')
                      .update({'status': 'Diterima'})
                      .eq('id_application', id)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: status lamaran BERHASIL diubah!';
                } catch (e) {
                  return 'Aman: ditolak (${e.runtimeType}).';
                }
              }),
              _btn('Serang: lamar dengan status Diterima', () async {
                final j = _int(_jobId);
                final c = _int(_cvId);
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (j == null || c == null || uid == null) {
                  return 'Isi ID lowongan, ID CV, dan login dulu.';
                }
                try {
                  await SupabaseConfig.client.from('applications').insert({
                    'id_job': j,
                    'id_user': uid,
                    'id_cv': c,
                    'status': 'Diterima',
                  });
                  return 'BAHAYA: lamaran dengan status Diterima TERSIMPAN!';
                } catch (e) {
                  return 'Aman: ditolak (${e.runtimeType}).';
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
