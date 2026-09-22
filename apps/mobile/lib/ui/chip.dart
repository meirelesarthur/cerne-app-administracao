import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';

/// Espelha `Chip.tsx` — cor semântica única e parametrizável (spec §6.9),
/// reutilizada em todos os badges de status. Não depende de tema (light/gbMode)
/// pois usa diretamente as escalas cruas de `AppColors`, igual ao React original
/// (`bg-brand-50`, `bg-blue-50`, etc. não são tokens semânticos de tema).
///
/// Padding horizontal/vertical (10px/4px) é um valor fixo de design fora da
/// escala de espaçamento — mesmo padrão de `_spinnerSize` em `button.dart`.
enum AppChipTone { brand, blue, amber, red, neutral }

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    this.tone = AppChipTone.neutral,
    required this.child,
    this.icon,
  });

  final AppChipTone tone;
  final Widget child;
  final Widget? icon;

  ({Color bg, Color fg, Color border}) get _colors => switch (tone) {
    AppChipTone.brand => (
      bg: AppColors.brand50,
      fg: AppColors.brand700,
      border: AppColors.brand200,
    ),
    AppChipTone.blue => (
      bg: AppColors.blue50,
      fg: AppColors.blue600,
      border: AppColors.blue200,
    ),
    AppChipTone.amber => (
      bg: AppColors.amber50,
      fg: AppColors.amber600,
      border: AppColors.amber200,
    ),
    AppChipTone.red => (
      bg: AppColors.red50,
      fg: AppColors.red600,
      border: AppColors.red200,
    ),
    AppChipTone.neutral => (
      bg: AppColors.neutral100,
      fg: AppColors.neutral600,
      border: AppColors.neutral200,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = _colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.twoHalf,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: colors.fg, size: 14),
              child: icon!,
            ),
            const SizedBox(width: AppSpacing.space1),
          ],
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: AppTypography.xs,
              fontWeight: AppTypography.weightSemibold,
              color: colors.fg,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildChipWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Chip',
    useCases: [
      WidgetbookUseCase(
        name: 'Tons',
        builder: (context) => const Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(tone: AppChipTone.brand, child: Text('Aprovado')),
              AppChip(tone: AppChipTone.blue, child: Text('Em análise')),
              AppChip(tone: AppChipTone.amber, child: Text('Pendente')),
              AppChip(tone: AppChipTone.red, child: Text('Recusado')),
              AppChip(child: Text('Neutro')),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Com ícone',
        builder: (context) => const Center(
          child: AppChip(
            tone: AppChipTone.brand,
            icon: AppIcon(AppIcons.check),
            child: Text('Concluído'),
          ),
        ),
      ),
    ],
  );
}
