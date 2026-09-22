import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/credito/credito_module.dart';

import '../../support/test_viewport.dart';

Widget _wrap() {
  final router = GoRouter(
    initialLocation: '/credito/propostas',
    routes: [buildCreditoModuleRoute()],
  );
  return MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: router,
  );
}

void main() {
  group('PropostasScreen', () {
    testWidgets('renderiza KPIs e todas as propostas sem exceção', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Minhas propostas'), findsOneWidget);
      expect(find.text('Total solicitado'), findsOneWidget);
      expect(find.text('R\$ 526.500,00'), findsOneWidget);
      expect(find.text('Aprovado'), findsOneWidget);

      expect(find.text('Custeio Safra 25/26'), findsOneWidget);
      expect(find.text('Investimento — Máquinas'), findsOneWidget);
      expect(find.text('CPR Financeira'), findsOneWidget);
      expect(find.text('Consórcio Agro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar em uma proposta navega para o detalhe correspondente', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('CPR Financeira'));
      await tester.pumpAndSettle();

      // Detalhe da prop3 (CPR Financeira, contratada) mostra o header com o nome da linha.
      // "Contratada" aparece no badge de status e na timeline (mesmo padrão de
      // proposta_detalhe_screen_test.dart).
      expect(find.text('CPR Financeira'), findsWidgets);
      expect(find.text('Contratada'), findsWidgets);
    });
  });
}
