import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/screens/pagamentos_screen.dart';

import '../../support/test_viewport.dart';

Widget _wrap({PagamentosFlow? initialFlow}) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: PagamentosScreen(initialFlow: initialFlow)),
  ),
);

void main() {
  group('PagamentosScreen', () {
    testWidgets('renderiza o hub com as 4 ações sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Pagamentos'), findsOneWidget);
      expect(find.text('Todas as opções'), findsOneWidget);
      // Cada ação aparece 2x: na QuickAction do topo e na lista "Todas as opções".
      expect(find.text('Pagar boleto'), findsWidgets);
      expect(find.text('Transferir'), findsWidgets);
      expect(find.text('Cobrar'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar em "Transferir" abre o SimplePaymentFlow', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transferir').first);
      await tester.pumpAndSettle();

      expect(find.text('Banco de destino'), findsOneWidget);
    });

    testWidgets(
      'initialFlow=pix abre direto no PixFlow (deep-link /bank/pix)',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(_wrap(initialFlow: PagamentosFlow.pix));
        await tester.pumpAndSettle();

        expect(find.text('Enviar para uma chave'), findsOneWidget);
      },
    );

    testWidgets('sair do fluxo via botão voltar retorna ao hub', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(initialFlow: PagamentosFlow.pix));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('Pagamentos'), findsOneWidget);
      expect(find.text('Todas as opções'), findsOneWidget);
    });
  });
}
