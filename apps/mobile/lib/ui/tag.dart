import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Tom do rótulo. `neutral` é o metadado de sempre (categoria, safra, talhão);
/// os demais são os badges de status do padrão global do Figma
/// (`Pré-aprovado`, `Em análise`, `Aprovado` — 54300:16147, 54333:443).
enum AppTagTone { neutral, success, warning, danger }

/// Espelha `Tag.tsx` — rótulo compacto de metadado ou de status.
///
/// Anatomia do padrão global: rótulo de **contorno** (fundo transparente),
/// `px 8 / py 3`, raio squircle (não mais pílula), rótulo de 10 px Medium na
/// cor do tom, e um ícone opcional de 14 px à esquerda (o `PartyPopperIcon`
/// do "Aprovado").
///
/// Diferente do `AppChip`, que é preenchido e maior — o chip é filtro e estado
/// de tela; a tag é uma anotação dentro de outro bloco.
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.child,
    this.tone = AppTagTone.neutral,
    this.icon,
  });

  final Widget child;
  final AppTagTone tone;

  /// Ícone de 14 px à esquerda do rótulo.
  final AppIconData? icon;

  Color _color(AppSemanticColors semantic) => switch (tone) {
    AppTagTone.neutral => semantic.fgMuted,
    AppTagTone.success => AppColors.feedbackSuccessText,
    AppTagTone.warning => AppColors.feedbackWarningText,
    AppTagTone.danger => AppColors.feedbackErrorText,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final color = _color(semantic);
    final borderColor = tone == AppTagTone.neutral
        ? semantic.borderDefault
        : color;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.threeQuarter,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(icon!, size: AppSize.iconXs, color: color),
            const SizedBox(width: AppSpacing.half),
          ],
          DefaultTextStyle(
            style: TextStyle(
              fontSize: AppTypography.xs2,
              fontWeight: AppTypography.weightMedium,
              color: color,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildTagWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Tag',
    useCases: [
      WidgetbookUseCase(
        name: 'Metadado',
        builder: (context) => const Center(
          child: Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              AppTag(child: Text('Grão')),
              AppTag(child: Text('Safra 24/25')),
              AppTag(child: Text('Talhão 12')),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Status de crédito',
        builder: (context) => const Center(
          child: Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              AppTag(tone: AppTagTone.success, child: Text('Pré-aprovado')),
              AppTag(tone: AppTagTone.warning, child: Text('Em análise')),
              AppTag(
                tone: AppTagTone.success,
                icon: AppIcons.partyPopper,
                child: Text('Aprovado'),
              ),
              AppTag(tone: AppTagTone.danger, child: Text('Recusado')),
            ],
          ),
        ),
      ),
    ],
  );
}
