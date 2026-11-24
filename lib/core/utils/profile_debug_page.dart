import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../models/job_model.dart';
import '../../models/profile_options.dart';
import '../../models/user_model.dart';
import '../../services/job_service.dart';
import '../../services/user_service.dart';
import 'app_exception.dart';

class ProfileDebugPage extends StatefulWidget {
  const ProfileDebugPage({super.key});

  @override
  State<ProfileDebugPage> createState() => _ProfileDebugPageState();
}

class _ProfileDebugPageState extends State<ProfileDebugPage> {
  final _users = UserService();
  final _jobs = JobService();

  String _output = 'Belum ada aksi. Login dulu lewat halaman Uji Auth.';
  bool _busy = false;

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

  String _fmtUser(UserModel u) =>
      '${u.name} | ${u.role.value} | lahir: ${u.birthDate} | '
      'gender: ${u.gender} | pendidikan: ${u.education}\n'
      'lokasi pilihan: ${u.preferredLocations} | '
      'jenis pilihan: ${u.preferredJobTypes}\n'
      'onboarding job seeker selesai: ${u.isJobSeekerOnboardingComplete}';

  String _fmtJob(JobModel j) =>
      '#${j.idJob} ${j.title} | ${j.location} | ${j.jobType} | ${j.status}';

  /// Update langsung ke tabel, melewati service. Hasil yang benar: ditolak.
  Future<String> _directUpdate(
    String table,
    Map<String, dynamic> changes, {
    required String dangerText,
  }) async {
    try {
      final res = await SupabaseConfig.client
          .from(table)
          .update(changes)
          .gte(
            table == 'users' ? 'created_at' : 'id_job',
            table == 'users' ? '1900-01-01' : 0,
          )
          .select();
      return res.isEmpty
          ? 'Aman: tidak ada baris yang berubah.'
          : 'BAHAYA: $dangerText (${res.length} baris). Kembalikan lewat SQL Editor.';
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
        title: const Text('Uji Onboarding & Rekomendasi (sementara)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Job seeker'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Isi profil onboarding (data valid)', () async {
                await _users.updateProfile(
                  birthDate: DateTime(2000, 5, 17),
                  gender: 'Laki-laki',
                  education: 'S1',
                );
                final u = await _users.updatePreferences(
                  locations: ['Malang', 'Surabaya'],
                  jobTypes: ['Full-time', 'Internship'],
                );
                return 'Tersimpan:\n${_fmtUser(u)}';
              }, filled: true),
              _btn('Lihat profil saya', () async {
                final u = await _users.getCurrentProfile();
                return u == null ? 'Profil tidak ditemukan.' : _fmtUser(u);
              }),
              _btn('Rekomendasi sesuai preferensi', () async {
                final u = await _users.getCurrentProfile();
                if (u == null) return 'Profil tidak ditemukan.';
                final list = await _jobs.getRecommendedJobs(
                  locations: u.preferredLocations,
                  jobTypes: u.preferredJobTypes,
                );
                return 'Rekomendasi (${list.length}) untuk lokasi '
                    '${u.preferredLocations} dan jenis ${u.preferredJobTypes}:\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmtJob).join("\n")}';
              }),
              _btn('Filter utama satu lokasi (Malang)', () async {
                final list = await _jobs.getJobs(location: 'Malang');
                return 'Lowongan Malang (${list.length}):\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmtJob).join("\n")}';
              }),
              _btn('Label jenis pekerjaan', () async {
                return JobOptions.jobTypes
                    .map((t) => '$t -> ${JobTypeLabels.of(t)}')
                    .join('\n');
              }),
            ],
          ),
          _section('Validasi aplikasi (hasil yang benar: ditolak)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Tanggal lahir masa depan', () async {
                await _users.updateProfile(
                  birthDate: DateTime.now().add(const Duration(days: 30)),
                );
                return 'BAHAYA: tanggal lahir masa depan lolos!';
              }),
              _btn('Tanggal lahir usia 10 tahun', () async {
                final n = DateTime.now();
                await _users.updateProfile(
                  birthDate: DateTime(n.year - 10, n.month, n.day),
                );
                return 'BAHAYA: usia 10 tahun lolos!';
              }),
              _btn('Pendidikan "Doktor"', () async {
                await _users.updateProfile(education: 'Doktor');
                return 'BAHAYA: pendidikan di luar daftar lolos!';
              }),
              _btn('Lokasi pilihan "Jakarta"', () async {
                await _users.updatePreferences(locations: ['Jakarta']);
                return 'BAHAYA: lokasi di luar tiga kota lolos!';
              }),
            ],
          ),
          _section('Serangan langsung ke database (hasil yang benar: "Aman")'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Serang: birth_date tahun 2100', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('users')
                      .update({'birth_date': '2100-01-01'})
                      .eq('id_user', uid)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: birth_date tahun 2100 TERSIMPAN!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn('Serang: birth_date usia 10 tahun', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('users')
                      .update({
                        'birth_date': '${DateTime.now().year - 10}-01-01',
                      })
                      .eq('id_user', uid)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: usia 10 tahun TERSIMPAN!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn('Serang: preferred_locations Jakarta', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('users')
                      .update({
                        'preferred_locations': ['Jakarta'],
                      })
                      .eq('id_user', uid)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: lokasi Jakarta TERSIMPAN!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn('Serang: education "Doktor"', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('users')
                      .update({'education': 'Doktor'})
                      .eq('id_user', uid)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris yang berubah.'
                      : 'BAHAYA: pendidikan "Doktor" TERSIMPAN!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn('Serang: ubah preferensi akun lain', () async {
                final uid = SupabaseConfig.client.auth.currentUser?.id;
                if (uid == null) return 'Login dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('users')
                      .update({
                        'preferred_locations': ['Malang'],
                      })
                      .neq('id_user', uid)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris akun lain yang berubah.'
                      : 'BAHAYA: preferensi ${res.length} akun lain BERUBAH!';
                } catch (e) {
                  return 'Aman: ditolak (${_errCode(e)}).';
                }
              }),
              _btn(
                'Serang (recruiter): jobs.education "Doktor"',
                () => _directUpdate('jobs', {
                  'education': 'Doktor',
                }, dangerText: 'pendidikan "Doktor" tersimpan di lowongan'),
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
