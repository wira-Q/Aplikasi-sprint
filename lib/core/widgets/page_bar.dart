import 'package:flutter/material.dart';

/// Tiga model tampilan nomor halaman.
enum PageBarStyle {
  /// Bulat bergaris abu, angka aktif berlatar biru penuh.
  circle,

  /// Tanpa garis, angka aktif berlatar kotak biru bersudut membulat.
  flat,

  /// Kotak bergaris abu, angka aktif bergaris dan berangka biru.
  square,
}

/// Nomor halaman: ‹ 1 2 3 … 9 ›. Tidak tampil jika hanya ada satu halaman.
/// [page] dimulai dari 0; yang tampil ke pengguna dimulai dari 1.
class PageBar extends StatelessWidget {
  const PageBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageSelected,
    this.enabled = true,
    this.activeColor = const Color(0xFF2862E8),
    this.style = PageBarStyle.circle,
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onPageSelected;
  final bool enabled;
  final Color activeColor;
  final PageBarStyle style;

  static const double _size = 38;
  static const Color _border = Color(0xFFD4D7DD);
  static const Color _text = Color(0xFF555B66);

  /// Halaman pertama, terakhir, dan sekitar halaman aktif. null = titik-titik.
  List<int?> _tokens() {
    final pages = <int>{
      0,
      totalPages - 1,
      page - 1,
      page,
      page + 1,
    }.where((p) => p >= 0 && p < totalPages).toList()..sort();
    final out = <int?>[];
    int? previous;
    for (final p in pages) {
      if (previous != null && p - previous > 1) out.add(null);
      out.add(p);
      previous = p;
    }
    return out;
  }

  BoxDecoration _decoration({required bool selected, required bool arrow}) {
    switch (style) {
      case PageBarStyle.circle:
        return BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? activeColor : Colors.white,
          border: Border.all(
            color: selected ? activeColor : _border,
            width: 1.6,
          ),
        );
      case PageBarStyle.flat:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? activeColor : Colors.transparent,
        );
      case PageBarStyle.square:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(
            color: selected ? activeColor : _border,
            width: selected ? 1.6 : 1.4,
          ),
        );
    }
  }

  Color _textColor({required bool selected}) {
    if (!selected) return _text;
    return style == PageBarStyle.square ? activeColor : Colors.white;
  }

  BorderRadius get _inkRadius => style == PageBarStyle.circle
      ? BorderRadius.circular(_size)
      : BorderRadius.circular(style == PageBarStyle.flat ? 10 : 8);

  Widget _cell({
    required Widget child,
    VoidCallback? onTap,
    bool selected = false,
    bool arrow = false,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: _inkRadius,
        onTap: onTap,
        child: Container(
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: _decoration(selected: selected, arrow: arrow),
          child: child,
        ),
      ),
    );
  }

  Widget _arrow(IconData icon, bool active, VoidCallback onTap) {
    return _cell(
      arrow: true,
      onTap: active ? onTap : null,
      child: Icon(
        icon,
        size: 20,
        color: active ? _text : const Color(0xFFBFC3CB),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final canPrev = enabled && page > 0;
    final canNext = enabled && page < totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _arrow(Icons.chevron_left, canPrev, () => onPageSelected(page - 1)),
          for (final token in _tokens())
            if (token == null)
              const SizedBox(
                width: 22,
                child: Text(
                  '…',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              _cell(
                selected: token == page,
                onTap: (enabled && token != page)
                    ? () => onPageSelected(token)
                    : null,
                child: Text(
                  '${token + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: token == page
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: _textColor(selected: token == page),
                  ),
                ),
              ),
          _arrow(Icons.chevron_right, canNext, () => onPageSelected(page + 1)),
        ],
      ),
    );
  }
}
