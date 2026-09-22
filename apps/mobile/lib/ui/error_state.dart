import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'button.dart';
import 'heading.dart';
import '../design/generated/app_layout.dart';

/// Espelha `ErrorState.tsx` — estado de erro de carregamento com retry
/// (spec §7.1). Compõe `AppHeading` (nível 3) + `AppButton` (variant
/// secondary), nunca reimplementa botão/título localmente (Lei 2).
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Não foi possível carregar',
    this.description = 'Ocorreu um erro ao buscar os dados. Tente novamente.',
    this.onRetry,
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;

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
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space4),
            child: Container(
              width: AppSpacing.space14,
              height: AppSpacing.space14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.red50,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: const AppIcon(
                AppIcons.triangleAlert,
                size: AppSize.iconLg,
                color: AppColors.red600,
              ),
            ),
          ),
          AppHeading(
            level: AppHeadingLevel.h3,
            child: Text(title, textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space1),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  color: semantic.fgMuted,
                ),
              ),
            ),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space4),
              child: AppButton(
                variant: AppButtonVariant.secondary,
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
            ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildErrorStateWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ErrorState',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => Center(child: AppErrorState(onRetry: () {})),
      ),
      WidgetbookUseCase(
        name: 'Sem retry',
        builder: (context) => const Center(
          child: AppErrorState(
            title: 'Falha ao sincronizar',
            description: 'Verifique sua conexão e tente novamente mais tarde.',
          ),
        ),
      ),
    ],
  );
}
