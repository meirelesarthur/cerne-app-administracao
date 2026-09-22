import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/marketplace/marketplace_module.dart';

import '../../support/test_viewport.dart';

GoRouter _buildRouter() => GoRouter(
  initialLocation: '/marketplace',
  routes: [buildMarketplaceModuleRoute()],
);

// Em produção, `buildMarketplaceModuleRoute()` sempre roda dentro do
// `Scaffold` do `ShellLayout` — sem ele, o `TextField` da busca não acha um
// ancestral `Material`.
Widget _wrap(GoRouter router) => MaterialApp.router(
  theme: buildAppTheme(AppThemeVariant.light),
  routerConfig: router,
  builder: (context, child) => Scaffold(body: child),
);

void main() {
  group('MarketplaceHomeScreen', () {
    testWidgets('renderiza busca, categorias e grid de produtos sem exceção', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(_buildRouter()));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Semana do Plantio'), findsOneWidget);
      expect(find.text('Sementes'), findsOneWidget);
      expect(find.text('Semente de soja Intacta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtra produtos ao buscar por termo', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(_buildRouter()));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'ureia');
      await tester.pumpAndSettle();

      expect(find.text('Ureia 45% granulada'), findsOneWidget);
      expect(find.text('Semente de soja Intacta'), findsNothing);
    });

    testWidgets('mostra estado vazio quando nada combina com a busca', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(_buildRouter()));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'produto inexistente xyz',
      );
      await tester.pumpAndSettle();

      expect(find.text('Nada encontrado'), findsOneWidget);

      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();

      expect(find.text('Semente de soja Intacta'), findsOneWidget);
    });

    testWidgets('tocar num produto navega para a PDP', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(_buildRouter()));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Semente de soja Intacta').first);
      await tester.pumpAndSettle();

      expect(find.text('Adicionar ao pedido'), findsOneWidget);
    });
  });
}
