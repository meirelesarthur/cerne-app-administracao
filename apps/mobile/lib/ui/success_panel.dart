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

/// Espelha `SuccessPanel.tsx` — painel de sucesso genérico pós-operação, no
/// padrão da SuccessScreen de Fazendas (NEW_UI_SUPERAPP.md). A navegação de
/// saída é responsabilidade da tela chamadora, passada via [actions]
/// (botões de `ui/`), equivalente ao `children` do React.
class AppSuccessPanel extends StatelessWidget {
  const AppSuccessPanel({
    super.key,
    required this.title,
    this.description,
    this.icon = AppIcons.checkCircle2,
    this.actions,
  });

  final String title;
  final Widget? description;
  final AppIconData icon;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      color: semantic.bgCanvas,
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.space16,
              height: AppSpacing.space16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl2),
                color: AppColors.brand50,
              ),
              child: AppIcon(
                icon,
                size: AppSize.iconXxl,
                color: semantic.accentDefault,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppHeading(child: Text(title, textAlign: TextAlign.center)),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.space4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    color: semantic.fgMuted,
                  ),
                  textAlign: TextAlign.center,
                  child: description!,
                ),
              ),
            ],
            if (actions != null) ...[
              const SizedBox(height: AppSpacing.space2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: SizedBox(width: double.infinity, child: actions!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildSuccessPanelWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'SuccessPanel',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => SizedBox(
          height: 480,
          child: AppSuccessPanel(
            title: 'Transferência concluída',
            description: const Text(
              'O valor de R\$ 1.200,00 foi enviado com sucesso.',
            ),
            actions: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  fullWidth: true,
                  onPressed: () {},
                  child: const Text('Ver comprovante'),
                ),
                const SizedBox(height: AppSpacing.space2),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () {},
                  child: const Text('Voltar ao início'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
