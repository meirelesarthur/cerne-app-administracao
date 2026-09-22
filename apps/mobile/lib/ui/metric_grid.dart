import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import 'kpi_stat_card.dart';

/// Grade de blocos de métrica que deriva o número de colunas da largura
/// disponível e deixa cada bloco com a sua altura natural.
///
/// Os painéis usavam `GridView.count` com `crossAxisCount` constante (2, 3 ou
/// 4) e `childAspectRatio` fixo. Isso trazia dois defeitos: numa viewport larga
/// — o desktop CERNE ADM — continuavam em duas colunas; e como a proporção fixa
/// derivava a altura da largura da coluna, o conteúdo estourava assim que o
/// texto crescia (escala de acessibilidade) ou a coluna estreitava.
///
/// Aqui as colunas saem de [minTileWidth] e a altura vem do próprio conteúdo:
/// não há proporção para estourar. [tileHeight] existe para o caso em que a
/// altura precisa ser travada de propósito.
class AppMetricGrid extends StatelessWidget {
  const AppMetricGrid({
    super.key,
    required this.children,
    this.minTileWidth = 168,
    this.tileHeight,
    this.spacing = AppSpacing.space3,
    this.maxColumns = 4,
  });

  final List<Widget> children;

  /// Largura mínima de um bloco. Quantas couberem, tantas colunas haverá.
  final double minTileWidth;

  /// Altura fixa opcional. Sem valor — o padrão — cada bloco fica com a altura
  /// do seu conteúdo.
  final double? tileHeight;

  final double spacing;

  /// Teto de colunas: numa TV o conteúdo não deve virar uma fita de 8 colunas.
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final fits = ((available + spacing) / (minTileWidth + spacing)).floor();
        final columns = fits.clamp(1, maxColumns).clamp(1, children.length);
        final tileWidth = (available - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth, height: tileHeight, child: child),
          ],
        );
      },
    );
  }
}

WidgetbookComponent buildMetricGridWidgetbookComponent() {
  const cards = [
    AppKpiStatCard(
      label: 'A Receber',
      value: 'R\$ 1,82 mi',
      tone: AppKpiStatTone.positive,
    ),
    AppKpiStatCard(label: 'A Pagar', value: 'R\$ 940 mil'),
    AppKpiStatCard(
      label: 'Atrasados',
      value: 'R\$ 128 mil',
      tone: AppKpiStatTone.negative,
      caption: 'Vencidos > 0',
    ),
    AppKpiStatCard(label: 'Investimentos', value: 'R\$ 350 mil'),
  ];

  return WidgetbookComponent(
    name: 'MetricGrid',
    useCases: [
      WidgetbookUseCase(
        name: 'Telefone (2 colunas)',
        builder: (context) => const Center(
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.space4),
              child: AppMetricGrid(children: cards),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Desktop (4 colunas)',
        builder: (context) => const Center(
          child: SizedBox(
            width: 960,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.space4),
              child: AppMetricGrid(children: cards),
            ),
          ),
        ),
      ),
    ],
  );
}
