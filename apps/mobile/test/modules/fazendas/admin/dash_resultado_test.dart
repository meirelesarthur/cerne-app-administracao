import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/admin_dashboard.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_resultado.dart';
import 'package:cerne_app/modules/fazendas/mocks/dashboards_mocks.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashResultado', () {
    testWidgets('renderiza os blocos financeiros sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashResultado()));
      await tester.pumpAndSettle();

      expect(find.text('Resultado'), findsWidgets);
      expect(find.text('A Receber'), findsOneWidget);
      expect(find.text('Receita × custo'), findsOneWidget);
      expect(find.text('Despesa por centro de custo'), findsOneWidget);
      expect(find.text('Composição do custo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('os dashIds antigos continuam resolvendo aqui', (tester) async {
      for (final dashId in ['resultado', 'financeiro', 'pecuaria']) {
        await setTallSurface(tester);
        await tester.pumpWidget(_wrap(buildAdminDashboard(dashId)));
        await tester.pumpAndSettle();

        expect(
          find.byType(DashResultado),
          findsOneWidget,
          reason: 'dashId "$dashId" deveria abrir o painel Resultado',
        );
      }
    });
  });

  group('mocks de resultado', () {
    test('cartões e série descrevem os mesmos números', () {
      final atual = resultadoMeses.last;
      final anterior = resultadoMeses[resultadoMeses.length - 2];

      final receita = pecuariaFinanceiro.firstWhere(
        (c) => c.label == 'Receita',
      );
      final margem = pecuariaFinanceiro.firstWhere((c) => c.label == 'Margem');

      expect(receita.value, formatMilhares(atual.receita));
      expect(receita.spark.last, atual.receita);
      expect(
        receita.delta,
        closeTo(((atual.receita / anterior.receita) - 1) * 100, 0.001),
      );

      // Margem é derivada, não digitada: receita − custo, sempre.
      expect(margem.value, formatMilhares(atual.receita - atual.custo));
    });

    test('a barra por centro de custo fecha com o custo do mês', () {
      final total = centrosCusto.fold<double>(0, (sum, c) => sum + c.value);

      expect(total, resultadoMeses.last.custo);
      // Ordenada do maior para o menor — é como se lê a decisão.
      expect(centrosCusto.first.value, greaterThan(centrosCusto.last.value));
    });
  });
}
