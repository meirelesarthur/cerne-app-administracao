import 'package:go_router/go_router.dart';

import 'screens/ajuda_screen.dart';
import 'screens/contratos_screen.dart';
import 'screens/credito_home_screen.dart';
import 'screens/proposta_detalhe_screen.dart';
import 'screens/propostas_screen.dart';

/// Rotas do módulo Crédito — espelha `CreditoModule.tsx`: oferta pré-aprovada,
/// simulador rápido, linhas disponíveis e acompanhamento de propostas. O
/// simulador vive na Home; a rota "simular" (aba do bottom tab) renderiza a
/// mesma Home rolada automaticamente até a seção.
GoRoute buildCreditoModuleRoute() {
  return GoRoute(
    path: '/credito',
    builder: (context, state) => const CreditoHomeScreen(),
    routes: [
      GoRoute(
        path: 'propostas',
        builder: (context, state) => const PropostasScreen(),
      ),
      GoRoute(
        path: 'proposta/:id',
        builder: (context, state) =>
            PropostaDetalheScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: 'simular',
        builder: (context, state) =>
            const CreditoHomeScreen(scrollToSimulador: true),
      ),
      GoRoute(
        path: 'contratos',
        builder: (context, state) => const ContratosScreen(),
      ),
      GoRoute(path: 'ajuda', builder: (context, state) => const AjudaScreen()),
    ],
  );
}
