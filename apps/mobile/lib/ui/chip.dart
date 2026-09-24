import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha `Chip.tsx` — cor semântica única e parametrizável (spec §6.9),
/// reutilizada em todos os badges de status. As cores vêm dos tokens de tom
/// theme-aware (`tone*` em [AppSemanticColors]): no tema claro são as mesmas
/// escalas `*50/200/600` de antes; no gbMode, fundo translúcido do matiz em vez
/// de um bloco pastel claro sobre o verde escuro.
///
/// Padding horizontal/vertical (10px/4px) é um valor fixo de design fora da
/// escala de espaçamento — mesmo padrão de `_spinnerSize` em `button.dart`.
enum AppChipTone { brand, blue, amber, red, neutral }

/// Fundo, texto e borda de um tom no tema atual — fonte única para chips e
/// para qualquer superfície tonal (ex.: blocos de aviso do detalhe).
({Color bg, Color fg, Color border}) appToneColors(
  AppSemanticColors s,
  AppChipTone tone,
) => switch (tone) {
  AppChipTone.brand => (
    bg: s.toneBrandBg,
    fg: s.toneBrandFg,
    border: s.toneBrandBorder,
  ),
  AppChipTone.blue => (
    bg: s.toneBlueBg,
    fg: s.toneBlueFg,
    border: s.toneBlueBorder,
  ),
  AppChipTone.amber => (
    bg: s.toneAmberBg,
    fg: s.toneAmberFg,
    border: s.toneAmberBorder,
  ),
  AppChipTone.red => (
    bg: s.toneRedBg,
    fg: s.toneRedFg,
    border: s.toneRedBorder,
  ),
  AppChipTone.neutral => (
    bg: s.toneNeutralBg,
    fg: s.toneNeutralFg,
    border: s.toneNeutralBorder,
  ),
};

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

  @override
  Widget build(BuildContext context) {
    final colors = appToneColors(
      Theme.of(context).extension<AppSemanticColors>()!,
      tone,
    );

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
