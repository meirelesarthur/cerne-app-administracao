import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/screens/extrato_screen.dart';

import '../../support/test_viewport.dart';

Widget _wrap() => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: const Scaffold(body: ExtratoScreen()),
  ),
);

void main() {
  group('ExtratoScreen', () {
    testWidgets('renderiza saldo e a lista completa de movimentações', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Extrato'), findsOneWidget);
      expect(find.text('R\$ 128.450,32'), findsOneWidget);
      expect(find.textContaining('Venda de gado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtro "Entradas" mostra só lançamentos de entrada', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entradas'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Venda de gado'), findsOneWidget);
      expect(find.textContaining('Folha de pagamento'), findsNothing);
    });

    testWidgets('filtro "Saídas" mostra só lançamentos de saída', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Saídas'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Folha de pagamento'), findsOneWidget);
      expect(find.textContaining('Venda de gado'), findsNothing);
    });

    testWidgets('tocar em um lançamento abre o comprovante', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Venda de gado'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da transação'), findsOneWidget);
    });
  });
}
