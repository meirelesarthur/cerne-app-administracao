import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_confinamento.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_suprimentos.dart';
import 'package:cerne_app/modules/fazendas/screens/atividades_screen.dart';

import '../../../support/test_viewport.dart';

/// Router mínimo com só as rotas que "Atividades" de fato abre — o toque leva
/// ao painel real (Lei 2: nenhuma ficha genérica própria da lista).
Widget _wrapWithRouter() {
  final router = GoRouter(
    initialLocation: '/atividades',
    routes: [
      GoRoute(
        path: '/atividades',
        builder: (context, state) => const Scaffold(body: AtividadesScreen()),
      ),
      GoRoute(
        path: '/fazendas/dashboards/confinamento',
        builder: (context, state) => const Scaffold(body: DashConfinamento()),
      ),
      GoRoute(
        path: '/fazendas/dashboards/suprimentos',
        builder: (context, state) => const Scaffold(body: DashSuprimentos()),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      theme: buildAppTheme(AppThemeVariant.light),
      routerConfig: router,
    ),
  );
}

void main() {
  group('AtividadesScreen', () {
    testWidgets('lista as atividades e abre o painel real ao tocar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();

      expect(find.text('Atividades'), findsOneWidget);
      expect(find.text('Pesagem do Lote 42'), findsOneWidget);
      expect(find.text('Página 1 de 2'), findsOneWidget);

      // Pesagem é movimentação de rebanho: vai para o painel de Confinamento,
      // não para uma ficha genérica.
      await tester.tap(find.text('Pesagem do Lote 42').first);
      await tester.pumpAndSettle();

      expect(find.text('Rebanho e confinamento'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pagina as atividades e mantém a página ao voltar do painel', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pumpAndSettle();

      expect(find.text('Pesagem do Lote 42'), findsOneWidget);
      expect(find.text('Transferência de lote'), findsNothing);

      await tester.tap(find.byTooltip('Próxima página'));
      await tester.pumpAndSettle();

      expect(find.text('Página 2 de 2'), findsOneWidget);
      expect(find.text('Pesagem do Lote 42'), findsNothing);
      expect(find.text('Transferência de lote'), findsOneWidget);

      // Transferência de lote também é confinamento.
      await tester.tap(find.text('Transferência de lote'));
      await tester.pumpAndSettle();

      // O painel real cobre a lista — a régua de paginação sai da árvore
      // enquanto está aberto. A invariante que o teste protege — paginar e
      // abrir um item não zera a página — se verifica no retorno.
      expect(find.text('Rebanho e confinamento'), findsOneWidget);
      expect(find.text('Página 2 de 2'), findsNothing);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('Página 2 de 2'), findsOneWidget);
      expect(find.text('Transferência de lote'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
