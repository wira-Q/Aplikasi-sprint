/// Jumlah kartu per halaman di semua daftar.
const int kPageSize = 5;

/// Satu halaman data beserta total seluruh data, untuk nomor halaman.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<T> items;
  final int total;

  /// Halaman yang diminta, dimulai dari 0.
  final int page;
  final int pageSize;

  int get totalPages => total <= 0 ? 1 : (total + pageSize - 1) ~/ pageSize;
}
