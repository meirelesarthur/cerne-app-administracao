import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../modules/armazem/armazem_module.dart';
import '../modules/bank/bank_module.dart';
import '../modules/credito/credito_module.dart';
import '../modules/fazendas/fazendas_module.dart';
import '../modules/fazendas/screens/busca_global_screen.dart';
import '../modules/hub/hub_module.dart';
import '../modules/marketplace/marketplace_module.dart';
import '../shell/module_config.dart';
import '../shell/pages/login_page.dart';
import '../shell/pages/module_placeholder_screen.dart';
import '../shell/pages/notificacoes_page.dart';
import '../shell/pages/onboarding_page.dart';
import '../shell/pages/perfil_config_page.dart';
import '../shell/shell_layout.dart';
import '../shell/state/prototype_session_store.dart';

/// Router do app — `ShellRoute` (F3.1) com rotas `/:moduleId` e `/:moduleId/:tab`
/// aninhadas, espelhando a navegação de 2 níveis do protótipo React
/// (`react-router-dom`, `ShellLayout` + `Outlet` implícito).
///
/// Cada rota de módulo usa um segmento literal (`/bank`, não `/:moduleId`) —
/// por isso o `moduleId`/`tab` ativos são derivados de `state.uri.pathSegments`
/// dentro do builder do `ShellRoute`, não de `state.pathParameters` (não há
/// parâmetro nomeado `:moduleId` em nenhuma rota).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen<PrototypeSessionState>(prototypeSessionProvider, (previous, next) {
    refresh.value++;
  });

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(prototypeSessionProvider);
      return redirectForSession(state.uri.path, session);
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/fazendas/visao-geral',
      ),
      ShellRoute(
        builder: (context, state, child) {
          final segments = state.uri.pathSegments;
          final moduleId = segments.isNotEmpty ? segments.first : 'fazendas';
          final tab = segments.length > 1 ? segments[1] : '';
          // A central de um grupo é um estado intermediário: mantém o
          // seletor de fazenda e o dock global, mas remove a saudação e
          // as abas para a própria tela renderizar busca + cards.
          // Funcionalidades, dashboards e fluxos continuam sendo telas
          // fundas, sem chrome.
          final isGroup = segments.length > 2 && segments[2] == 'grupo';
          final isDeep = segments.length > 2 && !isGroup;
          return ShellLayout(
            moduleId: moduleId,
            activeTab: tab,
            hideChrome: isDeep,
            compactChrome: isGroup,
            child: child,
          );
        },
        routes: [
          buildHubModuleRoute(),
          buildFazendasModuleRoute(),
          buildBankModuleRoute(),
          buildCreditoModuleRoute(),
          buildMarketplaceModuleRoute(),
          buildArmazemModuleRoute(),
          for (final module in modules.where(
            (m) => !_wiredModules.contains(m.id),
          ))
            GoRoute(
              path: '/${module.id}',
              builder: (context, state) => ModulePlaceholderScreen(
                moduleLabel: module.label,
                tabLabel: _tabLabel(module, ''),
              ),
              routes: [
                GoRoute(
                  path: ':tab',
                  builder: (context, state) {
                    final tab = state.pathParameters['tab']!;
                    return ModulePlaceholderScreen(
                      moduleLabel: module.label,
                      tabLabel: _tabLabel(module, tab),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) => const PerfilConfigPage(),
      ),
      GoRoute(
        path: '/notificacoes',
        builder: (context, state) => const NotificacoesPage(),
      ),
      // Busca global de funcionalidades. Fica fora do `ShellRoute` — como
      // `/perfil` e `/notificacoes` — porque é tela cheia: quem busca quer a
      // lista, não o cromo do app. A tela vive no módulo Fazendas, onde mora o
      // catálogo funcional que ela pesquisa; a rota é de topo, onde mora a sua
      // navegação.
      GoRoute(
        path: '/busca',
        builder: (context, state) => const BuscaGlobalScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

/// Política única de acesso do protótipo, separada do roteador para permitir
/// testes determinísticos de deep links. O CERNE ADM tem um único perfil
/// (Administração) e entra direto pelo login — sem tela de seleção de
/// ambiente/perfil —, então a política só decide entre rota pública, entrada
/// sem sessão e normalização das rotas de entrada do módulo.
String? redirectForSession(String path, PrototypeSessionState session) {
  final isPublic = path == '/login' || path == '/onboarding';
  final profile = session.profile;

  if (profile == null) {
    // O login é a porta de entrada real do protótipo (ver
    // `initialLocation`) — sem sessão, qualquer rota protegida cai nele.
    return isPublic ? null : '/login';
  }

  if (path == '/' || path == '/fazendas' || path == '/login') {
    return path == '/fazendas' ? profile.homeRoute : profile.landingRoute;
  }
  if (path == '/fazendas/mais') return profile.homeRoute;

  return null;
}

/// Módulos com rota real registrada (todos, após a F4) — o loop genérico de
/// `ModulePlaceholderScreen` abaixo só existe como rede de segurança para um
/// módulo futuro sem tela própria ainda.
const _wiredModules = {
  'inicio',
  'fazendas',
  'bank',
  'credito',
  'marketplace',
  'armazem',
};

String _tabLabel(ModuleDef module, String tabPath) {
  for (final tab in module.bottomTabs) {
    if (tab.path == tabPath) return tab.label;
  }
  return tabPath;
}
