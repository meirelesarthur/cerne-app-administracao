import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Badge.tsx` — contador/indicador numérico compacto (ex.: badge do
/// sino de notificações). Dimensão mínima de 18px é um valor fixo de design
/// (fora da escala de espaçamento), assim como o `_spinnerSize` de `button.dart`.
enum AppBadgeTone { brand, red, neutral }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.child,
    this.tone = AppBadgeTone.red,
  });

  final Widget child;
  final AppBadgeTone tone;

  ({Color bg, Color fg}) _colors(AppSemanticColors s) => switch (tone) {
    AppBadgeTone.brand => (bg: s.ctaBg, fg: s.ctaFg),
    AppBadgeTone.red => (bg: AppColors.red600, fg: AppColors.neutral0),
    AppBadgeTone.neutral => (
      bg: AppColors.neutral200,
      fg: AppColors.neutral700,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final colors = _colors(semantic);

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: AppTypography.xs,
          fontWeight: AppTypography.weightBold,
          height: 1.0,
          color: colors.fg,
        ),
        child: child,
      ),
    );
  }
}

WidgetbookComponent buildBadgeWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Badge',
    useCases: [
      WidgetbookUseCase(
        name: 'Tons',
        builder: (context) => const Center(
          child: Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppBadge(tone: AppBadgeTone.brand, child: Text('3')),
              AppBadge(child: Text('9')),
              AppBadge(tone: AppBadgeTone.neutral, child: Text('99+')),
            ],
          ),
        ),
      ),
    ],
  );
}
