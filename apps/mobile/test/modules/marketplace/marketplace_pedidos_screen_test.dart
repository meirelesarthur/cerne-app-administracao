import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/marketplace/marketplace_module.dart';

GoRouter _buildRouter() => GoRouter(
  initialLocation: '/marketplace/pedidos',
  routes: [buildMarketplaceModuleRoute()],
);

Widget _wrap(GoRouter router) => MaterialApp.router(
  theme: buildAppTheme(AppThemeVariant.light),
  routerConfig: router,
);

void main() {
  group('MarketplacePedidosScreen', () {
    testWidgets('lista pedidos mockados sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(_buildRouter()));
      await tester.pumpAndSettle();

      expect(find.text('Pedido #48213'), findsOneWidget);
      expect(find.text('Em transporte'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tocar num pedido abre o detalhe em BottomSheet', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pedido #48213'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da movimentação'), findsNothing);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('R\$ 1.729,30'), findsWidgets);
    });
  });
}
