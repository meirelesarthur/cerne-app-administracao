import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/marketplace/marketplace_module.dart';

import '../../support/test_viewport.dart';

GoRouter _buildRouter() => GoRouter(
  initialLocation: '/marketplace/categorias',
  routes: [buildMarketplaceModuleRoute()],
);

// A navegação de volta cai em MarketplaceHomeScreen, cujo campo de busca
// precisa de um ancestral `Material` (em produção, o `Scaffold` do ShellLayout).
Widget _wrap(GoRouter router) => MaterialApp.router(
  theme: buildAppTheme(AppThemeVariant.light),
  routerConfig: router,
  builder: (context, child) => Scaffold(body: child),
);

void main() {
  group('MarketplaceCategoriasScreen', () {
    testWidgets('lista categorias com contagem de produtos sem exceção', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(_buildRouter()));
      await tester.pumpAndSettle();

      expect(find.text('Categorias'), findsOneWidget);
      expect(find.text('Sementes'), findsOneWidget);
      expect(find.text('1 produto'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar numa categoria navega de volta à Home filtrada', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(_buildRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sementes'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Semente de soja Intacta'), findsOneWidget);
      expect(find.text('Ureia 45% granulada'), findsNothing);
    });
  });
}
