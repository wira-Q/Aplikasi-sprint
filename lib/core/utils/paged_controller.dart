import 'package:flutter/foundation.dart';

import '../../models/paged_result.dart';
import 'app_exception.dart';

/// Penyimpan keadaan daftar berhalaman: item, nomor halaman, total, loading,
/// dan error. Dipakai semua layar daftar supaya perilakunya seragam.
///
/// [onChanged] dipanggil setiap keadaan berubah (isi dengan setState).
/// [onBackgroundError] dipanggil jika muat ulang diam-diam (tarik ke bawah)
/// gagal padahal daftar sudah terisi; daftar lama tetap ditampilkan.
class PagedController<T> {
  PagedController({
    required this.fetch,
    required this.onChanged,
    this.pageSize = kPageSize,
    this.errorText = 'Gagal memuat data. Periksa koneksi Anda.',
    this.onBackgroundError,
  });

  final Future<PagedResult<T>> Function(int page, int pageSize) fetch;
  final VoidCallback onChanged;
  final int pageSize;
  final String errorText;
  final void Function(String message)? onBackgroundError;

  List<T> items = <T>[];

  /// Halaman aktif, dimulai dari 0.
  int page = 0;
  int total = 0;
  bool isLoading = true;
  String? error;

  int _requestId = 0;
  bool _disposed = false;

  int get totalPages => total <= 0 ? 1 : (total + pageSize - 1) ~/ pageSize;

  /// Memuat halaman [page] (default: halaman aktif). [spinner] false untuk
  /// muat ulang diam-diam tanpa mengganti daftar dengan indikator loading.
  Future<void> load({int? page, bool spinner = true}) async {
    final target = page ?? this.page;
    final id = ++_requestId;
    if (spinner) {
      final wasLoading = isLoading;
      isLoading = true;
      error = null;
      if (!wasLoading) _notify();
    }
    try {
      var result = await _fetchSafe(target);
      // Halaman ini sudah kosong (data berkurang): pindah ke halaman terakhir.
      if (result.items.isEmpty && target > 0 && result.total > 0) {
        result = await _fetchSafe(result.totalPages - 1);
      }
      if (_disposed || id != _requestId) return;
      items = result.items;
      total = result.total;
      this.page = result.total == 0 ? 0 : result.page;
      error = null;
      isLoading = false;
    } on AppException catch (e) {
      if (_disposed || id != _requestId) return;
      _fail(e.message, spinner);
    } catch (_) {
      if (_disposed || id != _requestId) return;
      _fail(errorText, spinner);
    }
    _notify();
  }

  Future<PagedResult<T>> _fetchSafe(int target) async {
    try {
      return await fetch(target, pageSize);
    } on AppException catch (e) {
      // Halaman di luar jangkauan (data berkurang): kembali ke halaman 1.
      if (e.code == 'page_out_of_range' && target > 0) {
        return fetch(0, pageSize);
      }
      rethrow;
    }
  }

  void _fail(String message, bool spinner) {
    isLoading = false;
    if (!spinner && items.isNotEmpty) {
      onBackgroundError?.call(message);
    } else {
      error = message;
    }
  }

  Future<void> goTo(int target) async {
    if (target == page || target < 0 || target >= totalPages) return;
    await load(page: target);
  }

  Future<void> refresh() => load(spinner: false);

  void dispose() => _disposed = true;

  void _notify() {
    if (!_disposed) onChanged();
  }
}
