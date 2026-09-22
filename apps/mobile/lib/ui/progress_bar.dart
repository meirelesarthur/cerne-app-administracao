import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_motion.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `ProgressBar.tsx`.
enum AppProgressBarTone { brand, blue, amber, red }

AppProgressBarTone _occupancyTone(double pct) {
  if (pct >= 100) return AppProgressBarTone.red;
  if (pct >= 80) return AppProgressBarTone.amber;
  return AppProgressBarTone.brand;
}

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.max = 100,
    this.colorByOccupancy = false,
    this.tone = AppProgressBarTone.brand,
    this.showLabel = false,
  });

  final double value;
  final double max;

  /// Cor por ocupação (spec §4.2): verde <80%, amber 80–99%, vermelho ≥100%.
  final bool colorByOccupancy;
  final AppProgressBarTone tone;
  final bool showLabel;

  Color _toneColor(AppProgressBarTone t, AppSemanticColors semantic) =>
      switch (t) {
        AppProgressBarTone.brand => semantic.accentDefault,
        AppProgressBarTone.blue => AppColors.blue500,
        AppProgressBarTone.amber => AppColors.amber500,
        AppProgressBarTone.red => AppColors.red500,
      };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final rawPct = max == 0 ? 0.0 : (value / max) * 100;
    final pct = rawPct.clamp(0, 100).toDouble();
    final activeTone = colorByOccupancy ? _occupancyTone(rawPct) : tone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            height: AppSpacing.space2,
            width: double.infinity,
            color: semantic.bgSubtle,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: AppMotion.fast,
                widthFactor: pct / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: _toneColor(activeTone, semantic),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: AppSpacing.space1),
          Text(
            '${rawPct.round()}%',
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightMedium,
              color: semantic.fgMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// `AnimatedFractionallySizedBox` não existe em `package:flutter` — implementação
/// mínima local para animar a largura da barra ao estilo `transition-all` do React.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required super.duration,
    super.curve,
  });

  final double widthFactor;
  final Widget child;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor =
        visitor(
              _widthFactor,
              widget.widthFactor,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}

WidgetbookComponent buildProgressBarWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ProgressBar',
    useCases: [
      WidgetbookUseCase(
        name: 'Tons',
        builder: (context) => const Center(
          child: SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppProgressBar(value: 40, showLabel: true),
                SizedBox(height: AppSpacing.space4),
                AppProgressBar(
                  value: 55,
                  tone: AppProgressBarTone.blue,
                  showLabel: true,
                ),
                SizedBox(height: AppSpacing.space4),
                AppProgressBar(
                  value: 85,
                  colorByOccupancy: true,
                  showLabel: true,
                ),
                SizedBox(height: AppSpacing.space4),
                AppProgressBar(
                  value: 110,
                  colorByOccupancy: true,
                  showLabel: true,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
