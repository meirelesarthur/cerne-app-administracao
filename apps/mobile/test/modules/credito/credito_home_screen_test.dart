import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/credito/credito_module.dart';

import '../../support/test_viewport.dart';

Widget _wrap({String initialLocation = '/credito'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [buildCreditoModuleRoute()],
  );
  return MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: router,
  );
}

void main() {
  group('CreditoHomeScreen', () {
    testWidgets('renderiza hero, simulador e linhas sem exceção', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('R\$ 480.000,00'), findsOneWidget);
      expect(find.text('Simulador rápido'), findsOneWidget);
      expect(find.text('Linhas disponíveis'), findsOneWidget);
      expect(find.text('Minhas propostas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('trocar valor/prazo do simulador atualiza a parcela estimada', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      // Seleção padrão: R$ 480.000 / 24 meses -> R$ 23.410,66.
      expect(find.text('R\$ 23.410,66'), findsOneWidget);

      await tester.tap(find.text('R\$ 100.000'));
      await tester.pumpAndSettle();
      expect(find.text('R\$ 4.877,22'), findsOneWidget);

      await tester.tap(find.text('12 meses'));
      await tester.pumpAndSettle();
      expect(find.text('R\$ 9.054,17'), findsOneWidget);
    });

    testWidgets('"Enviar proposta" navega para /credito/propostas', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enviar proposta'));
      await tester.pumpAndSettle();

      expect(find.text('Minhas propostas'), findsWidgets);
      expect(find.text('Total solicitado'), findsOneWidget);
    });

    testWidgets(
      'tocar em uma linha de crédito abre o bottom sheet com a descrição',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(_wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Custeio Safra 25/26').first);
        await tester.pumpAndSettle();

        // A descrição aparece na linha da lista e de novo no bottom sheet aberto.
        expect(
          find.text(
            'Capital de giro para insumos, sementes e defensivos do ciclo atual.',
          ),
          findsWidgets,
        );

        await tester.tap(find.text('Simular esta linha'));
        await tester.pumpAndSettle();

        expect(find.text('Simulador rápido'), findsOneWidget);
      },
    );

    testWidgets('rota /credito/simular rola até o simulador sem exceção', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(initialLocation: '/credito/simular'));
      await tester.pumpAndSettle();

      expect(find.text('Simulador rápido'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
