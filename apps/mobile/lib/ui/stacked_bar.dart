import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'chart_legend.dart';
import 'chart_sampling.dart';
import 'chart_scale.dart';

/// Uma coluna do [AppStackedBar] — um período, com um valor por categoria.
/// A ordem de [values] precisa ser a mesma de `categories`.
class AppStackedDatum {
  const AppStackedDatum({required this.label, required this.values});

  final String label;
  final List<double> values;

  double get total => values.fold(0, (sum, v) => sum + v);
}

/// Colunas empilhadas: composição de um total ao longo do tempo.
///
/// Complementa o [AppBarChart] (que compara categorias num instante) e o
/// [AppLineChart] (que mostra a evolução de um total). Aqui a pergunta é outra:
/// *o total subiu — mas subiu por causa de qual componente?*
class AppStackedBar extends StatelessWidget {
  const AppStackedBar({
    super.key,
    required this.data,
    required this.categories,
    this.colors,
    this.height = 190,
    this.formatValue,
    this.showLegend = true,
    this.maxPoints = 120,
  });

  final List<AppStackedDatum> data;

  /// Nome de cada faixa da pilha, de baixo para cima.
  final List<String> categories;

  /// Sem valor, usa `AppSemanticColors.chartSeries` do tema ativo.
  final List<Color>? colors;

  final double height;
  final String Function(double value)? formatValue;
  final bool showLegend;

  /// Limite de períodos pintados; séries maiores são amostradas de forma
  /// uniforme para preservar desempenho e rótulos legíveis.
  final int maxPoints;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final palette = colors ?? semantic.chartSeries;
    final fmt = formatValue ?? formatAxisValue;
    final indexes = sampleChartIndexes(data.length, maxPoints);
    final visibleData = [for (final index in indexes) data[index]];
    final scale = ChartScale.forValues(visibleData.map((d) => d.total));

    final chart = SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _StackedBarPainter(
          data: visibleData,
          palette: palette,
          scale: scale,
          formatValue: fmt,
          gridColor: semantic.chartGrid,
          axisColor: semantic.chartAxis,
          trackColor: semantic.chartTrack,
        ),
      ),
    );

    if (!showLegend || categories.isEmpty) return chart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        chart,
        const SizedBox(height: AppSpacing.space3),
        AppChartLegend(
          items: [
            for (var i = 0; i < categories.length; i++)
              AppChartLegendItem(
                label: categories[i],
                color: palette[i % palette.length],
              ),
          ],
        ),
      ],
    );
  }
}

class _StackedBarPainter extends CustomPainter {
  _StackedBarPainter({
    required this.data,
    required this.palette,
    required this.scale,
    required this.formatValue,
    required this.gridColor,
    required this.axisColor,
    required this.trackColor,
  });

  final List<AppStackedDatum> data;
  final List<Color> palette;
  final ChartScale scale;
  final String Function(double value) formatValue;
  final Color gridColor;
  final Color axisColor;
  final Color trackColor;

  static const double _axisGap = AppSpacing.space2;
  static const double _xAxisHeight = AppSpacing.space5;
  static const double _maxBarWidth = AppSpacing.space10;

  TextPainter _text(String value) => TextPainter(
    text: TextSpan(
      text: value,
      style: TextStyle(fontSize: AppTypography.xs, color: axisColor),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final ticks = scale.ticks;
    var axisWidth = 0.0;
    for (final tick in ticks) {
      final w = _text(formatValue(tick)).width;
      if (w > axisWidth) axisWidth = w;
    }
    axisWidth += _axisGap;

    final plot = Rect.fromLTWH(
      axisWidth,
      0,
      size.width - axisWidth,
      size.height - _xAxisHeight,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = AppSpacing.quarter;
    for (final tick in ticks) {
      final y = plot.bottom - scale.fraction(tick) * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final label = _text(formatValue(tick));
      label.paint(
        canvas,
        Offset(plot.left - _axisGap - label.width, y - label.height / 2),
      );
    }

    final slot = plot.width / data.length;
    final barWidth = (slot * 0.55).clamp(AppSpacing.space2, _maxBarWidth);
    const radius = Radius.circular(AppRadius.sm);

    for (var i = 0; i < data.length; i++) {
      final datum = data[i];
      final centerX = plot.left + slot * (i + 0.5);
      final left = centerX - barWidth / 2;

      // Trilho até o topo da escala: dá a leitura de "quanto ainda cabia".
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, plot.top, left + barWidth, plot.bottom),
          radius,
        ),
        Paint()..color = trackColor,
      );

      var cursor = plot.bottom;
      for (var s = 0; s < datum.values.length; s++) {
        final segment = scale.fraction(datum.values[s]) * plot.height;
        if (segment <= 0) continue;
        final top = cursor - segment;
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTRB(left, top, left + barWidth, cursor),
            topLeft: s == datum.values.length - 1 ? radius : Radius.zero,
            topRight: s == datum.values.length - 1 ? radius : Radius.zero,
            bottomLeft: s == 0 ? radius : Radius.zero,
            bottomRight: s == 0 ? radius : Radius.zero,
          ),
          Paint()..color = palette[s % palette.length],
        );
        cursor = top;
      }

      final label = _text(datum.label);
      label.paint(
        canvas,
        Offset(centerX - label.width / 2, plot.bottom + _axisGap),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StackedBarPainter old) =>
      old.data != data ||
      old.palette != palette ||
      old.scale.max != scale.max ||
      old.gridColor != gridColor ||
      old.trackColor != trackColor;
}

WidgetbookComponent buildStackedBarWidgetbookComponent() {
  const sample = [
    AppStackedDatum(label: 'Jan', values: [420, 180, 260]),
    AppStackedDatum(label: 'Fev', values: [455, 165, 268]),
    AppStackedDatum(label: 'Mar', values: [398, 190, 255]),
    AppStackedDatum(label: 'Abr', values: [470, 172, 281]),
    AppStackedDatum(label: 'Mai', values: [441, 158, 274]),
    AppStackedDatum(label: 'Jun', values: [462, 149, 279]),
  ];

  return WidgetbookComponent(
    name: 'StackedBar',
    useCases: [
      WidgetbookUseCase(
        name: 'Composição de custo',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppStackedBar(
            data: sample,
            categories: const ['Nutrição', 'Sanidade', 'Mão de obra'],
            formatValue: (v) => '${v.toStringAsFixed(0)}k',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Sem legenda',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppStackedBar(data: sample, categories: [], showLegend: false),
        ),
      ),
    ],
  );
}
