import 'package:go_router/go_router.dart';

import 'screens/armazem_home_screen.dart';
import 'screens/estoque_screen.dart';
import 'screens/movimentacoes_screen.dart';
import 'screens/relatorios_screen.dart';
import 'screens/unidades_screen.dart';

/// Rotas do módulo Armazém: home operacional + abas de Estoque,
/// Movimentações, Unidades e Relatórios (spec §3.4, D2). Espelha
/// `ArmazemModule.tsx`. Registrado no `ShellRoute` principal
/// (`lib/router/app_router.dart`).
GoRoute buildArmazemModuleRoute() {
  return GoRoute(
    path: '/armazem',
    builder: (context, state) => const ArmazemHomeScreen(),
    routes: [
      GoRoute(
        path: 'estoque',
        builder: (context, state) => EstoqueScreen(
          initialUnidadeId: state.uri.queryParameters['unidade'],
        ),
      ),
      GoRoute(
        path: 'movimentacoes',
        builder: (context, state) => const MovimentacoesScreen(),
      ),
      GoRoute(
        path: 'unidades',
        builder: (context, state) => const UnidadesScreen(),
      ),
      GoRoute(
        path: 'relatorios',
        builder: (context, state) => const RelatoriosScreen(),
      ),
    ],
  );
}
