import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

/// Mengizinkan menggeser daftar dengan mouse dan trackpad (bukan hanya
/// sentuhan), supaya tarik-ke-bawah untuk memuat ulang bisa dicoba di Chrome.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };
}
