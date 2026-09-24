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
import 'screens/responsibility_workspace.dart';

/// Rotas do módulo Fazendas (ex-"Cerne") — espelha `FazendasModule.tsx`.
/// Registrado no `ShellRoute` principal (`lib/router/app_router.dart`), no
/// mesmo padrão dos demais construtores de rota de módulo.
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
        name: 'farm.admin_center',
        builder: (context, state) => const _FazendasScaffold(
          child: ResponsibilityWorkspace(
            profile: FeatureProfile.administration,
            showLocalContext: false,
            focusGroups: ['Painéis de decisão'],
            sectionTitle: 'Painéis de decisão',
          ),
        ),
        routes: [
          GoRoute(
            path: 'grupo/:group',
            name: 'farm.admin_group',
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
            name: 'farm.admin_feature',
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
        path: 'visao-geral',
        name: 'farm.overview',
        builder: (context, state) =>
            const _FazendasScaffold(child: FazendasHome()),
      ),
      GoRoute(
        path: 'atividades',
        name: 'farm.activities',
        builder: (context, state) =>
            const _FazendasScaffold(child: AtividadesScreen()),
      ),
      GoRoute(
        path: 'fazendas',
        name: 'farm.list',
        builder: (context, state) =>
            const _FazendasScaffold(child: FarmListScreen()),
      ),
      GoRoute(
        path: 'financeiro',
        name: 'farm.financeiro_legacy',
        // Atalho legado; hoje resolve no painel Resultado, mesma tela do dashId
        // `resultado` (e dos aliases `financeiro`/`pecuaria`).
        builder: (context, state) =>
            _FazendasScaffold(child: buildAdminDashboard('resultado')),
      ),
      GoRoute(
        path: 'mais',
        name: 'farm.mais',
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
        name: 'farm.consultas',
        builder: (context, state) => const _FazendasScaffold(
          child: ResponsibilityWorkspace(
            profile: FeatureProfile.administration,
            showLocalContext: false,
            // OS em primeiro (pedido de produto): a consulta que o gestor
            // mais abre, junto das demais consultas e auditorias.
            focusGroups: ['Ordem de serviço', 'Consultas e auditoria'],
            sectionTitle: 'Consultas',
            routeSegment: 'consultas',
          ),
        ),
        routes: [
          GoRoute(
            path: 'gerenciais',
            name: 'farm.consultas_gerenciais',
            builder: (context, state) =>
                _FazendasScaffold(child: buildAdminDashboard('consultas')),
          ),
          GoRoute(
            path: ':featureId',
            name: 'farm.consulta_feature',
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
      // Antiga aba "OS": a lista de OS agora abre pelo primeiro ladrilho da
      // aba Consultas, na tela com voltar e o "+" no topo. O path continua
      // resolvendo para links salvos.
      GoRoute(
        path: 'ordem-servico',
        redirect: (context, state) => '/fazendas/dashboards/ordem-servico',
      ),
      GoRoute(
        path: 'dashboards/:dashId',
        name: 'farm.dashboard',
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
/// A navbar global é sobreposta ao conteúdo pela `Stack` do `ShellLayout`; este
/// scaffold não reduz o viewport para abrir espaço para ela. Espaçamento para
/// rolar itens por baixo da navbar pertence ao conteúdo rolável da tela.
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
