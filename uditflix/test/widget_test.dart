import 'package:flutter_test/flutter_test.dart';

import 'package:uditflix/main.dart';

void main() {
  testWidgets('UDITflix opens the catalog and content details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('UDITflix'), findsOneWidget);
    expect(find.text('Introducción a Flutter'), findsOneWidget);

    await tester.tap(find.text('Introducción a Flutter'));
    await tester.pumpAndSettle();

    expect(find.text('Ver contenido'), findsOneWidget);
  });
}
