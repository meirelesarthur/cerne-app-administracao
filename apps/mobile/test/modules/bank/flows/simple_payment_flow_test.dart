import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/screens/flows/simple_payment_flow.dart';

import '../../../support/test_viewport.dart';
import '../../../helpers/cta_finder.dart';

GoRouter _router(Widget flow) => GoRouter(
  initialLocation: '/bank/pagamentos',
  routes: [
    GoRoute(path: '/bank/pagamentos', builder: (context, state) => flow),
    GoRoute(
      path: '/bank',
      builder: (context, state) => const Text('Bank home destino'),
    ),
  ],
);

Widget _wrap(Widget flow) => ProviderScope(
  child: MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: _router(flow),
  ),
);

void main() {
  group('SimplePaymentFlow · transferir', () {
    testWidgets('formulário exige banco, agência, conta e valor', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        _wrap(SimplePaymentFlow(kind: PaymentKind.transferir, onExit: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transferir'), findsOneWidget);
      expect(find.text('Banco de destino'), findsOneWidget);
      expect(find.text('Agência'), findsOneWidget);
      expect(find.text('Conta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fluxo completo: preencher → revisar → confirmar → sucesso', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        _wrap(SimplePaymentFlow(kind: PaymentKind.transferir, onExit: () {})),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banco do Brasil').last);
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '0001'); // Agência
      await tester.enterText(fields.at(1), '12345-6'); // Conta
      await tester.enterText(fields.at(2), '500,00'); // Valor
      await tester.pumpAndSettle();

      await tester.tap(findCta('Revisar'));
      await tester.pumpAndSettle();

      expect(find.text('Banco do Brasil'), findsOneWidget);

      await tester.tap(findCta('Confirmar transferência'));
      await tester.pumpAndSettle();

      expect(find.text('Transferência enviada'), findsOneWidget);

      await tester.tap(find.text('Voltar ao Bank'));
      await tester.pumpAndSettle();

      expect(find.text('Bank home destino'), findsOneWidget);
    });
  });

  group('SimplePaymentFlow · cobrar', () {
    testWidgets('apenas valor é obrigatório', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        _wrap(SimplePaymentFlow(kind: PaymentKind.cobrar, onExit: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cobrar via Pix'), findsOneWidget);

      // Campos do formulário "cobrar": Pagador (opcional), Valor, Descrição (opcional).
      await tester.enterText(find.byType(TextFormField).at(1), '75,00');
      await tester.pumpAndSettle();

      await tester.tap(findCta('Revisar'));
      await tester.pumpAndSettle();

      await tester.tap(findCta('Gerar cobrança'));
      await tester.pumpAndSettle();

      expect(find.text('Cobrança criada'), findsOneWidget);
    });
  });

  group('SimplePaymentFlow · onBack', () {
    testWidgets('voltar no formulário dispara onExit', (tester) async {
      await setTallSurface(tester);
      var exited = false;
      await tester.pumpWidget(
        _wrap(
          SimplePaymentFlow(
            kind: PaymentKind.boleto,
            onExit: () => exited = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pump();

      expect(exited, isTrue);
    });
  });
}
