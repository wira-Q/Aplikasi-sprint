import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../models/interview_model.dart';
import '../../models/notification_model.dart';
import '../../services/interview_service.dart';
import '../../services/notification_service.dart';
import 'app_exception.dart';

class InterviewsDebugPage extends StatefulWidget {
  const InterviewsDebugPage({super.key});

  @override
  State<InterviewsDebugPage> createState() => _InterviewsDebugPageState();
}

class _InterviewsDebugPageState extends State<InterviewsDebugPage> {
  final _interviews = InterviewService();
  final _notifs = NotificationService();
  final _appId = TextEditingController();
  final _interviewId = TextEditingController();
  final _notifId = TextEditingController();
  final _link = TextEditingController(
    text: 'https://meet.google.com/abc-defg-hij',
  );
  final _notes = TextEditingController(
    text: 'Interview teknis via Google Meet.',
  );

  String _output = 'Belum ada aksi. Login dulu lewat halaman Uji Auth.';
  bool _busy = false;

  @override
  void dispose() {
    _appId.dispose();
    _interviewId.dispose();
    _notifId.dispose();
    _link.dispose();
    _notes.dispose();
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  DateTime _inDays(int days) => DateTime.now().add(Duration(days: days));

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

  String _fmtI(InterviewModel i) =>
      '#${i.idInterview} lamaran#${i.idApplication} | ${i.interviewDate} | '
      '${i.status} | ${i.meetingLink} | ${i.jobTitle ?? "-"} | '
      'pelamar: ${i.applicantName ?? "-"}';

  String _fmtN(NotificationModel n) =>
      '#${n.idNotification} [${n.isRead ? "dibaca" : "BARU"}] ${n.title} '
      '- ${n.message}';

  String _errCode(Object e) =>
      e is PostgrestException ? 'kode ${e.code}' : e.runtimeType.toString();

  /// Insert langsung ke tabel, melewati validasi aplikasi.
  Future<String> _directInsert({
    required int appId,
    required String link,
    required DateTime date,
  }) async {
    try {
      final res = await SupabaseConfig.client.from('interviews').insert({
        'id_application': appId,
        'interview_date': date.toUtc().toIso8601String(),
        'meeting_link': link,
      }).select();
      if (res.isEmpty) return 'Aman: tidak ada baris tersimpan.';
      return 'BAHAYA: interview TERSIMPAN (#${res.first['id_interview']})! '
          'Bersihkan lewat SQL Editor.';
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
      appBar: AppBar(
        title: const Text('Uji Interview & Notifikasi (sementara)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _appId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID lamaran'),
          ),
          TextField(
            controller: _interviewId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID interview'),
          ),
          TextField(
            controller: _notifId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID notifikasi'),
          ),
          TextField(
            controller: _link,
            decoration: const InputDecoration(labelText: 'Link meeting'),
          ),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Catatan'),
          ),
          _section('Recruiter'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Jadwalkan (besok)', () async {
                final a = _int(_appId);
                if (a == null) return 'Isi ID lamaran dulu.';
                final i = await _interviews.schedule(
                  idApplication: a,
                  dateTime: _inDays(1),
                  meetingLink: _link.text,
                  notes: _notes.text,
                );
                _interviewId.text = '${i.idInterview}';
                return 'Dijadwalkan: ${_fmtI(i)}';
              }, filled: true),
              _btn('Jadwalkan (kemarin)', () async {
                final a = _int(_appId);
                if (a == null) return 'Isi ID lamaran dulu.';
                await _interviews.schedule(
                  idApplication: a,
                  dateTime: _inDays(-1),
                  meetingLink: _link.text,
                );
                return 'BAHAYA: tanggal lampau lolos validasi!';
              }),
              _btn('Ubah jadwal (+2 hari, link kolom)', () async {
                final id = _int(_interviewId);
                if (id == null) return 'Isi ID interview dulu.';
                final i = await _interviews.reschedule(
                  id,
                  dateTime: _inDays(2),
                  meetingLink: _link.text,
                  notes: _notes.text,
                );
                return 'Diubah: ${_fmtI(i)}';
              }),
              _btn('Batalkan', () async {
                final id = _int(_interviewId);
                if (id == null) return 'Isi ID interview dulu.';
                return 'Dibatalkan: ${_fmtI(await _interviews.cancel(id))}';
              }),
              _btn('Tandai selesai', () async {
                final id = _int(_interviewId);
                if (id == null) return 'Isi ID interview dulu.';
                return 'Selesai: ${_fmtI(await _interviews.complete(id))}';
              }),
            ],
          ),
          _section('Recruiter dan job seeker (sesuai akun)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Daftar interview', () async {
                final list = await _interviews.getInterviews();
                return 'Interview (${list.length}):\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmtI).join("\n")}';
              }),
              _btn('Interview pada lamaran target', () async {
                final a = _int(_appId);
                if (a == null) return 'Isi ID lamaran dulu.';
                final list = await _interviews.getByApplication(a);
                return 'Interview lamaran #$a (${list.length}):\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmtI).join("\n")}';
              }),
              _btn('Link meeting aktif (lamaran target)', () async {
                final a = _int(_appId);
                if (a == null) return 'Isi ID lamaran dulu.';
                final i = await _interviews.getActiveForApplication(a);
                if (i == null) return 'Belum ada jadwal aktif.';
                final note = (i.notes == null || i.notes!.trim().isEmpty)
                    ? '-'
                    : i.notes;
                return 'Jadwal : ${i.interviewDate}\n'
                    'Catatan: $note\n'
                    'Link   : ${i.meetingLink}';
              }),
            ],
          ),
          _section('Notifikasi'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Daftar notifikasi', () async {
                final list = await _notifs.getMyNotifications();
                return 'Notifikasi (${list.length}):\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmtN).join("\n")}';
              }, filled: true),
              _btn('Jumlah belum dibaca', () async {
                return 'Belum dibaca: ${await _notifs.getUnreadCount()}';
              }),
              _btn('Tandai dibaca (ID target)', () async {
                final id = _int(_notifId);
                if (id == null) return 'Isi ID notifikasi dulu.';
                return 'Ditandai: ${_fmtN(await _notifs.markAsRead(id))}';
              }),
              _btn('Tandai semua dibaca', () async {
                return 'Ditandai dibaca: ${await _notifs.markAllAsRead()} data';
              }),
            ],
          ),
          _section('Serangan (hasil yang benar: "Aman")'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Serang: link http langsung', () async {
                final a = _int(_appId);
                if (a == null) return 'Isi ID lamaran dulu.';
                return _directInsert(
                  appId: a,
                  link: 'http://meet.google.com/abc-defg-hij',
                  date: _inDays(1),
                );
              }),
              _btn('Serang: link bukan Google Meet', () async {
                final a = _int(_appId);
                if (a == null) return 'Isi ID lamaran dulu.';
                return _directInsert(
                  appId: a,
                  link: 'https://contoh-jahat.example/login',
                  date: _inDays(1),
                );
              }),
              _btn('Serang: tanggal lampau langsung', () async {
                final a = _int(_appId);
                if (a == null) return 'Isi ID lamaran dulu.';
                return _directInsert(
                  appId: a,
                  link: 'https://meet.google.com/abc-defg-hij',
                  date: _inDays(-1),
                );
              }),
              _btn('Serang: jadwal (data valid, akun apa pun)', () async {
                final a = _int(_appId);
                if (a == null) return 'Isi ID lamaran dulu.';
                return _directInsert(
                  appId: a,
                  link: 'https://meet.google.com/abc-defg-hij',
                  date: _inDays(1),
                );
              }),
              _btn('Serang: ubah link interview langsung', () async {
                final id = _int(_interviewId);
                if (id == null) return 'Isi ID interview dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('interviews')
                      .update({
                        'meeting_link': 'https://meet.google.com/xyz-xyzx-xyz',
                      })
                      .eq('id_interview', id)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: link interview BERHASIL diubah!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn('Serang: pindahkan id_application', () async {
                final id = _int(_interviewId);
                if (id == null) return 'Isi ID interview dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('interviews')
                      .update({'id_application': 999999})
                      .eq('id_interview', id)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: id_application BERHASIL diubah!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn('Serang: buat notifikasi sendiri', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                try {
                  final res =
                      await SupabaseConfig.client.from('notifications').insert({
                        'id_user': uid,
                        'title': 'Palsu',
                        'message': 'Notifikasi palsu',
                        'is_read': false,
                      }).select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris tersimpan.'
                      : 'BAHAYA: notifikasi BERHASIL dibuat dari client!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn('Serang: ubah judul notifikasi', () async {
                final id = _int(_notifId);
                if (id == null) return 'Isi ID notifikasi dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('notifications')
                      .update({'title': 'Judul diubah'})
                      .eq('id_notification', id)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: judul notifikasi BERHASIL diubah!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn('Serang: baca notifikasi akun lain', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                try {
                  final rows = await SupabaseConfig.client
                      .from('notifications')
                      .select('id_notification')
                      .neq('id_user', uid);
                  return rows.isEmpty
                      ? 'Aman: 0 notifikasi akun lain terbaca.'
                      : 'BAHAYA: ${rows.length} notifikasi akun lain terbaca!';
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
