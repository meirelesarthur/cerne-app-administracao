import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Uma entrada de legenda. [value] é o texto opcional à direita do rótulo
/// (valor absoluto, percentual, meta — quem chama decide o que significa).
class AppChartLegendItem {
  const AppChartLegendItem({
    required this.label,
    required this.color,
    this.value,
  });

  final String label;
  final Color color;
  final String? value;
}

/// Forma do marcador de cor — linha para séries de [AppLineChart], ponto para
/// categorias de donut/barra.
enum AppChartLegendMarker { dot, line }

/// Legenda de gráfico, compartilhada por todo o catálogo (Lei 2).
///
/// Antes desta classe cada gráfico desenhava a sua: o donut tinha uma legenda
/// embutida em coluna e os demais simplesmente não tinham. Aqui a legenda é um
/// componente só, que envolve nas duas direções conforme o espaço disponível.
class AppChartLegend extends StatelessWidget {
  const AppChartLegend({
    super.key,
    required this.items,
    this.marker = AppChartLegendMarker.dot,
    this.direction = Axis.horizontal,
  });

  final List<AppChartLegendItem> items;
  final AppChartLegendMarker marker;

  /// `horizontal` envolve em linhas (padrão, abaixo do gráfico); `vertical`
  /// empilha (ao lado de um donut, por exemplo).
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final entries = [
      for (final item in items) _Entry(item: item, marker: marker),
    ];

    if (direction == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space1),
              child: entry,
            ),
        ],
      );
    }

    return Wrap(
      spacing: AppSpacing.space4,
      runSpacing: AppSpacing.space2,
      children: entries,
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.item, required this.marker});

  final AppChartLegendItem item;
  final AppChartLegendMarker marker;

  // 10px: mesma medida do ponto que o donut já usava.
  static const double _dot = AppSpacing.twoHalf;
  static const double _lineWidth = AppSpacing.space4;
  static const double _lineHeight = AppSpacing.half;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isLine = marker == AppChartLegendMarker.line;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isLine ? _lineWidth : _dot,
          height: isLine ? _lineHeight : _dot,
          decoration: BoxDecoration(
            color: item.color,
            shape: isLine ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isLine ? BorderRadius.circular(AppRadius.full) : null,
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        Text(
          item.label,
          style: TextStyle(fontSize: AppTypography.md, color: semantic.fgMuted),
        ),
        if (item.value != null) ...[
          const SizedBox(width: AppSpacing.space2),
          Text(
            item.value!,
            style: TextStyle(
              fontSize: AppTypography.md,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
            ),
          ),
        ],
      ],
    );
  }
}

WidgetbookComponent buildChartLegendWidgetbookComponent() {
  List<AppChartLegendItem> sample(BuildContext context) {
    final series = Theme.of(
      context,
    ).extension<AppSemanticColors>()!.chartSeries;
    return [
      AppChartLegendItem(
        label: 'Receita',
        color: series[0],
        value: 'R\$ 2,4 mi',
      ),
      AppChartLegendItem(label: 'Custo', color: series[5], value: 'R\$ 1,1 mi'),
      AppChartLegendItem(
        label: 'Margem',
        color: series[1],
        value: 'R\$ 1,3 mi',
      ),
    ];
  }

  return WidgetbookComponent(
    name: 'ChartLegend',
    useCases: [
      WidgetbookUseCase(
        name: 'Horizontal (ponto)',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppChartLegend(items: sample(context)),
        ),
      ),
      WidgetbookUseCase(
        name: 'Horizontal (linha)',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppChartLegend(
            items: sample(context),
            marker: AppChartLegendMarker.line,
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Vertical',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppChartLegend(
            items: sample(context),
            direction: Axis.vertical,
          ),
        ),
      ),
    ],
  );
}
