import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/date_format_id.dart';
import 'package:sprint/models/application_model.dart';
import 'package:sprint/models/interview_model.dart';
import 'package:sprint/services/application_service.dart';
import 'package:sprint/services/avatar_service.dart';
import 'package:sprint/services/cv_service.dart';
import 'package:sprint/services/interview_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'recruiter_theme.dart';

String _hhmm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

// Halaman Detail Pelamar. Data dimuat dari database berdasarkan
// [idApplication]. Alur status: Diproses -> Interview atau Ditolak,
// Interview -> Diterima atau Ditolak. Diterima dan Ditolak final.
class DetailPelamarPage extends StatefulWidget {
  final int idApplication;

  const DetailPelamarPage({super.key, required this.idApplication});

  @override
  State<DetailPelamarPage> createState() => _DetailPelamarPageState();
}

class _DetailPelamarPageState extends State<DetailPelamarPage> {
  static const Color _blue = Color(0xFF2863E9);
  static const Color _dark = Color(0xFF17233D);

  final ApplicationService _applications = ApplicationService();
  final AvatarService _avatars = AvatarService();
  final CvService _cvs = CvService();
  final InterviewService _interviews = InterviewService();

  ApplicationModel? _app;
  InterviewModel? _activeInterview;
  String? _photoUrl;
  bool _isLoading = true;
  bool _busy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool spinner = true}) async {
    if (spinner) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final app = await _applications.getApplicantById(widget.idApplication);
      if (app == null) {
        throw const AppException(
          'Pelamar tidak ditemukan atau bukan milik lowongan Anda.',
        );
      }
      final photoUrl = await _avatars.signedUrl(app.applicantPhoto);
      final interviews = await _interviews.getByApplication(
        widget.idApplication,
      );
      if (!mounted) return;
      setState(() {
        _app = app;
        _photoUrl = photoUrl;
        _activeInterview = interviews.where((i) => i.isScheduled).firstOrNull;
        _errorMessage = null;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat pelamar. Periksa koneksi Anda.';
        _isLoading = false;
      });
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Color _statusTextColor(String s) {
    switch (s) {
      case ApplicationStatus.diterima:
        return const Color(0xFF159653);
      case ApplicationStatus.ditolak:
        return Colors.red;
      case ApplicationStatus.interview:
        return const Color(0xFFB7791F);
      default:
        return _blue;
    }
  }

  List<String> get _nextStatuses {
    final current = _app?.status;
    return [
          ApplicationStatus.interview,
          ApplicationStatus.diterima,
          ApplicationStatus.ditolak,
        ]
        .where(
          (s) => ApplicationStatus.allowedFrom[s]?.contains(current) ?? false,
        )
        .toList();
  }

  Future<bool?> _confirm(String title, String message, {String ok = 'Ya'}) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(ok),
          ),
        ],
      ),
    );
  }

  // ---------- aksi ----------
  Future<void> _changeStatus(String target) async {
    final app = _app;
    if (app == null || _busy) return;

    final isFinal = target != ApplicationStatus.interview;
    final message = target == ApplicationStatus.interview
        ? 'Lamaran akan dilanjutkan ke tahap interview. Pelamar akan '
              'mendapat notifikasi.'
        : 'Keputusan ini tidak dapat diubah lagi dan pelamar akan mendapat '
              'notifikasi.';
    final ok = await _confirm(
      'Ubah status menjadi $target?',
      message,
      ok: target,
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _applications.updateStatus(widget.idApplication, target);
      if (!mounted) return;
      _snack('Status ${app.applicantName ?? 'pelamar'} diubah menjadi $target');
      if (isFinal) {
        Navigator.pop(context, true);
        return;
      }
      setState(() => _busy = false);
      await _load(spinner: false);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Gagal mengubah status. Periksa koneksi Anda.');
    }
  }

  void _pickStatus() {
    final options = _nextStatuses;
    if (options.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              const Text(
                'Ubah Status Lamaran',
                style: TextStyle(
                  color: _dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...options.map((s) {
                return ListTile(
                  title: Text(
                    s,
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusTextColor(s),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _changeStatus(s);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCv() async {
    final app = _app;
    if (app == null) return;
    try {
      final url = await _cvs.createSignedUrl(app.idCv);
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) _snack('Tidak dapat membuka CV.');
    } on AppException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Tidak dapat membuka CV.');
    }
  }

  Future<void> _openSchedule({InterviewModel? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ScheduleSheet(
        idApplication: widget.idApplication,
        existing: existing,
      ),
    );
    if (saved == true && mounted) {
      _snack('Jadwal interview disimpan. Pelamar mendapat notifikasi.');
      await _load(spinner: false);
    }
  }

  Future<void> _cancelInterview(InterviewModel interview) async {
    if (_busy) return;
    final ok = await _confirm(
      'Batalkan jadwal interview?',
      'Pelamar akan mendapat notifikasi pembatalan. Anda bisa membuat jadwal '
          'baru setelahnya.',
      ok: 'Batalkan jadwal',
    );
    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _interviews.cancel(interview.idInterview);
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Jadwal interview dibatalkan.');
      await _load(spinner: false);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Gagal membatalkan jadwal. Periksa koneksi Anda.');
    }
  }

  // ---------- widget ----------
  String _sizeText(int? bytes) {
    if (bytes == null) return '';
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} mb';
    }
    return '${(bytes / 1024).ceil()} kb';
  }

  Widget _avatar(ApplicationModel a) {
    Widget initial() => Container(
      color: Colors.blueGrey,
      alignment: Alignment.center,
      child: Text(
        initialsOf(a.applicantName),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    final url = _photoUrl;
    return ClipOval(
      child: SizedBox(
        width: 72,
        height: 72,
        child: url == null
            ? initial()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => initial(),
              ),
      ),
    );
  }

  Widget _profileHeader(ApplicationModel a) {
    final education = a.applicantEducation?.trim();
    final city = a.applicantLocation?.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(a),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                a.applicantName ?? '-',
                style: const TextStyle(
                  color: _dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Melamar: ${a.jobTitle ?? '-'}',
                style: const TextStyle(color: _dark, fontSize: 9),
              ),
              if (city != null && city.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(city, style: const TextStyle(color: _dark, fontSize: 9)),
              ],
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.school_outlined, size: 12, color: _dark),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      (education == null || education.isEmpty)
                          ? 'Pendidikan belum diisi'
                          : education,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _dark, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: _blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _dark, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactSection(ApplicationModel a) {
    final phone = a.applicantPhone?.trim();
    final message = a.message?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoLine(Icons.mail_outline_rounded, a.applicantEmail ?? '-'),
        if (phone != null && phone.isNotEmpty)
          _infoLine(Icons.phone_outlined, phone),
        if (message != null && message.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text(
            'Pesan pelamar',
            style: TextStyle(
              color: _dark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: const TextStyle(color: _dark, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusCard(ApplicationModel a) {
    final canChange = _nextStatuses.isNotEmpty;
    return GestureDetector(
      onTap: canChange ? _pickStatus : null,
      child: Container(
        width: double.infinity,
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE3F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              a.status.toLowerCase(),
              style: TextStyle(
                color: _statusTextColor(a.status),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (canChange)
              const Icon(Icons.chevron_right, color: _dark, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _interviewSection() {
    final i = _activeInterview;
    final notes = i?.notes?.trim();

    Widget row(IconData icon, String text, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _dark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _dark, fontSize: 11),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Jadwal interview',
            style: TextStyle(
              color: _dark,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: i == null
              ? const Text(
                  'Belum dijadwalkan. Buat jadwal dan link Google Meet agar '
                  'pelamar bisa mengikuti interview.',
                  style: TextStyle(color: _dark, fontSize: 11, height: 1.4),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    row(
                      Icons.calendar_today_outlined,
                      DateFormatId.dayDate(i.interviewDate),
                    ),
                    row(
                      Icons.access_time_rounded,
                      'Pukul ${DateFormatId.time(i.interviewDate)}',
                    ),
                    row(
                      Icons.sticky_note_2_outlined,
                      (notes == null || notes.isEmpty) ? '-' : notes,
                    ),
                    row(
                      Icons.video_call_rounded,
                      i.meetingLink,
                      trailing: GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: i.meetingLink),
                          );
                          if (mounted) _snack('Link disalin.');
                        },
                        child: const Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 10),
        if (i == null)
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: _busy ? null : () => _openSchedule(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Jadwalkan Interview',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _cancelInterview(i),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Batalkan Jadwal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _busy ? null : () => _openSchedule(existing: i),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ubah Jadwal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _cvCard(ApplicationModel a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E6EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CV pelamar',
            style: TextStyle(
              color: _dark,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3ECFE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: _blue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.cvFileName ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                    Text(
                      _sizeText(a.cvFileSize),
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openCv,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFFE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Lihat cv',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          width: 120,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions(ApplicationModel a) {
    const red = Color(0xFFFF7F87);
    if (a.status == ApplicationStatus.diproses) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(
            'Tolak',
            red,
            _busy ? null : () => _changeStatus(ApplicationStatus.ditolak),
          ),
          _actionButton(
            'Interview',
            _blue,
            _busy ? null : () => _changeStatus(ApplicationStatus.interview),
          ),
        ],
      );
    }
    if (a.status == ApplicationStatus.interview) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(
            'Tolak',
            red,
            _busy ? null : () => _changeStatus(ApplicationStatus.ditolak),
          ),
          _actionButton(
            'Terima',
            _blue,
            _busy ? null : () => _changeStatus(ApplicationStatus.diterima),
          ),
        ],
      );
    }
    return const Center(
      child: Text(
        'Keputusan untuk lamaran ini sudah final.',
        style: TextStyle(color: textGrey, fontSize: 11),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final a = _app;
    if (a == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage ?? 'Pelamar tidak ditemukan.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: textGrey, fontSize: 12),
              ),
              TextButton(onPressed: _load, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileHeader(a),
          const SizedBox(height: 16),
          _contactSection(a),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Status lamaran',
              style: TextStyle(
                color: _dark,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _statusCard(a),
          if (a.status == ApplicationStatus.interview) ...[
            const SizedBox(height: 24),
            _interviewSection(),
          ],
          const SizedBox(height: 28),
          _cvCard(a),
          const SizedBox(height: 36),
          _actions(a),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 21),
        ),
        title: const Text(
          'Detail Pelamar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }
}

// Form jadwal interview (bottom sheet). Mengembalikan true jika tersimpan.
class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({required this.idApplication, this.existing});

  final int idApplication;
  final InterviewModel? existing;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  static const Color _blue = Color(0xFF2863E9);
  static const Color _dark = Color(0xFF17233D);

  final InterviewService _service = InterviewService();
  late final TextEditingController _linkC;
  late final TextEditingController _notesC;

  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _linkC = TextEditingController(text: e?.meetingLink ?? '');
    _notesC = TextEditingController(text: e?.notes ?? '');
    if (e != null) {
      _date = DateTime(
        e.interviewDate.year,
        e.interviewDate.month,
        e.interviewDate.day,
      );
      _time = TimeOfDay.fromDateTime(e.interviewDate);
    }
  }

  @override
  void dispose() {
    _linkC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var initial = _date ?? today.add(const Duration(days: 1));
    if (initial.isBefore(today)) initial = today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _error = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _time = picked;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_saving) return;
    final date = _date;
    final time = _time;
    if (date == null || time == null) {
      setState(() => _error = 'Pilih tanggal dan jam interview.');
      return;
    }
    final when = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!when.isAfter(DateTime.now())) {
      setState(() => _error = 'Tanggal dan jam harus di masa depan.');
      return;
    }
    final linkError = MeetingRules.validateLink(_linkC.text);
    if (linkError != null) {
      setState(() => _error = linkError);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final existing = widget.existing;
      if (existing == null) {
        await _service.schedule(
          idApplication: widget.idApplication,
          dateTime: when,
          meetingLink: _linkC.text,
          notes: _notesC.text,
        );
      } else {
        await _service.reschedule(
          existing.idInterview,
          dateTime: when,
          meetingLink: _linkC.text,
          notes: _notesC.text,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _saving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan. Periksa koneksi Anda.';
        _saving = false;
      });
    }
  }

  Widget _pickerBox(IconData icon, String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: _saving ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFAAAAAA)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 11, color: _dark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = _date;
    final time = _time;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null ? 'Jadwalkan Interview' : 'Ubah Jadwal',
                style: const TextStyle(
                  color: _dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Interview dilakukan online. Pelamar akan melihat tanggal, '
                'jam, catatan, dan link meeting.',
                style: TextStyle(color: textGrey, fontSize: 10, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _pickerBox(
                    Icons.calendar_today_outlined,
                    date == null ? 'Pilih tanggal' : DateFormatId.date(date),
                    _pickDate,
                  ),
                  const SizedBox(width: 10),
                  _pickerBox(
                    Icons.access_time_rounded,
                    time == null ? 'Pilih jam' : _hhmm(time),
                    _pickTime,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkC,
                enabled: !_saving,
                keyboardType: TextInputType.url,
                style: const TextStyle(fontSize: 11),
                decoration: _decoration('https://meet.google.com/xxx-xxxx-xxx'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesC,
                enabled: !_saving,
                maxLines: 3,
                maxLength: 1000,
                style: const TextStyle(fontSize: 11),
                decoration: _decoration(
                  'Catatan untuk pelamar (opsional). Terlihat oleh pelamar.',
                ).copyWith(counterText: ''),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Jadwal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
