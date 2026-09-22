import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/em_section.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('EmSection', () {
    testWidgets('renderiza o título recebido e o estado "em desenvolvimento"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const EmSection(title: 'Dashboard')));

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Em desenvolvimento'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
