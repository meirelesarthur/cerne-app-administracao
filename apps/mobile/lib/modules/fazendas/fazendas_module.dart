import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'admin/admin_dashboard.dart';
import 'components/sync_banner.dart';
import 'functional_catalog.dart';
import 'screens/atividades_screen.dart';
import 'screens/farm_list_screen.dart';
import 'screens/fazendas_home.dart';
import 'screens/group_features_screen.dart';
import 'screens/mais_screen.dart';
import 'screens/mapped_feature_screen.dart';
import 'screens/ordem_servico_tab_screen.dart';
import 'screens/responsibility_workspace.dart';

/// Rotas do módulo Fazendas (ex-"Cerne") — espelha `FazendasModule.tsx`.
/// Registrado no `ShellRoute` principal (`lib/router/app_router.dart`), no
/// mesmo padrão de `buildHubModuleRoute()`.
///
/// A troca de fazenda ativa vive na tela dedicada (tab "Fazendas"). O CERNE
/// ADM opera sempre no ambiente de Administração.
GoRoute buildFazendasModuleRoute() {
  return GoRoute(
    path: '/fazendas',
    builder: (context, state) => const _FazendasScaffold(child: FazendasHome()),
    routes: [
      GoRoute(
        path: 'administracao',
        builder: (context, state) => const _FazendasScaffold(
          child: ResponsibilityWorkspace(
            profile: FeatureProfile.administration,
            showLocalContext: false,
            focusGroup: 'Painéis de decisão',
          ),
        ),
        routes: [
          GoRoute(
            path: 'grupo/:group',
            builder: (context, state) => _FazendasScaffold(
              child: GroupFeaturesScreen(
                groupSlug: state.pathParameters['group']!,
                profile: FeatureProfile.administration,
                embedded: true,
              ),
            ),
          ),
          GoRoute(
            path: ':featureId',
            builder: (context, state) => _FazendasScaffold(
              child: MappedFeatureScreen(
                featureId: state.pathParameters['featureId']!,
                profile: FeatureProfile.administration,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'atividades',
        builder: (context, state) =>
            const _FazendasScaffold(child: AtividadesScreen()),
      ),
      GoRoute(
        path: 'fazendas',
        builder: (context, state) =>
            const _FazendasScaffold(child: FarmListScreen()),
      ),
      GoRoute(
        path: 'financeiro',
        // Atalho legado; hoje resolve no painel Resultado, mesma tela do dashId
        // `resultado` (e dos aliases `financeiro`/`pecuaria`).
        builder: (context, state) =>
            _FazendasScaffold(child: buildAdminDashboard('resultado')),
      ),
      GoRoute(
        path: 'mais',
        builder: (context, state) =>
            const _FazendasScaffold(child: MaisScreen()),
      ),
      // Consultas Gerenciais e 100% leitura, sem indicador e sem acao: e um
      // console de consulta, nao um painel de decisao. Fica fora de
      // `dashboards/` para o menu nao ensinar errado o que e painel — o dashId
      // antigo continua resolvendo pelo dispatcher, para links salvos.
      // Ver docs/ESTEIRA-DASHBOARDS-ADM.md, secao 2.
      GoRoute(
        path: 'consultas',
        builder: (context, state) => const _FazendasScaffold(
          child: ResponsibilityWorkspace(
            profile: FeatureProfile.administration,
            showLocalContext: false,
            focusGroup: 'Consultas e auditoria',
          ),
        ),
        routes: [
          GoRoute(
            path: 'gerenciais',
            builder: (context, state) =>
                _FazendasScaffold(child: buildAdminDashboard('consultas')),
          ),
          GoRoute(
            path: ':featureId',
            builder: (context, state) => _FazendasScaffold(
              child: MappedFeatureScreen(
                featureId: state.pathParameters['featureId']!,
                profile: FeatureProfile.administration,
                centerRoute: '/fazendas/consultas',
              ),
            ),
          ),
        ],
      ),
      // Aba "OS" da Administração: lista direto as ordens de serviço da
      // fazenda ativa, filtráveis por status e prazo, com a opção de criar
      // uma nova — sem a camada intermediária de tiles (`OrdemServicoTabScreen`).
      GoRoute(
        path: 'ordem-servico',
        builder: (context, state) =>
            const _FazendasScaffold(child: OrdemServicoTabScreen()),
      ),
      GoRoute(
        path: 'dashboards/:dashId',
        builder: (context, state) => _FazendasScaffold(
          child: buildAdminDashboard(state.pathParameters['dashId']!),
        ),
      ),
    ],
  );
}

/// Scaffold do próprio módulo (equivalente ao `<div className="flex h-full
/// flex-col">` de `FazendasModule.tsx`): `SyncBanner` fixo no topo + conteúdo
/// do módulo abaixo.
///
/// Desvio consciente do React: lá, o próprio `FazendasModule` aplica o padding
/// inferior (`AppLayout.tabBarClearance`) na área rolável. Na porta Flutter,
/// esse respiro para o dock de módulos é aplicado uma única vez, de forma
/// global, pelo `ShellLayout` quando a rota está rasa e o dock está visível.
/// Rotas profundas de cadastro usam a área liberada integralmente — sem
/// duplicar o respiro por módulo (Lei 2 — fonte única do espaçamento).
class _FazendasScaffold extends StatelessWidget {
  const _FazendasScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Sem `ColoredBox` de canvas: quem pinta o fundo é a folha de conteúdo do
    // shell (`AppContentSheet`), e repintar o canvas aqui cobria a folha —
    // deixava o cabeçalho sobre a superfície clara e o resto da tela sobre o
    // cinza, com uma emenda visível logo abaixo das abas.
    return Column(
      children: [
        const SyncBanner(),
        Expanded(child: child),
      ],
    );
  }
}
