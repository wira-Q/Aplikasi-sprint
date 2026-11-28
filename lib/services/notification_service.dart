import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/postgrest_error_mapper.dart';
import '../models/notification_model.dart';
import '../models/paged_result.dart';

/// Notifikasi dibuat oleh trigger database. Service ini hanya membaca
/// dan menandai dibaca; client tidak bisa membuat notifikasi.
class NotificationService {
  NotificationService({SupabaseClient? client})
    : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  static const int _maxPageSize = 50;
  static const int unreadCountCap = 100;

  Future<PagedResult<NotificationModel>> getMyNotificationsPage({
    bool unreadOnly = false,
    int page = 0,
    int pageSize = kPageSize,
  }) async {
    final uid = _requireUid();
    if (page < 0 || pageSize < 1 || pageSize > _maxPageSize) {
      throw const AppException('Parameter halaman tidak valid.');
    }
    try {
      var q = _client.from('notifications').select().eq('id_user', uid);
      if (unreadOnly) q = q.eq('is_read', false);
      final from = page * pageSize;
      final res = await q
          .order('created_at', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);
      return PagedResult<NotificationModel>(
        items: res.data.map((r) => NotificationModel.fromMap(r)).toList(),
        total: res.count,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getMyNotificationsPage error: ${e.runtimeType}');
      throw const AppException(
        'Gagal memuat notifikasi. Periksa koneksi Anda.',
      );
    }
  }

  Future<List<NotificationModel>> getMyNotifications({
    bool unreadOnly = false,
    int page = 0,
    int pageSize = 20,
  }) async => (await getMyNotificationsPage(
    unreadOnly: unreadOnly,
    page: page,
    pageSize: pageSize,
  )).items;

  /// Jumlah belum dibaca, dibatasi [unreadCountCap]. Untuk badge: tampilkan
  /// "99+" jika hasilnya sama dengan batas.
  Future<int> getUnreadCount() async {
    final uid = _requireUid();
    try {
      final rows = await _client
          .from('notifications')
          .select('id_notification')
          .eq('id_user', uid)
          .eq('is_read', false)
          .limit(unreadCountCap);
      return rows.length;
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('getUnreadCount error: ${e.runtimeType}');
      throw const AppException(
        'Gagal memuat notifikasi. Periksa koneksi Anda.',
      );
    }
  }

  Future<NotificationModel> markAsRead(int idNotification) async {
    final uid = _requireUid();
    try {
      final row = await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id_notification', idNotification)
          .eq('id_user', uid)
          .select()
          .maybeSingle();
      if (row == null) {
        throw const AppException(
          'Notifikasi tidak ditemukan.',
          code: 'not_found',
        );
      }
      return NotificationModel.fromMap(row);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('markAsRead error: ${e.runtimeType}');
      throw const AppException('Gagal memperbarui notifikasi.');
    }
  }

  /// Mengembalikan jumlah notifikasi yang ditandai dibaca.
  Future<int> markAllAsRead() async {
    final uid = _requireUid();
    try {
      final rows = await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id_user', uid)
          .eq('is_read', false)
          .select('id_notification');
      return rows.length;
    } on PostgrestException catch (e) {
      throw mapPostgrestError(e);
    } catch (e) {
      _log('markAllAsRead error: ${e.runtimeType}');
      throw const AppException('Gagal memperbarui notifikasi.');
    }
  }

  String _requireUid() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw const AppException(
        'Sesi berakhir. Silakan login kembali.',
        code: 'no_session',
      );
    }
    return uid;
  }

  void _log(String text) {
    if (kDebugMode) debugPrint('[NotificationService] $text');
  }
}
