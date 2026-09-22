import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'heading.dart';
import '../design/generated/app_layout.dart';

/// Espelha `EmptyState.tsx` — estado vazio (lista/dado ausente), com ícone
/// opcional, título (`AppHeading` nível 3), descrição e ação opcionais.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.description,
    this.action,
  });

  final AppIconData? icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space4),
              child: Container(
                width: AppSpacing.space14,
                height: AppSpacing.space14,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: semantic.bgSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                ),
                child: AppIcon(
                  icon,
                  size: AppSize.iconLg,
                  color: semantic.fgSubtle,
                ),
              ),
            ),
          AppHeading(
            level: AppHeadingLevel.h3,
            child: Text(title, textAlign: TextAlign.center),
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space1),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    color: semantic.fgMuted,
                  ),
                ),
              ),
            ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space4),
              child: action,
            ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildEmptyStateWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'EmptyState',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Center(
          child: AppEmptyState(
            icon: AppIcons.inbox,
            title: 'Nenhum lançamento encontrado',
            description: 'Ajuste os filtros ou tente novamente mais tarde.',
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Sem ícone',
        builder: (context) =>
            const Center(child: AppEmptyState(title: 'Sem dados no período')),
      ),
    ],
  );
}
