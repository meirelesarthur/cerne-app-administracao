import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/screens/bank_home_screen.dart';

import '../../support/test_viewport.dart';

GoRouter _router() => GoRouter(
  initialLocation: '/bank',
  routes: [
    GoRoute(path: '/bank', builder: (context, state) => const BankHomeScreen()),
    GoRoute(
      path: '/bank/pagamentos',
      builder: (context, state) => const Text('Pagamentos destino'),
    ),
    GoRoute(
      path: '/bank/extrato',
      builder: (context, state) => const Text('Extrato destino'),
    ),
    GoRoute(
      path: '/bank/cartoes',
      builder: (context, state) => const Text('Cartoes destino'),
    ),
    GoRoute(
      path: '/credito',
      builder: (context, state) => const Text('Credito destino'),
    ),
  ],
);

Widget _wrap() => ProviderScope(
  child: MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: _router(),
  ),
);

/// `SimulatedLoad`/`RiseIn` usam `Future.delayed` isolado — não agenda frame
/// algum até disparar; avança o relógio antes de `pumpAndSettle` (mesmo padrão
/// de `app_router_test.dart`).
Future<void> _settleTimers(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 1));

void main() {
  group('BankHomeScreen', () {
    testWidgets('renderiza saldo, cartão e movimentações sem exceção', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await _settleTimers(tester);
      await tester.pumpAndSettle();

      expect(find.text('R\$ 128.450,32'), findsOneWidget);
      expect(find.text('Meu cartão'), findsOneWidget);
      expect(find.text('Últimas movimentações'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ação rápida Pix navega para Pagamentos', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await _settleTimers(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pix'));
      await tester.pumpAndSettle();

      expect(find.text('Pagamentos destino'), findsOneWidget);
    });

    testWidgets('cartão corporativo navega para Cartões', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await _settleTimers(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Limite disponível'));
      await tester.pumpAndSettle();

      expect(find.text('Cartoes destino'), findsOneWidget);
    });

    testWidgets('deep-link de Crédito navega para o módulo Crédito', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await _settleTimers(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Antecipe recebíveis da safra'));
      await tester.pumpAndSettle();

      expect(find.text('Credito destino'), findsOneWidget);
    });

    testWidgets('"Ver extrato" navega para o Extrato', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await _settleTimers(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver extrato'));
      await tester.pumpAndSettle();

      expect(find.text('Extrato destino'), findsOneWidget);
    });
  });
}
