import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/prototype_session_store.dart';
import '../../../ui/ui.dart';
import '../components/farm_picker.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';
import '../state/fazendas_store.dart';

/// Busca global de funcionalidades — destino do `AppSearchField` do cabeçalho.
///
/// Tela cheia, fora do `ShellRoute`: conserva apenas o contexto da fazenda,
/// enquanto troca o cabeçalho de perfil por descoberta de produtos, acessos
/// recentes e histórico. Ao digitar, a curadoria dá lugar aos resultados do
/// catálogo funcional dos dois perfis.
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
    final products = _productsFor(sessionProfile);
    final recent = _recentFor(sessionProfile);
    final history = _historyFor(sessionProfile);

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
                    AppIcons.aiSearch,
                    size: AppSize.iconLg,
                    color: semantic.accentDefault,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.space6),
              if (!hasQuery) ...[
                const _SearchSectionHeader(title: 'Seus Produtos'),
                const SizedBox(height: AppSpacing.space3),
                _SearchDiscoveryRail(items: products),
                const SizedBox(height: AppSpacing.space6),
                const _SearchSectionHeader(title: 'Mais acessados'),
                const SizedBox(height: AppSpacing.space3),
                _SearchDiscoveryRail(items: recent),
                const SizedBox(height: AppSpacing.space6),
                const _SearchSectionHeader(title: 'Histórico'),
                const SizedBox(height: AppSpacing.space2),
                for (final item in history)
                  _SearchHistoryItem(
                    item: item,
                    onTap: () => context.go(item.route),
                  ),
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
                        ? () => context.push(featureDestination(result.feature))
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

class _SearchDiscoveryRail extends StatelessWidget {
  const _SearchDiscoveryRail({required this.items});

  final List<_SearchShortcut> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.space2),
        itemBuilder: (context, index) {
          final item = items[index];
          return AppDiscoveryTile(
            icon: item.icon,
            label: item.label,
            onTap: () => context.go(item.route),
          );
        },
      ),
    );
  }
}

class _SearchHistoryItem extends StatelessWidget {
  const _SearchHistoryItem({required this.item, required this.onTap});

  final _SearchShortcut item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: item.label,
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        height: AppSpacing.space14,
        child: Row(
          children: [
            AppIcon(
              item.icon,
              size: AppSize.iconLg,
              color: semantic.fgDefault,
            ),
            const SizedBox(width: AppSpacing.space4),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  color: semantic.fgDefault,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            AppIcon(
              AppIcons.chevronRight,
              size: AppSize.iconLg,
              color: semantic.fgDefault,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchShortcut {
  const _SearchShortcut({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final AppIconData icon;
  final String route;
}

List<_SearchShortcut> _productsFor(UserAccessProfile? profile) {

  return const [
    _SearchShortcut(
      label: 'Fazendas',
      icon: AppIcons.sprout,
      route: '/fazendas/administracao',
    ),
    _SearchShortcut(
      label: 'Gestão de Estoque',
      icon: AppIcons.boxes,
      route: '/armazem/estoque',
    ),
    _SearchShortcut(
      label: 'Marketplace',
      icon: AppIcons.store,
      route: '/marketplace',
    ),
    _SearchShortcut(
      label: 'Open Finance',
      icon: AppIcons.openFinance,
      route: '/bank',
    ),
  ];
}

List<_SearchShortcut> _recentFor(UserAccessProfile? profile) {

  return const [
    _SearchShortcut(
      label: 'Open Finance',
      icon: AppIcons.openFinance,
      route: '/bank',
    ),
    _SearchShortcut(
      label: 'Marketplace',
      icon: AppIcons.store,
      route: '/marketplace',
    ),
    _SearchShortcut(
      label: 'Fazendas',
      icon: AppIcons.sprout,
      route: '/fazendas/administracao',
    ),
    _SearchShortcut(
      label: 'Gestão de Estoque',
      icon: AppIcons.boxes,
      route: '/armazem/estoque',
    ),
  ];
}

List<_SearchShortcut> _historyFor(UserAccessProfile? profile) {

  return const [
    _SearchShortcut(
      label: 'Empréstimos e Financiamentos',
      icon: AppIcons.handCoins,
      route: '/credito',
    ),
    _SearchShortcut(
      label: 'Seguros, Consórcios e Capitalização',
      icon: AppIcons.shieldCheck,
      route: '/credito',
    ),
    _SearchShortcut(
      label: 'Open Finance',
      icon: AppIcons.openFinance,
      route: '/bank',
    ),
    _SearchShortcut(
      label: 'Transações',
      icon: AppIcons.receipt,
      route: '/bank/extrato',
    ),
    _SearchShortcut(
      label: 'Autorizações',
      icon: AppIcons.shieldCheck,
      route: '/bank/pagamentos',
    ),
    _SearchShortcut(
      label: 'Dashboards da Fazenda',
      icon: AppIcons.layoutDashboard,
      route: '/fazendas/administracao',
    ),
  ];
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
