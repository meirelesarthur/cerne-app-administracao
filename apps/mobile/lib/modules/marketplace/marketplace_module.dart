import 'package:go_router/go_router.dart';

import '../../ui/ui.dart';
import 'screens/marketplace_categorias_screen.dart';
import 'screens/marketplace_favoritos_screen.dart';
import 'screens/marketplace_home_screen.dart';
import 'screens/marketplace_pedidos_screen.dart';
import 'screens/produto_detalhe_screen.dart';

/// Rotas do módulo Marketplace — espelha `MarketplaceModule.tsx`. Registrado
/// no `ShellRoute` principal (`lib/router/app_router.dart`).
GoRoute buildMarketplaceModuleRoute() {
  return GoRoute(
    path: '/marketplace',
    builder: (context, state) {
      final extra = state.extra;
      final categoriaId = extra is Map ? extra['categoriaId'] as String? : null;
      return MarketplaceHomeScreen(initialCategoriaId: categoriaId);
    },
    routes: [
      GoRoute(
        path: 'produto/:id',
        builder: (context, state) =>
            ProdutoDetalheScreen(produtoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: 'categorias',
        builder: (context, state) => const MarketplaceCategoriasScreen(),
      ),
      GoRoute(
        path: 'pedidos',
        builder: (context, state) => const MarketplacePedidosScreen(),
      ),
      GoRoute(
        path: 'favoritos',
        builder: (context, state) => const MarketplaceFavoritosScreen(),
      ),
      GoRoute(
        path: 'ajuda',
        builder: (context, state) => const AppEmptyState(
          icon: AppIcons.construction,
          title: 'Marketplace · Ajuda',
          description:
              'Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase.',
        ),
      ),
    ],
  );
}
