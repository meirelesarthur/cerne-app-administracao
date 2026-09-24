import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/components/bottom_tab_bar.dart';
import 'package:cerne_app/shell/components/context_tabs.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/ui/farm_selector.dart';
import 'package:cerne_app/ui/module_tile.dart';
import 'package:cerne_app/ui/pressable.dart';
import 'package:cerne_app/ui/search_field.dart';
import 'package:cerne_app/ui/segmented_tabs.dart';

import '../support/router_test_harness.dart';
import '../support/test_viewport.dart';

late RouterTestHarness harness;

/// `pumpAndSettle` só continua pumpando enquanto frames são agendados — um
/// `Future.delayed` isolado (SimulatedLoad/RiseIn da HubHomeScreen, renderizada
/// por padrão em `/inicio`) não agenda frame algum até disparar, então pode
/// ficar pendente se não avançarmos o relógio explicitamente antes. Chamar
/// sempre que o teste passar por `/inicio`.
Future<void> _settleHubTimers(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 1));

void main() {
  setUp(() {
    harness = RouterTestHarness(profile: UserAccessProfile.administration);
    addTearDown(() => harness.dispose());
    harness.router.go('/inicio');
  });

  group('appRouter', () {
    testWidgets(
      'seletor de fazenda só aparece onde a fazenda muda o conteúdo',
      (tester) async {
        await setTallSurface(tester);
        harness.router.go('/fazendas/visao-geral');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();
        expect(find.byType(AppFarmSelector), findsOneWidget);

        harness.router.go('/inicio');
        await _settleHubTimers(tester);
        await tester.pumpAndSettle();
        expect(find.byType(AppFarmSelector), findsNothing);
      },
    );

    testWidgets('"/" redireciona para a central do perfil autenticado', (
      tester,
    ) async {
      await setTallSurface(tester);
      harness.router.go('/');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Radar da fazenda'), findsOneWidget);
      expect(find.byType(AppContextTabs), findsOneWidget);
      expect(find.byType(AppBottomTabBar), findsOneWidget);
    });

    testWidgets(
      'tocar a busca da home administrativa abre a descoberta otimizada',
      (tester) async {
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(AppSearchField));
        await tester.pumpAndSettle();

        expect(find.text('Seus Produtos'), findsOneWidget);
        expect(find.text('Mais acessados'), findsOneWidget);
        expect(find.text('Histórico'), findsOneWidget);
        expect(find.text('Boa tarde,'), findsNothing);
      },
    );

    testWidgets('deep-link "/bank/extrato" abre o módulo Bank na aba Extrato', (
      tester,
    ) async {
      await setTallSurface(tester);
      harness.router.go('/bank/extrato');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Tela real do módulo Bank (F4.4) — a versão placeholder (F3) mostrava
      // apenas "$tabLabel — módulo chega na F4". "Extrato" sozinho é ambíguo
      // (também é o rótulo da aba em AppContextTabs).
      expect(find.text('Extrato'), findsWidgets);
      expect(find.textContaining('Saldo disponível'), findsOneWidget);
    });

    testWidgets(
      'deep-link "/fazendas" mostra as ContextTabs do módulo correto (não as do Início)',
      (tester) async {
        // Regressão: o moduleId ativo do ShellLayout era derivado de
        // `state.pathParameters['moduleId']`, que nunca existe (nenhuma rota usa
        // ':moduleId' — todas são segmentos literais) — sempre caía no fallback
        // 'inicio', então header/tabs/dock nunca refletiam o módulo real.
        await setTallSurface(tester);
        harness.router.go('/fazendas');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        // Abas administrativas de Fazendas — a central agora entrega cada
        // domínio no primeiro toque, sem a camada intermediária de grupos.
        final contextTabs = find.byType(AppContextTabs);
        for (final aba in ['Visão geral', 'Painéis', 'Consultas']) {
          expect(
            find.descendant(of: contextTabs, matching: find.text(aba)),
            findsOneWidget,
            reason: aba,
          );
        }
        expect(
          find.descendant(of: contextTabs, matching: find.text('OS')),
          findsNothing,
        );
        expect(
          find.descendant(of: contextTabs, matching: find.text('Fazendas')),
          findsNothing,
        );
        expect(
          find.descendant(of: contextTabs, matching: find.text('Financeiro')),
          findsNothing,
        );
        expect(find.text('Central de gestão'), findsNothing);
        Rect aba(String rotulo) => tester.getRect(
          find.ancestor(
            of: find.descendant(of: contextTabs, matching: find.text(rotulo)),
            matching: find.byType(AppPressable),
          ),
        );
        expect(aba('Visão geral').width, closeTo(aba('Painéis').width, 0.1));
        expect(aba('Visão geral').width, closeTo(aba('Consultas').width, 0.1));
        // "/fazendas" abre a Visão geral, com um grupo por painel.
        expect(find.text('Radar da fazenda'), findsOneWidget);
        expect(find.text('Resultado'), findsOneWidget);

        // A aba Painéis traz os painéis de decisão completos.
        await tester.tap(
          find.descendant(of: contextTabs, matching: find.text('Painéis')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Painéis de decisão'), findsOneWidget);
        expect(find.text('Rebanho e confinamento'), findsOneWidget);
        // Abas do Início não devem aparecer.
        expect(find.text('Apps'), findsNothing);
        expect(find.text('Carteira'), findsNothing);
      },
    );

    testWidgets(
      'aba Consultas traz a OS primeiro, junto das consultas, e abre a consulta gerencial',
      (tester) async {
        await setTallSurface(tester);
        harness.router.go('/fazendas/administracao');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        final contextTabs = find.byType(AppContextTabs);
        await tester.tap(
          find.descendant(of: contextTabs, matching: find.text('Consultas')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Central de gestão'), findsNothing);
        expect(find.text('Consultas gerenciais'), findsOneWidget);
        expect(find.text('Exportar log de estoque'), findsOneWidget);
        // Ordem de Serviço + Apontamentos + as 10 consultas e auditorias.
        expect(find.byType(AppModuleTile), findsNWidgets(12));
        final primeiro = tester.widget<AppModuleTile>(
          find.byType(AppModuleTile).first,
        );
        expect(primeiro.label, 'Ordem de Serviço');

        await tester.tap(find.text('Consultas gerenciais'));
        await tester.pumpAndSettle();

        expect(find.text('Consultas Gerenciais'), findsOneWidget);
        expect(find.byType(AppContextTabs), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      // A aba de contexto não aponta mais para cá (ver aba "Ordens de
      // Serviço" abaixo), mas a rota continua servindo o link "Ver todas" da
      // home administrativa ("Atividades recentes").
      '/fazendas/atividades continua acessível e não repete o título da central administrativa',
      (tester) async {
        await setTallSurface(tester);
        harness.router.go('/fazendas/atividades');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(find.text('Atividades'), findsWidgets);
        expect(find.text('Central de gestão'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'OS abre pelo primeiro ladrilho de Consultas, com filtro e criação',
      (tester) async {
        await setTallSurface(tester);
        harness.router.go('/fazendas');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        final contextTabs = find.byType(AppContextTabs);
        await tester.tap(
          find.descendant(of: contextTabs, matching: find.text('Consultas')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AppModuleTile).first);
        await tester.pumpAndSettle();

        // Lista as OS da fazenda, com o "+" de criar na faixa do topo.
        expect(find.byTooltip('Criar OS'), findsOneWidget);
        expect(find.text('Reparo de cerca do Talhão 04'), findsOneWidget);
        expect(
          find.text('Construção de bebedouro no Piquete 07'),
          findsOneWidget,
        );
        expect(find.text('Confinamento'), findsNothing);
        expect(find.text('Pecuária'), findsNothing);
        expect(find.text('Agricultura'), findsNothing);
        expect(find.text('Reprodução'), findsNothing);
        expect(find.text('Gestão de Frota'), findsNothing);
        expect(find.text('Sincronizar aplicativo'), findsNothing);
        expect(tester.takeException(), isNull);

        // Filtro por status: só a OS aguardando permanece.
        await tester.tap(
          find.descendant(
            of: find.byType(AppSegmentedTabs),
            matching: find.text('Aguardando'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Reparo de cerca do Talhão 04'), findsOneWidget);
        expect(
          find.text('Construção de bebedouro no Piquete 07'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'trocar de aba administrativa preserva o header (Silvio Ventura continua visível)',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await _settleHubTimers(tester);
        await tester.pumpAndSettle();

        expect(find.text('Silvio Ventura'), findsOneWidget);

        await tester.tap(find.text('Carteira').first);
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.text('Silvio Ventura'), findsOneWidget);
        expect(find.text('Resumo da sua conta GB Bank.'), findsOneWidget);
        expect(find.byType(AppBottomTabBar), findsOneWidget);
      },
    );

    testWidgets('deep link sem sessão retorna direto ao login', (tester) async {
      // Regressão: o login (`/login`) é a porta de entrada real do
      // protótipo — sem sessão, qualquer rota protegida cai nele, sem passar
      // por uma tela de seleção de ambiente/perfil.
      harness.dispose();
      harness = RouterTestHarness();
      harness.router.go('/fazendas/dashboards/financeiro');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('ENTRAR'), findsOneWidget);
      expect(find.text('Acesso administrativo'), findsOneWidget);
    });

    testWidgets('rota inicial sem navegação explícita é o login', (
      tester,
    ) async {
      harness.dispose();
      harness = RouterTestHarness();

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('ENTRAR'), findsOneWidget);
      expect(find.text('Acesso administrativo'), findsOneWidget);
    });
  });
}
