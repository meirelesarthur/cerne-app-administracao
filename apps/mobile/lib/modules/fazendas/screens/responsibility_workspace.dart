import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../components/farm_picker.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';
import '../state/fazendas_store.dart';

/// "O que fazer hoje" (operacional) / central de gestão (administração) —
/// espelha `ResponsibilityWorkspace.tsx`.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o título operacional
/// trocou de "Central de rotinas" (vocabulário de sistema) para "O que fazer
/// hoje" — mais concreto para quem chega para executar uma tarefa, não para
/// administrar um "ambiente". A aba de contexto acima continua dizendo
/// "Rotinas" (rótulo curto de navegação). Administração entra direto nos
/// painéis e nas consultas, sem repetir um título de contexto.
///
/// Nova UI (referência Força Agro): em vez de expandir cada funcionalidade
/// como um card solto (lia como uma lista longa e poluída), a home agrupa por
/// `feature.group` num grid ícone-em-cima/rótulo-embaixo. Tocar num card leva
/// para a tela fullscreen com as funções daquele grupo
/// ([GroupFeaturesScreen]); a navegação para a funcionalidade em si não muda.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o cabeçalho da
/// central foi reduzido ao título — o chip "AMBIENTE X" já é redundante com o
/// header global e as `AppContextTabs` (que dizem a mesma coisa), e a lista
/// "Acesso rápido" acima do grid apontava exatamente para os mesmos destinos
/// do grid logo abaixo, duplicada. O primeiro card tocável, que antes ficava a
/// ~53% da altura da tela, sobe para logo abaixo do título.
///
/// Padrão global (`docs/ESTEIRA-PADRAO-GLOBAL-HUGEICONS.md`, E7): esta é a tela
/// que o frame `operacao-home` do Figma descreve — os grupos do catálogo são,
/// um a um e na mesma ordem, os ladrilhos desenhados lá. Duas mudanças vieram
/// daí:
///
/// - O cartão de módulo era `_ModuleGridCard`, reimplementado aqui: ícone
///   centralizado, raio `xl3`, proporção fixa. Passou a ser `AppModuleTile` do
///   catálogo, com a anatomia medida no Figma (Lei 1 — o controle reutilizável
///   nasce em `lib/ui/`).
/// - O contexto de fazenda passa a abrir a tela, como no Figma. É o único bloco
///   que Operação e Administração compartilham (§4 da esteira).
class ResponsibilityWorkspace extends ConsumerWidget {
  const ResponsibilityWorkspace({
    super.key,
    required this.profile,
    this.showLocalContext = true,
    this.focusGroups,
    this.sectionTitle,
    this.routeSegment = 'administracao',
  });

  final FeatureProfile profile;

  /// O shell monta fazenda, saudação e busca globalmente. O valor `true` fica
  /// como padrão para preservar o uso isolado desta tela no Widgetbook/testes.
  final bool showLocalContext;

  /// Quando informado, a central abre diretamente as funções destes grupos
  /// (na ordem da lista) em vez de mostrar os grupos como uma segunda camada
  /// de navegação. A Administração usa isso para que as abas Painéis e
  /// Consultas entreguem conteúdo acionável no primeiro toque — a aba
  /// Consultas junta "Ordem de serviço" (primeiro) e "Consultas e auditoria".
  final List<String>? focusGroups;

  /// Título da seção quando há [focusGroups]. Padrão: o primeiro grupo.
  final String? sectionTitle;

  /// Segmento de rota das funcionalidades sem `existingRoute`
  /// (`/fazendas/<segmento>/<id>`) — define para qual aba o voltar retorna.
  final String routeSegment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollEndPadding =
        AppSpacing.space4 +
        AppLayout.tabBarClearance +
        MediaQuery.paddingOf(context).bottom;
    final activeFarm = ref.watch(
      fazendasStoreProvider.select((s) => s.activeFarm),
    );
    const allFeatures = adminFeatures;
    final focus = focusGroups;
    final features = focus == null
        ? allFeatures
        : [
            for (final group in focus)
              ...allFeatures.where((feature) => feature.group == group),
          ];
    final groups = <String, List<FeatureDefinition>>{};
    for (final feature in features) {
      groups.putIfAbsent(feature.group, () => []).add(feature);
    }
    // A ordem do grid é decisão de produto (`groupOrder`), não a ordem de
    // inserção no catálogo. O desempate pela posição original mantém o
    // resultado determinístico: `List.sort` não é estável em Dart, então
    // grupos ainda não listados em `_groupDisplayOrder` embaralhariam entre si.
    final insertionOrder = groups.keys.toList();
    final orderedGroups = [...insertionOrder]
      ..sort((a, b) {
        final byOrder = groupOrder(a).compareTo(groupOrder(b));
        if (byOrder != 0) return byOrder;
        return insertionOrder.indexOf(a).compareTo(insertionOrder.indexOf(b));
      });
    final segment = routeSegment;
    final isFocusedGroup = focus != null;

    final content = <Widget>[
      if (showLocalContext) ...[
        AppFarmSelector(
          farmName: activeFarm.name,
          onTap: () => openFarmPicker(context, ref),
        ),
        const SizedBox(height: AppSpacing.space3),
        AppSearchField(onTap: () => context.push('/busca')),
        const SizedBox(height: AppSpacing.space4),
      ],
      if (isFocusedGroup) ...[
        AppSectionTitle(child: Text(sectionTitle ?? focus.first)),
        const SizedBox(height: AppSpacing.space2),
        AppModuleTileGrid(
          lastTileFullWidth: false,
          tiles: [
            for (final feature in features)
              AppModuleTile(
                icon: featureIcon(feature.id, feature.group),
                label: feature.title,
                description: feature.objective,
                layout: AppModuleTileLayout.module,
                onTap: () => context.push(_featureRoute(feature, segment)),
              ),
          ],
        ),
      ] else
        AppModuleTileGrid(
          tiles: [
            for (final group in orderedGroups)
              AppModuleTile(
                icon: groupIcon(group),
                label: groupDisplayLabel(group),
                // Grupo com uma única funcionalidade (ex.: Sincronização): a
                // tela de listagem do grupo não teria nada além do próprio
                // card — pula direto para o destino, sem a camada
                // intermediária que só repetiria a mesma informação.
                onTap: () {
                  final groupFeatures = groups[group]!;
                  if (groupFeatures.length == 1) {
                    context.push(_featureRoute(groupFeatures.single, segment));
                  } else {
                    context.go(
                      '/fazendas/$segment/grupo/${groupToSlug(group)}',
                    );
                  }
                },
              ),
          ],
        ),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space4,
        AppSpacing.space4,
        scrollEndPadding,
      ),
      children: content,
    );
  }

  String _featureRoute(FeatureDefinition feature, String segment) {
    if (feature.existingRoute case final route?) return route;
    return '/fazendas/$segment/${feature.id}';
  }
}
