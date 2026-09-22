import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/theme/app_theme_extension.dart';

/// Espelha `SparklineArea.tsx` — sparkline usada nos cards de dashboard
/// (consumida por `DashboardCard`/`AppDashboardCard`).
/// Pintado via [CustomPainter] (ADR do projeto): reproduz a mesma matemática de
/// pontos/gradiente do `<path>`/`<linearGradient>` SVG original.
class AppSparklineArea extends StatelessWidget {
  const AppSparklineArea({
    super.key,
    required this.data,
    this.color,
    this.width = 120,
    this.height = 36,
  });

  final List<double> data;

  /// Cor da linha/área; sem valor, usa `AppSemanticColors.accentDefault`
  /// (equivalente ao fallback `#059669` do React, que é `brand600`/`accentDefault` no tema claro).
  final Color? color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return const SizedBox.shrink();

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final lineColor = color ?? semantic.accentDefault;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklineAreaPainter(data: data, color: lineColor),
      ),
    );
  }
}

class _SparklineAreaPainter extends CustomPainter {
  _SparklineAreaPainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    final range = (max - min) == 0 ? 1.0 : (max - min);
    final stepX = size.width / (data.length - 1);

    final points = <Offset>[
      for (var i = 0; i < data.length; i++)
        Offset(
          i * stepX,
          size.height - ((data[i] - min) / range) * (size.height - 4) - 2,
        ),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final gradientPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
      );
    canvas.drawPath(areaPath, gradientPaint);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklineAreaPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

WidgetbookComponent buildSparklineAreaWidgetbookComponent() {
  const sample = [12.0, 18.0, 15.0, 24.0, 20.0, 30.0, 26.0, 34.0];

  return WidgetbookComponent(
    name: 'SparklineArea',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) =>
            const Center(child: AppSparklineArea(data: sample)),
      ),
      WidgetbookUseCase(
        name: 'Cor customizada',
        builder: (context) => Center(
          child: AppSparklineArea(
            data: sample,
            color: Theme.of(context).colorScheme.error,
            width: 160,
            height: 48,
          ),
        ),
      ),
    ],
  );
}
