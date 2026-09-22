import 'package:go_router/go_router.dart';

import '../../ui/ui.dart';
import 'screens/bank_home_screen.dart';
import 'screens/cartoes_screen.dart';
import 'screens/extrato_screen.dart';
import 'screens/limites_screen.dart';
import 'screens/pagamentos_screen.dart';

/// Rotas do módulo GB Bank — espelha `BankModule.tsx`. Registrado no
/// `ShellRoute` principal (`lib/router/app_router.dart`).
GoRoute buildBankModuleRoute() {
  return GoRoute(
    path: '/bank',
    builder: (context, state) => const BankHomeScreen(),
    routes: [
      GoRoute(
        path: 'extrato',
        builder: (context, state) => const ExtratoScreen(),
      ),
      GoRoute(
        path: 'pagamentos',
        builder: (context, state) => const PagamentosScreen(),
      ),
      GoRoute(
        path: 'cartoes',
        builder: (context, state) => const CartoesScreen(),
      ),
      GoRoute(
        path: 'pix',
        builder: (context, state) =>
            const PagamentosScreen(initialFlow: PagamentosFlow.pix),
      ),
      GoRoute(
        path: 'limites',
        builder: (context, state) => const LimitesScreen(),
      ),
      GoRoute(
        path: 'ajuda',
        builder: (context, state) => const AppEmptyState(
          icon: AppIcons.construction,
          title: 'Bank · Ajuda',
          description:
              'Conteúdo em desenvolvimento. Esta área será detalhada em uma próxima fase.',
        ),
      ),
    ],
  );
}
