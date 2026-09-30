import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/module_config.dart';
import '../../../shell/state/prototype_session_store.dart';
import '../../../ui/ui.dart';
import '../components/farm_picker.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';
import '../state/fazendas_store.dart';

/// Busca global de funcionalidades — destino do `AppSearchField` do cabeçalho.
///
/// Tela cheia, fora do `ShellRoute`: conserva apenas o contexto da fazenda,
/// enquanto troca o cabeçalho de perfil pela lista de todas as funcionalidades
/// do menu ([menuFunctionalities]), com as de uso diário primeiro. Ao digitar,
/// a lista dá lugar aos resultados do catálogo funcional.
///
/// **Procura nos dois perfis**, por decisão de produto: o catálogo funcional é
/// um só e a pessoa não deveria precisar saber em qual ambiente uma função
/// mora para encontrá-la. Mas a política de acesso do protótipo continua
/// valendo — uma função do outro perfil aparece marcada e **não é tocável**,
/// porque abri-la só levaria a um desvio silencioso de volta para a home
/// (`redirectForSession`). Achar é diferente de poder abrir, e a tela diz qual
/// dos dois está acontecendo.
class BuscaGlobalScreen extends ConsumerStatefulWidget {
  const BuscaGlobalScreen({super.key});

  @override
  ConsumerState<BuscaGlobalScreen> createState() => _BuscaGlobalScreenState();
}

class _BuscaGlobalScreenState extends ConsumerState<BuscaGlobalScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final sessionProfile = ref.watch(prototypeSessionProvider).profile;
    final activeFarm = ref.watch(fazendasStoreProvider).activeFarm;
    final results = searchFeatures(_query, sessionProfile: sessionProfile);
    final hasQuery = normalizeForSearch(_query).isNotEmpty;
    final functionalities = menuFunctionalities(sessionProfile);

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: AppContentSheet(
          padded: false,
          // Voltar visível: a busca abre em tela cheia com o teclado aberto
          // e, sem este botão, só saía pelo gesto do sistema.
          header: Row(
            children: [
              AppIconButton(
                icon: const AppIcon(AppIcons.arrowLeft, size: AppSize.iconLg),
                label: 'Fechar busca',
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go('/fazendas/visao-geral'),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: AppFarmSelector(
                  farmName: activeFarm.name,
                  onTap: () => openFarmPicker(context, ref),
                ),
              ),
            ],
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space4,
              AppSpacing.space8,
            ),
            children: [
              AppTextInput(
                placeholder: 'Procurando por algo?',
                autofocus: true,
                suffixIcon: Container(
                  width: AppSpacing.space10,
                  height: AppSpacing.space10,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: semantic.bgSurface,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    AppIcons.search,
                    size: AppSize.iconLg,
                    color: semantic.accentDefault,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.space6),
              if (!hasQuery) ...[
                const _SearchSectionHeader(title: 'Funcionalidades'),
                const SizedBox(height: AppSpacing.space3),
                for (final item in functionalities) ...[
                  AppMenuItem(
                    icon: item.icon,
                    label: item.label,
                    description: item.context,
                    showShadow: false,
                    // `go`, não `push`: a busca é rota de topo e o destino
                    // mora no `ShellRoute` — empilhar um sobre o outro quebra
                    // o `HeroControllerScope` e a navegação não acontece.
                    onTap: () => context.go(item.route),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
              ] else if (results.isEmpty)
                const AppEmptyState(
                  icon: AppIcons.searchX,
                  title: 'Nenhuma função encontrada',
                  description:
                      'Tente outro termo — o nome do módulo também vale.',
                )
              else ...[
                Text(
                  '${results.length} '
                  '${results.length == 1 ? 'resultado' : 'resultados'}',
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                for (final result in results) ...[
                  AppMenuItem(
                    icon: groupIcon(result.feature.group),
                    label: result.feature.title,
                    description: result.feature.objective,
                    showShadow: false,
                    trailing: result.openable
                        ? null
                        : AppTag(child: Text(_profileLabel(result.feature))),
                    onTap: result.openable
                        ? () => context.go(featureDestination(result.feature))
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _profileLabel(FeatureDefinition feature) =>
      feature.profile == FeatureProfile.administration
      ? 'Administração'
      : 'Operação';
}

class _SearchSectionHeader extends StatelessWidget {
  const _SearchSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sem chevron: o título não é tocável, e a seta prometia um "ver
          // tudo" que não existia.
          AppHeading(child: Text(title)),
        ],
      ),
    );
  }
}

/// Uma funcionalidade do menu, pronta para a lista da busca.
class MenuFunctionality {
  const MenuFunctionality({
    required this.key,
    required this.label,
    required this.context,
    required this.icon,
    required this.route,
  });

  /// `feature:<id>` para o catálogo das Fazendas, `<módulo>/<item>` para os
  /// demais módulos — é a chave de [adminDailyPriority].
  final String key;
  final String label;

  /// Onde a função mora ("Fazendas · Painéis de decisão", "Bank").
  final String context;
  final AppIconData icon;
  final String route;
}

/// O que o administrador mais abre no dia a dia, nesta ordem. Não há API de
/// acessos recentes nem de histórico, então a prioridade é uma curadoria fixa:
/// resultado e operação da fazenda primeiro, depois dinheiro e estoque.
/// O restante do menu vem em seguida, na ordem do próprio menu.
const adminDailyPriority = <String>[
  'feature:painel-financeiro',
  'feature:consulta-os',
  'bank/pagamentos',
  'bank/extrato',
  'feature:saldo-estoque',
  'feature:lotacao-currais',
  'feature:consulta-apontamentos',
  'feature:suprimentos',
  'marketplace/pedidos',
  'credito/propostas',
  'feature:consultas-gerenciais',
  'armazem/estoque',
];

/// Todas as funcionalidades do menu visíveis para a sessão: o catálogo
/// funcional das Fazendas e as abas e itens de menu dos demais módulos.
/// Início e "Mais" ficam de fora — são navegação, não funcionalidade.
List<MenuFunctionality> menuFunctionalities(UserAccessProfile? profile) {
  final items = <MenuFunctionality>[
    for (final feature in allFeatures)
      if (profile != null && featureProfileOf(profile) == feature.profile)
        MenuFunctionality(
          key: 'feature:${feature.id}',
          label: feature.title,
          context: 'Fazendas · ${feature.group}',
          icon: groupIcon(feature.group),
          route: featureDestination(feature),
        ),
    for (final module in modules)
      if (module.id != 'fazendas') ...[
        for (final tab in visibleBottomTabs(module, profile))
          if (tab.path.isNotEmpty && tab.action == null && tab.id != 'mais')
            MenuFunctionality(
              key: '${module.id}/${tab.id}',
              label: tab.label,
              context: module.label,
              icon: tab.icon,
              route: '/${module.id}/${tab.path}',
            ),
        for (final section in getMenuSections(module, profile: profile))
          for (final item in section.items)
            MenuFunctionality(
              key: '${module.id}/${item.id}',
              label: item.label,
              context: module.label,
              icon: item.icon,
              route: item.route,
            ),
      ],
  ];

  int rank(MenuFunctionality item) {
    final index = adminDailyPriority.indexOf(item.key);
    return index == -1 ? adminDailyPriority.length : index;
  }

  // Ordenação estável: fora da prioridade, vale a ordem do menu.
  final indexed = items.indexed.toList()
    ..sort((a, b) {
      final byRank = rank(a.$2).compareTo(rank(b.$2));
      return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
    });
  return [for (final (_, item) in indexed) item];
}

/// Uma linha do resultado: a função encontrada e se a sessão atual pode abri-la.
class FeatureSearchResult {
  const FeatureSearchResult({required this.feature, required this.openable});

  final FeatureDefinition feature;

  /// Falso quando a função pertence ao outro perfil — a política de acesso
  /// impediria a navegação.
  final bool openable;
}

/// Normaliza para comparação: minúsculas e sem acento.
///
/// Sem isso, "pecuaria" não acharia "Pecuária" e "orgao" não acharia "órgão" —
/// e ninguém digita acento numa busca com pressa, de bota, no meio do curral.
String normalizeForSearch(String value) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
  final buffer = StringBuffer();
  for (final rune in value.trim().toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = comAcento.indexOf(char);
    buffer.write(index == -1 ? char : semAcento[index]);
  }
  return buffer.toString();
}

/// Busca no catálogo inteiro — os dois perfis.
///
/// Casa por nome, objetivo e módulo. Resultados que a sessão pode abrir vêm
/// primeiro: quem está no chão de fazenda não deveria rolar por funções
/// administrativas para chegar à sua.
///
/// [sessionProfile] é obrigatório de propósito — `null` é uma resposta válida
/// (sessão sem perfil, em que nada é abrível), e não um descuido de chamada.
List<FeatureSearchResult> searchFeatures(
  String query, {
  required UserAccessProfile? sessionProfile,
}) {
  final termo = normalizeForSearch(query);
  if (termo.isEmpty) return const [];

  final abertos = <FeatureSearchResult>[];
  final bloqueados = <FeatureSearchResult>[];

  for (final feature in allFeatures) {
    final alvo = normalizeForSearch(
      '${feature.title} ${feature.objective} ${feature.group}',
    );
    if (!alvo.contains(termo)) continue;

    final openable =
        sessionProfile != null &&
        featureProfileOf(sessionProfile) == feature.profile;
    final result = FeatureSearchResult(feature: feature, openable: openable);
    (openable ? abertos : bloqueados).add(result);
  }

  return [...abertos, ...bloqueados];
}

/// Perfil do catálogo correspondente ao perfil da sessão. O CERNE ADM tem um
/// perfil único, então o mapeamento é direto.
FeatureProfile featureProfileOf(UserAccessProfile profile) =>
    FeatureProfile.administration;

/// Rota de uma funcionalidade — mesma regra de [GroupFeaturesScreen]: a função
/// mapeada mora sob o segmento administrativo, salvo quando já tem rota
/// própria (`existingRoute`, ex. `/fazendas/dashboards/apontamentos`).
String featureDestination(FeatureDefinition feature) {
  if (feature.existingRoute case final route?) return route;
  return '/fazendas/administracao/${feature.id}';
}
