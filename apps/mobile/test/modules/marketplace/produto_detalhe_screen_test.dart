import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/marketplace/marketplace_module.dart';

import '../../support/test_viewport.dart';

GoRouter _buildRouter({required String location}) => GoRouter(
  initialLocation: location,
  routes: [buildMarketplaceModuleRoute()],
);

Widget _wrap(GoRouter router) => MaterialApp.router(
  theme: buildAppTheme(AppThemeVariant.light),
  routerConfig: router,
);

void main() {
  group('ProdutoDetalheScreen', () {
    testWidgets('renderiza dados do produto e permite adicionar ao pedido', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        _wrap(_buildRouter(location: '/marketplace/produto/prod-2')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ureia 45% granulada'), findsWidgets);
      expect(find.text('Fertil Nordeste'), findsOneWidget);
      expect(find.text('Adicionar ao pedido'), findsOneWidget);

      await tester.tap(find.text('Adicionar ao pedido'));
      await tester.pumpAndSettle();

      expect(find.text('Adicionado ao pedido'), findsOneWidget);
      expect(
        find.text('Produto adicionado ao pedido (protótipo).'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mostra estado vazio para produto inexistente', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        _wrap(_buildRouter(location: '/marketplace/produto/inexistente')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Produto não encontrado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
