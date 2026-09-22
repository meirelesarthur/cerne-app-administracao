import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'chart_legend.dart';
import 'chart_sampling.dart';
import 'chart_scale.dart';

/// Uma série do [AppLineChart]. [points] tem um valor por rótulo do eixo X.
class AppLineSeries {
  const AppLineSeries({
    required this.label,
    required this.points,
    this.color,
    this.filled = false,
  });

  final String label;
  final List<double> points;

  /// Sem valor, usa `AppSemanticColors.chartSeries[i]` do tema ativo.
  final Color? color;

  /// Preenche a área sob a linha com um degradê da própria cor. Reservado à
  /// série principal — duas áreas empilhadas viram sopa visual.
  final bool filled;
}

/// Gráfico de linha com eixo de valor, grade e múltiplas séries.
///
/// É o componente que faltava no catálogo: `AppSparklineArea` é decorativa
/// (sem eixo, sem escala) e não responde à pergunta de gestão "isso está
/// subindo há quantos meses?". Aqui há escala redonda ([ChartScale]), grade,
/// rótulos nos dois eixos e marcação do último ponto de cada série.
///
/// Pintado via [CustomPainter], como os demais gráficos do projeto.
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.series,
    required this.labels,
    this.height = 190,
    this.formatValue,
    this.showLegend = true,
    this.compact = false,
    this.maxPoints = 120,
  });

  final List<AppLineSeries> series;

  /// Rótulos do eixo X — um por ponto das séries.
  final List<String> labels;

  final double height;

  /// Formata os rótulos do eixo Y e a legenda; padrão: número redondo.
  final String Function(double value)? formatValue;

  final bool showLegend;

  /// Versão para a Home: sem legenda e sem rótulos do eixo Y, só a forma da
  /// curva. Mesmo widget, densidade menor — nunca uma segunda implementação.
  final bool compact;

  /// Limite de pontos pintados. Séries maiores são amostradas uniformemente,
  /// mantendo o primeiro e o último ponto para preservar o contexto temporal.
  final int maxPoints;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final palette = semantic.chartSeries;
    final fmt = formatValue ?? formatAxisValue;

    var pointCount = series.isEmpty
        ? 0
        : series.map((s) => s.points.length).reduce(math.min);
    if (labels.isNotEmpty) pointCount = math.min(pointCount, labels.length);
    final indexes = sampleChartIndexes(pointCount, maxPoints);
    final visibleSeries = [
      for (final item in series)
        AppLineSeries(
          label: item.label,
          points: [for (final index in indexes) item.points[index]],
          color: item.color,
          filled: item.filled,
        ),
    ];
    final visibleLabels = labels.isEmpty
        ? <String>[]
        : [for (final index in indexes) labels[index]];

    Color colorOf(int i) =>
        visibleSeries[i].color ?? palette[i % palette.length];

    final scale = ChartScale.forValues(visibleSeries.expand((s) => s.points));

    final chart = SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(
          series: visibleSeries,
          labels: visibleLabels,
          scale: scale,
          colorOf: colorOf,
          formatValue: fmt,
          gridColor: semantic.chartGrid,
          axisColor: semantic.chartAxis,
          showValueAxis: !compact,
          showLabels: !compact,
        ),
      ),
    );

    if (compact || !showLegend || visibleSeries.isEmpty) return chart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        chart,
        const SizedBox(height: AppSpacing.space3),
        AppChartLegend(
          marker: AppChartLegendMarker.line,
          items: [
            for (var i = 0; i < visibleSeries.length; i++)
              AppChartLegendItem(
                label: visibleSeries[i].label,
                color: colorOf(i),
                value: visibleSeries[i].points.isEmpty
                    ? null
                    : fmt(visibleSeries[i].points.last),
              ),
          ],
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.labels,
    required this.scale,
    required this.colorOf,
    required this.formatValue,
    required this.gridColor,
    required this.axisColor,
    required this.showValueAxis,
    required this.showLabels,
  });

  final List<AppLineSeries> series;
  final List<String> labels;
  final ChartScale scale;
  final Color Function(int index) colorOf;
  final String Function(double value) formatValue;
  final Color gridColor;
  final Color axisColor;
  final bool showValueAxis;
  final bool showLabels;

  static const double _strokeWidth = AppSpacing.half;
  static const double _dotRadius = AppSpacing.oneHalf / 2;
  static const double _axisGap = AppSpacing.space2;
  static const double _xAxisHeight = AppSpacing.space5;

  TextPainter _text(String value, Color color) => TextPainter(
    text: TextSpan(
      text: value,
      style: TextStyle(fontSize: AppTypography.xs, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final ticks = scale.ticks;

    // Reserva de espaço para os eixos, medida no texto real dos rótulos — não
    // numa largura chutada, que corta valores longos como "R$ 1.200".
    var axisWidth = 0.0;
    if (showValueAxis) {
      for (final tick in ticks) {
        axisWidth = math.max(
          axisWidth,
          _text(formatValue(tick), axisColor).width,
        );
      }
      axisWidth += _axisGap;
    }
    final bottom = showLabels && labels.isNotEmpty ? _xAxisHeight : 0.0;

    final plot = Rect.fromLTWH(
      axisWidth,
      _dotRadius,
      size.width - axisWidth,
      size.height - bottom - _dotRadius,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    _paintGrid(canvas, plot, ticks);
    if (showLabels && labels.isNotEmpty) _paintXLabels(canvas, plot, size);

    for (var i = 0; i < series.length; i++) {
      _paintSeries(canvas, plot, series[i], colorOf(i));
    }
  }

  void _paintGrid(Canvas canvas, Rect plot, List<double> ticks) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = AppSpacing.quarter;

    for (final tick in ticks) {
      final y = plot.bottom - scale.fraction(tick) * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      if (!showValueAxis) continue;
      final label = _text(formatValue(tick), axisColor);
      label.paint(
        canvas,
        Offset(plot.left - _axisGap - label.width, y - label.height / 2),
      );
    }
  }

  void _paintXLabels(Canvas canvas, Rect plot, Size size) {
    // Com muitos pontos os rótulos colidem; mostra o primeiro, o último e um a
    // cada `stride` — melhor do que sobrepor texto ilegível.
    final count = labels.length;
    final maxLabels = (plot.width / (AppSpacing.space10)).floor().clamp(
      2,
      count,
    );
    final stride = (count / maxLabels).ceil();

    for (var i = 0; i < count; i++) {
      final isEdge = i == 0 || i == count - 1;
      if (!isEdge && i % stride != 0) continue;
      final x = _xFor(plot, i, count);
      final label = _text(labels[i], axisColor);
      var left = x - label.width / 2;
      left = left.clamp(plot.left, size.width - label.width);
      label.paint(canvas, Offset(left, plot.bottom + _axisGap));
    }
  }

  double _xFor(Rect plot, int index, int count) => count <= 1
      ? plot.center.dx
      : plot.left + plot.width * (index / (count - 1));

  void _paintSeries(Canvas canvas, Rect plot, AppLineSeries s, Color color) {
    if (s.points.length < 2) return;

    final count = s.points.length;
    final points = [
      for (var i = 0; i < count; i++)
        Offset(
          _xFor(plot, i, count),
          plot.bottom - scale.fraction(s.points[i]) * plot.height,
        ),
    ];

    final path = _smoothPath(points);

    if (s.filled) {
      final area = Path.from(path)
        ..lineTo(points.last.dx, plot.bottom)
        ..lineTo(points.first.dx, plot.bottom)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(plot.left, plot.top),
            Offset(plot.left, plot.bottom),
            [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
          ),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Ponto final destacado: é o valor "de hoje", o que o gestor procura.
    canvas.drawCircle(points.last, _dotRadius * 2, Paint()..color = color);
  }

  /// Curva suave sem overshoot: cada segmento usa uma cúbica cujos controles
  /// ficam a 1/3 do caminho no eixo X, o que mantém a linha dentro da faixa de
  /// valores reais (um Catmull-Rom puro inventaria picos que não existem).
  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final dx = (p1.dx - p0.dx) / 3;
      path.cubicTo(p0.dx + dx, p0.dy, p1.dx - dx, p1.dy, p1.dx, p1.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.series != series ||
      old.labels != labels ||
      old.scale.min != scale.min ||
      old.scale.max != scale.max ||
      old.gridColor != gridColor ||
      old.axisColor != axisColor ||
      old.showValueAxis != showValueAxis ||
      old.showLabels != showLabels;
}

WidgetbookComponent buildLineChartWidgetbookComponent() {
  const labels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'];
  const receita = AppLineSeries(
    label: 'Receita',
    points: [1820, 1960, 1740, 2280, 2410, 2400],
    filled: true,
  );
  const custo = AppLineSeries(
    label: 'Custo',
    points: [1180, 1240, 1090, 1160, 1120, 1100],
  );

  return WidgetbookComponent(
    name: 'LineChart',
    useCases: [
      WidgetbookUseCase(
        name: 'Duas séries',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppLineChart(
            series: const [receita, custo],
            labels: labels,
            formatValue: (v) => '${(v / 1000).toStringAsFixed(1)}mi',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Série única com área',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppLineChart(series: [receita], labels: labels),
        ),
      ),
      WidgetbookUseCase(
        name: 'Compacto (Home)',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppLineChart(
            series: [receita, custo],
            labels: labels,
            compact: true,
          ),
        ),
      ),
    ],
  );
}
