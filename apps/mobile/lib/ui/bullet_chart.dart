import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Uma linha do [AppBulletChart]: o que foi realizado contra o que era a meta.
class AppBulletDatum {
  const AppBulletDatum({
    required this.label,
    required this.value,
    required this.target,
    this.color,
  });

  final String label;
  final double value;
  final double target;

  /// Sem valor, a barra é pintada por desempenho: verde ao bater a meta, âmbar
  /// entre 80% e 100% dela, vermelho abaixo disso. Indicadores em que **menor é
  /// melhor** (preço, prazo) precisam passar a cor explicitamente — o padrão
  /// assume "maior é melhor".
  final Color? color;
}

/// Gráfico de marcador (bullet): barra do realizado + traço da meta, uma linha
/// por indicador.
///
/// Responde "bateu ou não bateu" em um traço, sem gastar a altura de um gráfico
/// de barras agrupadas nem a área de um par de KPIs. É a forma certa para
/// economia em cotações, GMD contra o previsto e precisão de batelada.
class AppBulletChart extends StatelessWidget {
  const AppBulletChart({
    super.key,
    required this.data,
    this.formatValue,
    this.targetLabel = 'meta',
    this.maxItems = 12,
  });

  final List<AppBulletDatum> data;

  /// Formata o valor exibido à direita de cada linha.
  final String Function(double value)? formatValue;

  /// Palavra usada no texto de meta ("meta 1,55").
  final String targetLabel;

  /// Limite de indicadores pintados para manter a leitura estável em bases
  /// grandes. O filtro da tela pode ser usado para detalhar um item específico.
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final fmt = formatValue ?? (double v) => v.toStringAsFixed(0);
    final limit = maxItems < 1 ? 1 : maxItems;
    final visibleData = data.take(limit).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final datum in visibleData)
          Padding(
            padding: EdgeInsets.only(
              bottom: datum == visibleData.last
                  ? AppSpacing.space0
                  : AppSpacing.space4,
            ),
            child: _BulletRow(
              datum: datum,
              formatValue: fmt,
              targetLabel: targetLabel,
            ),
          ),
        if (visibleData.length < data.length) ...[
          const SizedBox(height: AppSpacing.space3),
          Text(
            'Exibindo ${visibleData.length} de ${data.length}. Use os filtros para detalhar.',
            style: TextStyle(
              fontSize: AppTypography.xs,
              color: Theme.of(context).extension<AppSemanticColors>()!.fgSubtle,
            ),
          ),
        ],
      ],
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.datum,
    required this.formatValue,
    required this.targetLabel,
  });

  final AppBulletDatum datum;
  final String Function(double value) formatValue;
  final String targetLabel;

  static const double _trackHeight = AppSpacing.twoHalf;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ratio = datum.target <= 0 ? 1.0 : datum.value / datum.target;
    final color =
        datum.color ??
        (ratio >= 1
            ? semantic.chartPositive
            : ratio >= 0.8
            ? AppColors.amber600
            : semantic.chartNegative);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                datum.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  color: semantic.fgMuted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Text(
              formatValue(datum.value),
              style: TextStyle(
                fontSize: AppTypography.md,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space2),
        SizedBox(
          height: _trackHeight,
          child: CustomPaint(
            painter: _BulletPainter(
              value: datum.value,
              target: datum.target,
              color: color,
              trackColor: semantic.chartTrack,
              markerColor: semantic.fgDefault,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space1),
        Text(
          '$targetLabel ${formatValue(datum.target)}',
          style: TextStyle(
            fontSize: AppTypography.xs,
            color: semantic.fgSubtle,
          ),
        ),
      ],
    );
  }
}

class _BulletPainter extends CustomPainter {
  _BulletPainter({
    required this.value,
    required this.target,
    required this.color,
    required this.trackColor,
    required this.markerColor,
  });

  final double value;
  final double target;
  final Color color;
  final Color trackColor;
  final Color markerColor;

  @override
  void paint(Canvas canvas, Size size) {
    // A escala vai até o maior entre realizado e meta, com uma folga de 10%:
    // se a meta encostasse na borda, "bateu" e "estourou" ficariam iguais.
    final ceiling = math.max(value, target) * 1.1;
    if (ceiling <= 0) return;

    const radius = Radius.circular(AppRadius.full);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = trackColor,
    );

    final width = size.width * (value / ceiling).clamp(0.0, 1.0);
    if (width > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, width, size.height),
          radius,
        ),
        Paint()..color = color,
      );
    }

    final markerX = size.width * (target / ceiling).clamp(0.0, 1.0);
    canvas.drawLine(
      Offset(markerX, -AppSpacing.quarter),
      Offset(markerX, size.height + AppSpacing.quarter),
      Paint()
        ..color = markerColor
        ..strokeWidth = AppSpacing.half
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BulletPainter old) =>
      old.value != value ||
      old.target != target ||
      old.color != color ||
      old.trackColor != trackColor;
}

WidgetbookComponent buildBulletChartWidgetbookComponent() {
  const sample = [
    AppBulletDatum(label: 'Economia em cotações', value: 82, target: 70),
    AppBulletDatum(label: 'Precisão de batelada', value: 93, target: 95),
    AppBulletDatum(label: 'Prazo médio de entrega', value: 48, target: 72),
  ];

  return WidgetbookComponent(
    name: 'BulletChart',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppBulletChart(data: sample),
        ),
      ),
      WidgetbookUseCase(
        name: 'Com unidade',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppBulletChart(
            data: const [
              AppBulletDatum(label: 'GMD do lote', value: 1.42, target: 1.55),
            ],
            formatValue: (v) =>
                '${v.toStringAsFixed(2).replaceAll('.', ',')} kg',
          ),
        ),
      ),
    ],
  );
}
