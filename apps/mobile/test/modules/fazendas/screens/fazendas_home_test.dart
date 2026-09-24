import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/fazendas_home.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../support/test_viewport.dart';

void main() {
  group('FazendasHome', () {
    testWidgets(
      'visão geral abre no radar da fazenda e mostra atividades',
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

        // O cabeçalho "Visão geral" (título, fazenda e safra) saiu: a aba e o
        // seletor de fazenda do shell já dizem onde a pessoa está.
        expect(find.text('Visão geral'), findsNothing);
        expect(find.text('Safra 24/25'), findsNothing);
        expect(find.text('Radar da fazenda'), findsOneWidget);
        expect(find.text('Atividades recentes'), findsOneWidget);
        // O banner de crédito (Bank) saiu da visão da fazenda.
        expect(find.text('Crédito pré-aprovado'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('traz um grupo por painel, cada um com "Ver painel"', (
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
      expect(find.text('em contas vencidas'), findsOneWidget);

      // Um grupo por painel de decisão, na ordem da aba Painéis, mais as OS.
      for (final painel in [
        'Resultado',
        'Rebanho e confinamento',
        'Ordens de serviço',
        'Suprimentos',
        'Ativos e depreciação',
        'Adoção e governança',
      ]) {
        expect(find.text(painel), findsOneWidget, reason: painel);
      }
      expect(find.text('Ver painel'), findsNWidgets(5));
      expect(find.text('Ver OS'), findsOneWidget);
      expect(find.text('Ocupação dos currais e ganho de peso'), findsOneWidget);
      expect(find.text('Patrimônio por categoria'), findsOneWidget);
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
