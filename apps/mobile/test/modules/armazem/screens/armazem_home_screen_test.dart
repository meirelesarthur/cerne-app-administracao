import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/armazem/screens/armazem_home_screen.dart';

import '../../../support/test_viewport.dart';

GoRouter _buildRouter() => GoRouter(
  initialLocation: '/armazem',
  routes: [
    GoRoute(
      path: '/armazem',
      builder: (context, state) => const Scaffold(body: ArmazemHomeScreen()),
    ),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const Scaffold(body: Text('Marketplace')),
    ),
  ],
);

void main() {
  group('ArmazemHomeScreen', () {
    testWidgets('renderiza KPIs, alertas, unidades e movimentações', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: _buildRouter(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Ocupação total'), findsOneWidget);
      expect(find.text('SKUs em estoque'), findsOneWidget);
      // "Alertas" aparece 2x: rótulo do KpiStatCard + título da seção de alertas.
      expect(find.text('Alertas'), findsNWidgets(2));
      expect(find.text('Vacina febre aftosa abaixo do mínimo'), findsOneWidget);
      expect(find.text('Unidades de armazenagem'), findsOneWidget);
      expect(find.text('Silo 01 — Soja'), findsOneWidget);
      expect(find.text('Movimentações recentes'), findsOneWidget);
      expect(find.text('Soja em grão'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar numa unidade abre o detalhe', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: _buildRouter(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Silo 01 — Soja'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da unidade'), findsOneWidget);
    });

    testWidgets('tocar numa movimentação abre o detalhe', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: _buildRouter(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Soja em grão').last);
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da movimentação'), findsOneWidget);
    });

    testWidgets('CTA "Reponha insumos" navega para o Marketplace', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: _buildRouter(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reponha insumos no Marketplace'));
      await tester.pumpAndSettle();

      expect(find.text('Marketplace'), findsOneWidget);
    });
  });
}
