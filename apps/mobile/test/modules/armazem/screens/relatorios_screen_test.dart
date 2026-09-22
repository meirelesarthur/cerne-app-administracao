import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/armazem/screens/relatorios_screen.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('RelatoriosScreen', () {
    testWidgets('lista os relatórios com período e disponibilidade', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const RelatoriosScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Relatórios'), findsOneWidget);
      expect(find.text('Ocupação por unidade'), findsOneWidget);
      expect(find.text('Julho/2026'), findsOneWidget);
      expect(find.text('Perdas e quebras de estoque'), findsOneWidget);
      expect(find.text('Disponível'), findsNWidgets(2));
      expect(find.text('Indisponível'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
