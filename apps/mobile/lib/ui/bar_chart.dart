import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'chart_scale.dart';

/// Um item de dado do [AppBarChart] — espelha `BarDatum` de `BarChart.tsx`.
class AppBarDatum {
  const AppBarDatum({required this.label, required this.value, this.color});

  final String label;
  final double value;

  /// Cor da barra; sem valor, usa `AppSemanticColors.chartSeries` do tema ativo.
  final Color? color;
}

/// Gráfico de barras horizontal, tokenizado.
///
/// Pintado via [CustomPainter] (ADR do projeto: os gráficos usam Canvas em vez
/// de lib de charting).
///
/// A largura da barra é estritamente proporcional ao valor. A versão anterior
/// aplicava um piso de 14% (`pct < 14 ? 14 : pct`) para caber o rótulo dentro
/// da barra, o que fazia um valor de R$ 5 mil desenhar quase a mesma barra de
/// um de R$ 59 mil — leitura falsa. Agora, quando a barra é curta demais para
/// conter o texto, o rótulo sai para fora dela em vez de a barra crescer.
class AppBarChart extends StatelessWidget {
  const AppBarChart({
    super.key,
    required this.data,
    this.height = 160,
    this.formatValue,
    this.showGrid = true,
    this.maxItems = 12,
  });

  final List<AppBarDatum> data;
  final double height;

  /// Formata o valor exibido na barra; padrão: `value.toStringAsFixed(0)`.
  final String Function(double value)? formatValue;

  /// Linhas de grade verticais na régua de valor. Desligue em cartões
  /// compactos, onde a grade compete com a barra.
  final bool showGrid;

  /// Limite de categorias pintadas. Categorias excedentes são somadas em
  /// "Outros" para evitar uma lista vertical interminável em bases grandes.
  final int maxItems;

  // w-24 (96px) do React, expresso como múltiplo de token de espaçamento.
  static const double _labelWidth = AppSpacing.space4 * 6;
  static const double _rowHeight = AppSpacing.space6; // h-6 (24px)
  static const double _rowGap = AppSpacing.space2; // gap-2 (8px)

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final fmt = formatValue ?? (double v) => v.toStringAsFixed(0);
    final chartData = _compactData(data, maxItems);
    final rowTotal = _rowHeight + _rowGap;
    final minHeight = chartData.isEmpty
        ? height
        : (chartData.length * rowTotal - _rowGap);

    return SizedBox(
      height: minHeight > height ? minHeight : height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarChartPainter(
          data: chartData,
          formatValue: fmt,
          palette: semantic.chartSeries,
          trackColor: semantic.chartTrack,
          gridColor: showGrid ? semantic.chartGrid : null,
          labelColor: semantic.fgMuted,
          outsideValueColor: semantic.fgDefault,
        ),
      ),
    );
  }
}

List<AppBarDatum> _compactData(List<AppBarDatum> data, int maxItems) {
  final limit = maxItems < 2 ? 2 : maxItems;
  if (data.length <= limit) return data;

  final visibleCount = limit - 1;
  final remainingValue = data
      .skip(visibleCount)
      .fold<double>(0, (sum, datum) => sum + datum.value);
  return [
    ...data.take(visibleCount),
    AppBarDatum(
      label: 'Outros (${data.length - visibleCount})',
      value: remainingValue,
    ),
  ];
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.data,
    required this.formatValue,
    required this.palette,
    required this.trackColor,
    required this.gridColor,
    required this.labelColor,
    required this.outsideValueColor,
  });

  final List<AppBarDatum> data;
  final String Function(double value) formatValue;
  final List<Color> palette;
  final Color trackColor;
  final Color? gridColor;
  final Color labelColor;
  final Color outsideValueColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const labelWidth = AppBarChart._labelWidth;
    const rowHeight = AppBarChart._rowHeight;
    const rowGap = AppBarChart._rowGap;
    const rowTotal = rowHeight + rowGap;
    const trackGap = AppSpacing.space2;

    final trackLeft = labelWidth + trackGap;
    final trackWidth = size.width - trackLeft;
    if (trackWidth <= 0) return;

    final scale = ChartScale.forValues(
      data.map((d) => d.value),
      targetTicks: 3,
    );

    if (gridColor != null) {
      final gridPaint = Paint()
        ..color = gridColor!
        ..strokeWidth = AppSpacing.quarter;
      for (final tick in scale.ticks) {
        final x = trackLeft + scale.fraction(tick) * trackWidth;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }

    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final top = i * rowTotal;

      final labelPainter = TextPainter(
        text: TextSpan(
          text: d.label,
          style: TextStyle(fontSize: AppTypography.md, color: labelColor),
        ),
        maxLines: 1,
        ellipsis: '…',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: labelWidth);
      labelPainter.paint(
        canvas,
        Offset(0, top + (rowHeight - labelPainter.height) / 2),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(trackLeft, top, trackWidth, rowHeight),
          const Radius.circular(AppRadius.md),
        ),
        Paint()..color = trackColor,
      );

      final barColor = d.color ?? palette[i % palette.length];
      final barWidth = scale.fraction(d.value) * trackWidth;
      if (barWidth > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(trackLeft, top, barWidth, rowHeight),
            const Radius.circular(AppRadius.md),
          ),
          Paint()..color = barColor,
        );
      }

      _paintValue(canvas, d, trackLeft, barWidth, top, rowHeight, size.width);
    }
  }

  /// Rótulo dentro da barra quando ela o comporta; fora, à direita, quando não.
  void _paintValue(
    Canvas canvas,
    AppBarDatum d,
    double trackLeft,
    double barWidth,
    double top,
    double rowHeight,
    double totalWidth,
  ) {
    const padding = AppSpacing.space2;

    TextPainter build(Color color) => TextPainter(
      text: TextSpan(
        text: formatValue(d.value),
        style: TextStyle(
          fontSize: AppTypography.xs,
          fontWeight: AppTypography.weightSemibold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final probe = build(outsideValueColor);
    final fitsInside = barWidth >= probe.width + padding * 2;
    final painter = fitsInside ? build(AppColors.neutral0) : probe;

    final x = fitsInside
        ? trackLeft + barWidth - painter.width - padding
        : (trackLeft + barWidth + padding).clamp(
            trackLeft,
            totalWidth - painter.width,
          );

    painter.paint(canvas, Offset(x, top + (rowHeight - painter.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.palette != palette ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}

WidgetbookComponent buildBarChartWidgetbookComponent() {
  const sample = [
    AppBarDatum(label: 'Jan', value: 42),
    AppBarDatum(label: 'Fev', value: 68),
    AppBarDatum(label: 'Mar', value: 55),
    AppBarDatum(label: 'Abr', value: 91),
    AppBarDatum(label: 'Mai', value: 30),
    AppBarDatum(label: 'Jun', value: 76),
  ];

  return WidgetbookComponent(
    name: 'BarChart',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppBarChart(data: sample),
        ),
      ),
      WidgetbookUseCase(
        name: 'Formatação de valor',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppBarChart(
            data: sample,
            formatValue: (v) => 'R\$ ${v.toStringAsFixed(0)}k',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Valores desiguais (rótulo sai da barra)',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppBarChart(
            data: [
              AppBarDatum(label: 'Nutrição', value: 590),
              AppBarDatum(label: 'Sanidade', value: 120),
              AppBarDatum(label: 'Logística', value: 48),
              AppBarDatum(label: 'Miúdos', value: 5),
            ],
          ),
        ),
      ),
    ],
  );
}
