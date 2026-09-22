import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../functional_catalog.dart';
import '../group_icons.dart';

/// Tela fullscreen com as funções de um único grupo (ex.: "Estoque" →
/// Formulações, Batidas) — destino do acesso rápido e dos cards de módulo em
/// [ResponsibilityWorkspace]. Tocar numa função navega exatamente como antes
/// (rota da própria [FeatureDefinition]); nada muda na jornada de cada uma.
///
/// É o frame `modulo-confinamento` do Figma (`54349:3009`): folha de conteúdo
/// com campo de busca no topo, cabeçalho de seção com a seta de voltar à
/// esquerda do nome do grupo, e as funções abaixo. O cabeçalho de página com
/// descrição e bolha de ícone saiu — a referência resolve o mesmo com uma
/// linha só.
class GroupFeaturesScreen extends StatelessWidget {
  const GroupFeaturesScreen({
    super.key,
    required this.profile,
    required this.groupSlug,
    this.embedded = false,
  });

  final FeatureProfile profile;

  /// Slug da rota (`grupo/:group`) — ver [groupFromSlug]. Um slug desconhecido
  /// (ex.: link antigo/quebrado) cai no estado vazio abaixo em vez de quebrar
  /// a navegação.
  final String groupSlug;

  /// As rotas de grupo já estão dentro do `AppContentSheet` do shell. O modo
  /// padrão mantém a tela autocontida para uso isolado em previews/testes.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    const segment = 'administracao';
    const centerRoute = '/fazendas/$segment';
    final group = groupFromSlug(groupSlug);
    final allFeatures = group == null
        ? const <FeatureDefinition>[]
        : adminFeatures.where((f) => f.group == group).toList();
    final title = group ?? groupSlug;

    final content = ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space4,
        AppSpacing.space4,
        AppSpacing.space4,
      ),
      children: [
        AppSearchField(onTap: () => context.push('/busca')),
        const SizedBox(height: AppSpacing.space4),
        AppSectionTitle(
          leading: AppIcons.chevronLeft,
          onTap: () => context.go(centerRoute),
          semanticLabel: 'Voltar à central',
          child: Text(title),
        ),
        // A contagem sobrevive à troca de cabeçalho: era a descrição do
        // `AppScreenHeader` e vira o metadado de 12px do padrão global. Saber
        // o tamanho da lista antes de rolar é informação de produto, não
        // enfeite do componente antigo.
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.space1),
          child: Text(
            '${allFeatures.length} '
            '${allFeatures.length == 1 ? 'função' : 'funções'} neste módulo',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        if (allFeatures.isEmpty)
          const AppEmptyState(
            icon: AppIcons.inbox,
            title: 'Nada por aqui',
            description: 'Este módulo ainda não tem funções mapeadas.',
          )
        else
          AppModuleTileGrid(
            lastTileFullWidth: false,
            tiles: [
              for (final feature in allFeatures)
                AppModuleTile(
                  icon: featureIcon(feature.id, feature.group),
                  label: feature.title,
                  description: feature.objective,
                  layout: AppModuleTileLayout.module,
                  onTap: () => context.push(_destination(feature, segment)),
                ),
            ],
          ),
      ],
    );

    return embedded
        ? content
        : AppContentSheet(padded: false, child: content);
  }

  String _destination(FeatureDefinition feature, String segment) {
    if (feature.existingRoute case final route?) return route;
    return '/fazendas/$segment/${feature.id}';
  }
}
