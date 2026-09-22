import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/armazem/screens/movimentacoes_screen.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('MovimentacoesScreen', () {
    testWidgets('lista todas as movimentações mockadas', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const MovimentacoesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Movimentações'), findsOneWidget);
      expect(find.text('Soja em grão'), findsOneWidget);
      expect(find.text('Ração bovina'), findsOneWidget);
      expect(find.text('Fertilizante NPK'), findsOneWidget);
      expect(find.text('Vacina febre aftosa'), findsOneWidget);
      expect(find.text('Milho em grão'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar numa movimentação abre o detalhe', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const MovimentacoesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Soja em grão'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da movimentação'), findsOneWidget);
    });
  });
}
