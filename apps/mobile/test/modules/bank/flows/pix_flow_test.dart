import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/screens/flows/pix_flow.dart';

import '../../../support/test_viewport.dart';
import '../../../helpers/cta_finder.dart';

GoRouter _router(VoidCallback onExit) => GoRouter(
  initialLocation: '/bank/pagamentos',
  routes: [
    GoRoute(
      path: '/bank/pagamentos',
      builder: (context, state) => PixFlow(onExit: onExit),
    ),
    GoRoute(
      path: '/bank',
      builder: (context, state) => const Text('Bank home destino'),
    ),
    GoRoute(
      path: '/bank/extrato',
      builder: (context, state) => const Text('Extrato destino'),
    ),
  ],
);

Widget _wrap(VoidCallback onExit) => ProviderScope(
  child: MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: _router(onExit),
  ),
);

void main() {
  group('PixFlow', () {
    testWidgets('renderiza o passo 1 (chave) com contatos frequentes', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(() {}));
      await tester.pumpAndSettle();

      expect(find.text('Pix'), findsOneWidget);
      expect(find.text('Enviar para uma chave'), findsOneWidget);
      expect(find.text('Contatos frequentes'), findsOneWidget);
      expect(find.textContaining('Agropecuária Vale Verde'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('onBack no passo 1 dispara onExit', (tester) async {
      await setTallSurface(tester);
      var exited = false;
      await tester.pumpWidget(_wrap(() => exited = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pump();

      expect(exited, isTrue);
    });

    testWidgets('fluxo completo: contato → valor → revisão → sucesso', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(() {}));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Agropecuária Vale Verde'));
      await tester.pumpAndSettle();

      expect(find.text('Valor do Pix'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, '150,00');
      await tester.pumpAndSettle();

      await tester.tap(findCta('Revisar'));
      await tester.pumpAndSettle();

      expect(find.text('Revisar Pix'), findsOneWidget);
      expect(find.text('R\$ 150,00'), findsWidgets);

      await tester.tap(findCta('Confirmar Pix'));
      await tester.pumpAndSettle();

      expect(find.text('Pix enviado'), findsOneWidget);

      await tester.tap(find.text('Voltar ao Bank'));
      await tester.pumpAndSettle();

      expect(find.text('Bank home destino'), findsOneWidget);
    });

    testWidgets(
      'valor vazio mantém "Revisar" desabilitado (toque não avança)',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(_wrap(() {}));
        await tester.pumpAndSettle();

        await tester.tap(find.textContaining('Agropecuária Vale Verde'));
        await tester.pumpAndSettle();

        await tester.tap(findCta('Revisar'), warnIfMissed: false);
        await tester.pumpAndSettle();

        // Sem valor preenchido, o botão primário está desabilitado — o toque
        // não avança para a revisão.
        expect(find.text('Revisar Pix'), findsNothing);
        expect(find.text('Valor do Pix'), findsOneWidget);
      },
    );
  });
}
