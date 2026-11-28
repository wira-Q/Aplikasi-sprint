import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sprint/core/utils/app_exception.dart';
import 'package:sprint/core/utils/paged_controller.dart';
import 'package:sprint/core/widgets/page_bar.dart';
import 'package:sprint/models/notification_model.dart';
import 'package:sprint/services/notification_service.dart';

/// Menampilkan popup daftar notifikasi pengguna yang sedang login (5 per
/// halaman, tarik ke bawah untuk memuat ulang). Notifikasi dibuat oleh
/// sistem (trigger database); popup ini hanya membaca dan menandai dibaca.
///
/// [onOpenApplication] dipanggil (setelah popup ditutup) saat pengguna
/// mengetuk notifikasi yang terkait lamaran. Jika null, mengetuk hanya
/// menandai dibaca.
Future<void> showNotificationSheet(
  BuildContext context, {
  void Function(int idApplication)? onOpenApplication,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _NotificationSheet(onOpenApplication: onOpenApplication),
  );
}

class _NotificationSheet extends StatefulWidget {
  const _NotificationSheet({this.onOpenApplication});

  final void Function(int idApplication)? onOpenApplication;

  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {
  static const Color _primaryColor = Color(0xFF203F8B);

  final NotificationService _service = NotificationService();
  late final PagedController<NotificationModel> _pager;

  bool _isMarkingAll = false;

  /// Gagal menandai dibaca atau memuat ulang.
  String? _actionMessage;

  @override
  void initState() {
    super.initState();
    _pager = PagedController<NotificationModel>(
      fetch: (page, size) =>
          _service.getMyNotificationsPage(page: page, pageSize: size),
      onChanged: () {
        if (mounted) setState(() {});
      },
      errorText: 'Gagal memuat notifikasi. Periksa koneksi Anda.',
      onBackgroundError: (message) {
        if (mounted) setState(() => _actionMessage = message);
      },
    );
    _pager.load(page: 0);
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _markRead(NotificationModel item) async {
    if (item.isRead) return;
    try {
      final updated = await _service.markAsRead(item.idNotification);
      if (!mounted) return;
      setState(() {
        _actionMessage = null;
        _pager.items = [
          for (final n in _pager.items)
            n.idNotification == updated.idNotification ? updated : n,
        ];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _actionMessage = e is AppException
            ? e.message
            : 'Gagal memperbarui notifikasi.';
      });
    }
  }

  /// Notifikasi dengan lamaran: ditandai dibaca, popup ditutup, lalu halaman
  /// lamaran dibuka oleh pemanggil. Notifikasi lain hanya ditandai dibaca.
  Future<void> _onTap(NotificationModel item) async {
    final idApplication = item.idApplication;
    final open = widget.onOpenApplication;

    await _markRead(item);
    if (!mounted) return;

    if (idApplication != null && open != null) {
      Navigator.pop(context);
      open(idApplication);
    }
  }

  Future<void> _markAllRead() async {
    if (_isMarkingAll) return;
    setState(() {
      _isMarkingAll = true;
      _actionMessage = null;
    });
    try {
      await _service.markAllAsRead();
      if (!mounted) return;
      setState(() {
        _pager.items = _pager.items.map(_asRead).toList();
        _isMarkingAll = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isMarkingAll = false;
        _actionMessage = e is AppException
            ? e.message
            : 'Gagal memperbarui notifikasi.';
      });
    }
  }

  NotificationModel _asRead(NotificationModel n) => NotificationModel(
    idNotification: n.idNotification,
    idUser: n.idUser,
    idApplication: n.idApplication,
    title: n.title,
    message: n.message,
    isRead: true,
    createdAt: n.createdAt,
  );

  /// Ikon hanya hiasan, dipilih dari kata di judul.
  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('interview') || t.contains('jadwal')) {
      return Icons.videocam_outlined;
    }
    if (t.contains('diterima')) return Icons.check_circle_outline;
    if (t.contains('belum dapat')) return Icons.cancel_outlined;
    if (t.contains('terkirim')) return Icons.send_outlined;
    if (t.contains('pelamar')) return Icons.person_add_alt_1_outlined;
    return Icons.notifications_none_rounded;
  }

  String _timeAgo(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.7;
    final hasUnread = _pager.items.any((n) => !n.isRead);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifikasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (hasUnread)
                    TextButton(
                      onPressed: _isMarkingAll ? null : _markAllRead,
                      child: Text(
                        'Tandai semua dibaca',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_actionMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _actionMessage!,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.red),
                  ),
                ),
              ),
            const Divider(height: 1),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final children = <Widget>[];

    if (_pager.isLoading) {
      children.add(
        const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (_pager.error != null && _pager.items.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                _pager.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              TextButton(
                onPressed: () => _pager.load(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    } else if (_pager.items.isEmpty) {
      children.add(
        SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 44,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada notifikasi',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      for (final item in _pager.items) {
        children.add(_buildItem(item));
        children.add(const Divider(height: 1));
      }
    }

    children.add(
      PageBar(
        page: _pager.page,
        totalPages: _pager.totalPages,
        enabled: !_pager.isLoading,
        onPageSelected: (p) => _pager.goTo(p),
      ),
    );

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _actionMessage = null);
        await _pager.load(spinner: false);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: children,
      ),
    );
  }

  Widget _buildItem(NotificationModel item) {
    final canOpen =
        item.idApplication != null && widget.onOpenApplication != null;

    return InkWell(
      onTap: () => _onTap(item),
      child: Container(
        color: item.isRead ? Colors.transparent : const Color(0xFFF0F4FF),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(item.title), size: 20, color: _primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: item.isRead
                          ? FontWeight.w600
                          : FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(item.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2862E8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (canOpen)
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
