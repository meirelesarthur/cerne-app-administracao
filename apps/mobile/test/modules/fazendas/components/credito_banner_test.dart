import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/components/credito_banner.dart';

void main() {
  group('CreditoBanner', () {
    testWidgets('renderiza o texto de crédito pré-aprovado sem exceção', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/fazendas',
        routes: [
          GoRoute(
            path: '/fazendas',
            builder: (context, state) => const Scaffold(body: CreditoBanner()),
          ),
          GoRoute(
            path: '/credito',
            builder: (context, state) => const Scaffold(body: Text('Crédito')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: router,
        ),
      );

      expect(find.text('Crédito pré-aprovado'), findsOneWidget);
      expect(find.text('R\$ 480.000,00 disponíveis'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navega para /credito ao tocar', (tester) async {
      final router = GoRouter(
        initialLocation: '/fazendas',
        routes: [
          GoRoute(
            path: '/fazendas',
            builder: (context, state) => const Scaffold(body: CreditoBanner()),
          ),
          GoRoute(
            path: '/credito',
            builder: (context, state) => const Scaffold(body: Text('Crédito')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: router,
        ),
      );

      await tester.tap(find.byType(CreditoBanner));
      await tester.pumpAndSettle();

      expect(find.text('Crédito'), findsOneWidget);
    });
  });
}
