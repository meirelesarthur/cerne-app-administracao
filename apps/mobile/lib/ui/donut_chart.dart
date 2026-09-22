import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'chart_legend.dart';
import 'empty_state.dart';

/// Uma fatia do [AppDonutChart] — espelha `DonutSlice` de `DonutChart.tsx`.
class AppDonutSlice {
  const AppDonutSlice({required this.label, required this.value, this.color});

  final String label;
  final double value;

  /// Cor da fatia; sem valor, usa `AppSemanticColors.chartSeries` do tema ativo.
  final Color? color;
}

/// Donut com legenda, pintado via [CustomPainter] (ADR do projeto): os arcos
/// reproduzem os `<circle stroke-dasharray>` do SVG original com `drawArc`.
///
/// A legenda passou a ser o [AppChartLegend] compartilhado e a trazer o
/// percentual de cada fatia — sem ele o donut informa a ordem das categorias,
/// mas não o peso de cada uma, que é justamente a decisão.
class AppDonutChart extends StatelessWidget {
  const AppDonutChart({
    super.key,
    required this.data,
    this.size = 140,
    this.thickness = 20,
    this.centerLabel,
    this.centerValue,
    this.showPercent = true,
    this.emptyLabel = 'Sem dados no período',
  });

  final List<AppDonutSlice> data;
  final double size;
  final double thickness;
  final String? centerLabel;
  final String? centerValue;

  /// Exibe o percentual de cada fatia ao lado do rótulo na legenda.
  final bool showPercent;

  /// Texto do estado vazio — um donut sem fatias, antes, desenhava nada e
  /// deixava um buraco silencioso no card.
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final palette = semantic.chartSeries;
    final total = data.fold<double>(0, (sum, d) => sum + d.value);

    if (data.isEmpty || total <= 0) {
      return AppEmptyState(title: emptyLabel);
    }

    Color colorOf(int i) => data[i].color ?? palette[i % palette.length];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutChartPainter(
              data: data,
              colorOf: colorOf,
              thickness: thickness,
              centerLabel: centerLabel,
              centerValue: centerValue,
              valueColor: semantic.fgDefault,
              labelColor: semantic.fgMuted,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
        Flexible(
          child: AppChartLegend(
            direction: Axis.vertical,
            items: [
              for (var i = 0; i < data.length; i++)
                AppChartLegendItem(
                  label: data[i].label,
                  color: colorOf(i),
                  value: showPercent
                      ? '${((data[i].value / total) * 100).round()}%'
                      : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.data,
    required this.colorOf,
    required this.thickness,
    required this.centerLabel,
    required this.centerValue,
    required this.valueColor,
    required this.labelColor,
  });

  final List<AppDonutSlice> data;
  final Color Function(int index) colorOf;
  final double thickness;
  final String? centerLabel;
  final String? centerValue;
  final Color valueColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    final safeTotal = total <= 0 ? 1.0 : total;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    var startAngle = -math.pi / 2;
    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final sweep = (d.value / safeTotal) * 2 * math.pi;
      final paint = Paint()
        ..color = colorOf(i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    if (centerValue != null) {
      final valuePainter = TextPainter(
        text: TextSpan(
          text: centerValue,
          // 16px no React (fontSize="16") == token AppTypography.xl.
          style: TextStyle(
            fontSize: AppTypography.xl,
            fontWeight: AppTypography.weightBold,
            color: valueColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valuePainter.paint(
        canvas,
        Offset(
          center.dx - valuePainter.width / 2,
          center.dy - valuePainter.height,
        ),
      );
    }
    if (centerLabel != null) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: centerLabel,
          // 9px no React não tem token exato; AppTypography.xs (11) é o mais próximo.
          style: TextStyle(fontSize: AppTypography.xs, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(center.dx - labelPainter.width / 2, center.dy + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.thickness != thickness ||
        oldDelegate.centerLabel != centerLabel ||
        oldDelegate.centerValue != centerValue ||
        oldDelegate.valueColor != valueColor ||
        oldDelegate.labelColor != labelColor;
  }
}

WidgetbookComponent buildDonutChartWidgetbookComponent() {
  const sample = [
    AppDonutSlice(label: 'Soja', value: 45),
    AppDonutSlice(label: 'Milho', value: 30),
    AppDonutSlice(label: 'Algodão', value: 15),
    AppDonutSlice(label: 'Outros', value: 10),
  ];

  return WidgetbookComponent(
    name: 'DonutChart',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Center(child: AppDonutChart(data: sample)),
      ),
      WidgetbookUseCase(
        name: 'Com valor central',
        builder: (context) => const Center(
          child: AppDonutChart(
            data: sample,
            centerValue: '450 ha',
            centerLabel: 'total',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Vazio',
        builder: (context) => const Center(child: AppDonutChart(data: [])),
      ),
    ],
  );
}
