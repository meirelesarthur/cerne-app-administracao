import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Leitura de cor do [AppGauge]. `auto` pinta pela ocupação — o mesmo critério
/// já usado por `AppProgressBar(colorByOccupancy: true)`: verde até 80%, âmbar
/// até 95%, vermelho acima disso.
enum AppGaugeTone { auto, positive, warning, negative, neutral }

/// Medidor radial de 270°, para indicadores que só significam algo contra um
/// teto: ocupação de curral, GMD contra a meta, precisão de batelada.
///
/// Uma barra de progresso responde "quanto"; o gauge responde "quanto do que
/// cabe", e é por isso que ele carrega a marca de meta ([target]) — o ponto em
/// que o número deixa de ser bom.
class AppGauge extends StatelessWidget {
  const AppGauge({
    super.key,
    required this.value,
    this.max = 100,
    this.size = 132,
    this.label,
    this.valueLabel,
    this.target,
    this.tone = AppGaugeTone.auto,
    this.valueFontSize,
    this.labelFontSize,
  });

  final double value;
  final double max;
  final double size;

  /// Legenda abaixo do número central.
  final String? label;

  /// Texto do número central; padrão: o percentual de [value] sobre [max].
  final String? valueLabel;

  /// Tamanho do número central; padrão [AppTypography.xl2]. Telas onde o
  /// medidor é o protagonista (ex.: progresso de sincronização) podem pedir
  /// um número maior sem afetar os demais usos do componente.
  final double? valueFontSize;

  /// Tamanho da legenda abaixo do número; padrão [AppTypography.xs].
  final double? labelFontSize;

  /// Meta, na mesma unidade de [value] — desenhada como um traço no arco.
  final double? target;

  final AppGaugeTone tone;

  double get _fraction => max <= 0 ? 0 : (value / max).clamp(0.0, 1.0);

  Color _color(AppSemanticColors s) => switch (tone) {
    AppGaugeTone.positive => s.chartPositive,
    AppGaugeTone.negative => s.chartNegative,
    AppGaugeTone.warning => AppColors.amber600,
    AppGaugeTone.neutral => s.fgMuted,
    AppGaugeTone.auto => switch (_fraction) {
      <= 0.8 => s.chartPositive,
      <= 0.95 => AppColors.amber600,
      _ => s.chartNegative,
    },
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          fraction: _fraction,
          targetFraction: target == null || max <= 0
              ? null
              : (target! / max).clamp(0.0, 1.0),
          color: _color(semantic),
          trackColor: semantic.chartTrack,
          axisColor: semantic.chartAxis,
          valueLabel: valueLabel ?? '${(_fraction * 100).round()}%',
          valueFontSize: valueFontSize ?? AppTypography.xl2,
          label: label,
          labelFontSize: labelFontSize ?? AppTypography.xs,
          valueColor: semantic.fgDefault,
          labelColor: semantic.fgMuted,
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.fraction,
    required this.targetFraction,
    required this.color,
    required this.trackColor,
    required this.axisColor,
    required this.valueLabel,
    required this.valueFontSize,
    required this.label,
    required this.labelFontSize,
    required this.valueColor,
    required this.labelColor,
  });

  final double fraction;
  final double? targetFraction;
  final Color color;
  final Color trackColor;
  final Color axisColor;
  final String valueLabel;
  final double valueFontSize;
  final String? label;
  final double labelFontSize;
  final Color valueColor;
  final Color labelColor;

  /// Arco de 270° começando embaixo à esquerda — a abertura na base é o que
  /// distingue um gauge de um donut à primeira vista.
  static const double _startAngle = math.pi * 0.75;
  static const double _sweepAngle = math.pi * 1.5;
  static const double _thickness = AppSpacing.twoHalf;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - _thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle,
      false,
      base..color = trackColor,
    );
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        _startAngle,
        _sweepAngle * fraction,
        false,
        base..color = color,
      );
    }

    if (targetFraction != null) {
      final angle = _startAngle + _sweepAngle * targetFraction!;
      final inner = radius - _thickness;
      final outer = radius + _thickness / 2;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        Paint()
          ..color = axisColor
          ..strokeWidth = AppSpacing.half
          ..strokeCap = StrokeCap.round,
      );
    }

    final valuePainter = TextPainter(
      text: TextSpan(
        text: valueLabel,
        style: TextStyle(
          fontSize: valueFontSize,
          fontWeight: AppTypography.weightBold,
          color: valueColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    TextPainter? labelPainter;
    if (label != null) {
      labelPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: labelFontSize, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: radius * 2 - _thickness * 2);
    }

    final blockHeight =
        valuePainter.height + (labelPainter == null ? 0 : labelPainter.height);
    var top = center.dy - blockHeight / 2;
    valuePainter.paint(canvas, Offset(center.dx - valuePainter.width / 2, top));
    top += valuePainter.height;
    labelPainter?.paint(
      canvas,
      Offset(center.dx - labelPainter.width / 2, top),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.fraction != fraction ||
      old.targetFraction != targetFraction ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.valueLabel != valueLabel ||
      old.valueFontSize != valueFontSize ||
      old.label != label ||
      old.labelFontSize != labelFontSize;
}

WidgetbookComponent buildGaugeWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Gauge',
    useCases: [
      WidgetbookUseCase(
        name: 'Ocupação saudável',
        builder: (context) => const Center(
          child: AppGauge(value: 64, label: 'ocupação dos currais'),
        ),
      ),
      WidgetbookUseCase(
        name: 'Ocupação crítica',
        builder: (context) => const Center(
          child: AppGauge(value: 97, label: 'ocupação dos currais'),
        ),
      ),
      WidgetbookUseCase(
        name: 'Contra meta',
        builder: (context) => const Center(
          child: AppGauge(
            value: 1.42,
            max: 1.8,
            target: 1.55,
            valueLabel: '1,42',
            label: 'GMD kg/dia · meta 1,55',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Texto grande (protagonista)',
        builder: (context) => const Center(
          child: AppGauge(
            value: 80,
            size: 200,
            tone: AppGaugeTone.positive,
            valueFontSize: AppTypography.xl2 * 2,
            labelFontSize: AppTypography.xs * 2,
            label: '80/100',
          ),
        ),
      ),
    ],
  );
}
