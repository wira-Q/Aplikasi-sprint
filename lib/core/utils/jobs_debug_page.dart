import 'package:flutter/material.dart';

import '../../config/supabase_config.dart';
import '../../models/job_model.dart';
import '../../services/company_service.dart';
import '../../services/job_service.dart';
import 'app_exception.dart';

class JobsDebugPage extends StatefulWidget {
  const JobsDebugPage({super.key});

  @override
  State<JobsDebugPage> createState() => _JobsDebugPageState();
}

class _JobsDebugPageState extends State<JobsDebugPage> {
  final _companies = CompanyService();
  final _jobs = JobService();
  final _companyName = TextEditingController(text: 'PT Uji Sprint');
  final _title = TextEditingController(text: 'Flutter Developer');
  final _search = TextEditingController();
  final _targetId = TextEditingController();

  String _location = 'Malang';
  String _jobType = 'Full-time';
  bool _useFilter = false;
  int _page = 0;
  int? _lastJobId;
  String _output = 'Belum ada aksi. Login dulu lewat halaman Uji Auth.';
  bool _busy = false;

  static const int _pageSize = 3;

  @override
  void dispose() {
    _companyName.dispose();
    _title.dispose();
    _search.dispose();
    _targetId.dispose();
    super.dispose();
  }

  int? get _target => int.tryParse(_targetId.text.trim()) ?? _lastJobId;

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

  String _fmt(JobModel j) =>
      '#${j.idJob} ${j.title} | ${j.location} | ${j.jobType} | ${j.status} | ${j.companyName ?? "-"}';

  Future<String> _listJobs(int page) async {
    final list = await _jobs.getJobs(
      query: _search.text,
      location: _useFilter ? _location : null,
      jobType: _useFilter ? _jobType : null,
      page: page,
      pageSize: _pageSize,
    );
    _page = page;
    return 'Daftar lowongan Dibuka, halaman ${page + 1} (${list.length} data):\n'
        '${list.isEmpty ? "(kosong)" : list.map(_fmt).join("\n")}';
  }

  Widget _btn(
    String label,
    Future<String> Function() action, {
    bool outlined = true,
  }) {
    final onPressed = _busy ? null : () => _run(action);
    return outlined
        ? OutlinedButton(onPressed: onPressed, child: Text(label))
        : FilledButton(onPressed: onPressed, child: Text(label));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uji Company & Jobs (sementara)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _companyName,
            decoration: const InputDecoration(labelText: 'Nama perusahaan'),
          ),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Judul lowongan'),
          ),
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'Kata kunci pencarian',
            ),
          ),
          TextField(
            controller: _targetId,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ID lowongan target (kosong = lowongan terakhir)',
            ),
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: _location,
                items: JobOptions.locations
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _location = v ?? _location),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _jobType,
                items: JobOptions.jobTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _jobType = v ?? _jobType),
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Pakai filter lokasi dan jenis saat mencari'),
            value: _useFilter,
            onChanged: (v) => setState(() => _useFilter = v),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Perusahaan saya', () async {
                final c = await _companies.getMyCompany();
                return c == null
                    ? 'Belum punya profil perusahaan.'
                    : 'Perusahaan: #${c.idCompany} ${c.companyName}';
              }),
              _btn('Buat perusahaan', () async {
                final c = await _companies.createMyCompany(
                  companyName: _companyName.text,
                );
                return 'Perusahaan dibuat: #${c.idCompany} ${c.companyName}';
              }),
              _btn('Buat lowongan', () async {
                final j = await _jobs.createJob(
                  title: _title.text,
                  description: 'Deskripsi lowongan uji.',
                  location: _location,
                  jobType: _jobType,
                  workSystem: 'Hybrid',
                  skills: 'Flutter, Dart',
                  salary: 5000000,
                );
                _lastJobId = j.idJob;
                return 'Lowongan dibuat: ${_fmt(j)}';
              }, outlined: false),
              _btn(
                'Daftar lowongan (job seeker)',
                () => _listJobs(0),
                outlined: false,
              ),
              _btn('Halaman berikut', () => _listJobs(_page + 1)),
              _btn('Lowongan saya (recruiter)', () async {
                final list = await _jobs.getMyJobs(pageSize: 20);
                return 'Lowongan saya (${list.length}):\n'
                    '${list.isEmpty ? "(kosong)" : list.map(_fmt).join("\n")}';
              }),
              _btn('Tutup lowongan', () async {
                final id = _target;
                if (id == null) return 'Isi ID target atau buat lowongan dulu.';
                final j = await _jobs.closeJob(id);
                return 'Ditutup: ${_fmt(j)}';
              }),
              _btn('Buka kembali', () async {
                final id = _target;
                if (id == null) return 'Isi ID target atau buat lowongan dulu.';
                final j = await _jobs.reopenJob(id);
                return 'Dibuka: ${_fmt(j)}';
              }),
              _btn('Ubah judul (target)', () async {
                final id = _target;
                if (id == null) return 'Isi ID target atau buat lowongan dulu.';
                final j = await _jobs.updateJob(id, title: _title.text);
                return 'Diubah: ${_fmt(j)}';
              }),
              _btn('Serang: pindahkan id_company', () async {
                final id = _target;
                if (id == null) return 'Isi ID target dulu.';
                try {
                  await SupabaseConfig.client
                      .from('jobs')
                      .update({'id_company': 999999})
                      .eq('id_job', id);
                  return 'BAHAYA: id_company BERHASIL diubah (izin kolom bocor!)';
                } catch (e) {
                  return 'Aman: ditolak (${e.runtimeType}).';
                }
              }),
              _btn('Serang: hapus lowongan', () async {
                final id = _target;
                if (id == null) return 'Isi ID target dulu.';
                try {
                  final res = await SupabaseConfig.client
                      .from('jobs')
                      .delete()
                      .eq('id_job', id)
                      .select();
                  return res.isEmpty
                      ? 'Aman: tidak ada baris terhapus.'
                      : 'BAHAYA: lowongan BERHASIL dihapus!';
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
