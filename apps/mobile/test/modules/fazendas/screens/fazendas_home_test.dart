import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/mocks/dashboards_mocks.dart';
import 'package:cerne_app/modules/fazendas/screens/fazendas_home.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../support/test_viewport.dart';

void main() {
  group('FazendasHome', () {
    testWidgets(
      'visão gerencial mostra resumo da safra e atividades recentes',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: buildAppTheme(AppThemeVariant.light),
              home: const Scaffold(body: FazendasHome()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Resumo da safra'), findsOneWidget);
        expect(find.text('Atividades recentes'), findsOneWidget);
        expect(find.text('Crédito pré-aprovado'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('a torre de controle traz um bloco de cada painel', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: FazendasHome()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Alerta acionável no topo, antes de qualquer gráfico.
      expect(find.text('vencidos'), findsOneWidget);
      expect(find.text(FinanceiroKpis.atrasados), findsOneWidget);

      // Um bloco por painel — Resultado, Confinamento, Ativos e Uso.
      expect(find.text('Resultado'), findsWidgets);
      expect(find.text('Ocupação e GMD'), findsOneWidget);
      expect(find.text('Despesa por centro de custo'), findsOneWidget);
      expect(find.text('Patrimônio por categoria'), findsOneWidget);
      expect(find.text('Adoção por fazenda'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('não repete os cartões que vivem no painel Resultado', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: FazendasHome()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // A Home exibia Receita/Custo/Margem com exatamente os mesmos valores do
      // painel — a duplicação que motivou a auditoria. Aqui esses números só
      // aparecem na curva; os cartões ficam no painel.
      // Ver docs/ESTEIRA-DASHBOARDS-ADM.md, achado A.
      expect(find.byType(AppDashboardCard), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
