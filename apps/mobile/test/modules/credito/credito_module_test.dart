import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/credito/credito_module.dart';

Widget _wrap(String initialLocation) {
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
  group('buildCreditoModuleRoute', () {
    testWidgets('"/credito" abre a Home do módulo', (tester) async {
      await tester.pumpWidget(_wrap('/credito'));
      await tester.pumpAndSettle();
      expect(find.text('Simulador rápido'), findsOneWidget);
    });

    testWidgets('"/credito/propostas" abre a listagem de propostas', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap('/credito/propostas'));
      await tester.pumpAndSettle();
      expect(find.text('Total solicitado'), findsOneWidget);
    });

    testWidgets('"/credito/proposta/:id" abre o detalhe com o id da rota', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap('/credito/proposta/prop2'));
      await tester.pumpAndSettle();
      expect(find.text('Investimento — Máquinas'), findsWidgets);
      expect(find.text('Aprovada'), findsWidgets);
    });

    testWidgets('"/credito/simular" abre a Home com scrollToSimulador', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap('/credito/simular'));
      await tester.pumpAndSettle();
      expect(find.text('Simulador rápido'), findsOneWidget);
    });

    testWidgets('"/credito/contratos" abre a tela de contratos', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap('/credito/contratos'));
      await tester.pumpAndSettle();
      expect(find.text('Contratos'), findsOneWidget);
    });

    testWidgets('"/credito/ajuda" abre a tela de ajuda', (tester) async {
      await tester.pumpWidget(_wrap('/credito/ajuda'));
      await tester.pumpAndSettle();
      expect(find.text('Ajuda'), findsOneWidget);
    });
  });
}
