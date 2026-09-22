import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/armazem/screens/unidades_screen.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('UnidadesScreen', () {
    testWidgets('lista todas as unidades de armazenagem', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const UnidadesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Unidades'), findsOneWidget);
      expect(find.text('Silo 01 — Soja'), findsOneWidget);
      expect(find.text('Silo 02 — Milho'), findsOneWidget);
      expect(find.text('Galpão de insumos'), findsOneWidget);
      expect(find.text('Câmara fria — Vacinas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar numa unidade abre o detalhe', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const UnidadesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Câmara fria — Vacinas'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da unidade'), findsOneWidget);
    });
  });
}
