import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/screens/cartoes_screen.dart';
import 'package:cerne_app/ui/toggle_switch.dart';

import '../../support/test_viewport.dart';

GoRouter _router() => GoRouter(
  initialLocation: '/bank/cartoes',
  routes: [
    GoRoute(
      path: '/bank/cartoes',
      builder: (context, state) => const CartoesScreen(),
    ),
    GoRoute(
      path: '/bank/limites',
      builder: (context, state) => const Text('Limites destino'),
    ),
  ],
);

Widget _wrap() => ProviderScope(
  child: MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: _router(),
  ),
);

void main() {
  group('CartoesScreen', () {
    testWidgets('renderiza cartão, limite e ações sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Cartões'), findsOneWidget);
      expect(find.text('ARTHUR M'), findsOneWidget);
      expect(find.text('Bloquear temporariamente'), findsOneWidget);
      expect(find.text('Segunda via'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bloquear o cartão exibe o banner de aviso', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Cartão bloqueado temporariamente'),
        findsNothing,
      );

      await tester.tap(find.byType(AppToggleSwitch));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Cartão bloqueado temporariamente'),
        findsOneWidget,
      );
    });

    testWidgets('"Segunda via" abre o bottom sheet "Em desenvolvimento"', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Segunda via'));
      await tester.pumpAndSettle();

      expect(find.text('Segunda via do cartão'), findsOneWidget);
      expect(find.text('Em desenvolvimento'), findsOneWidget);

      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();

      expect(find.text('Segunda via do cartão'), findsNothing);
    });

    testWidgets('"Ver limites e faixas" navega para Limites', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver limites e faixas'));
      await tester.pumpAndSettle();

      expect(find.text('Limites destino'), findsOneWidget);
    });
  });
}
