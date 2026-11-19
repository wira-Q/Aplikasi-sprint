import 'package:flutter_test/flutter_test.dart';

import 'package:sprint/main.dart';

void main() {
  testWidgets('Menampilkan pesan jika Supabase belum dikonfigurasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const SprintApp(initError: 'SUPABASE_URL belum diisi.'),
    );

    expect(find.text('SUPABASE_URL belum diisi.'), findsOneWidget);
  });
}
