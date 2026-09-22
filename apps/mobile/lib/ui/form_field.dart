import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'text_input.dart';

/// Espelha `FormField.tsx` — wrapper de campo: label + controle (`child`) + hint/erro.
/// O controle é sempre um widget do catálogo (`AppTextInput`, `AppFormSelect`, etc.),
/// nunca um `TextField` cru — a tela só compõe.
///
/// Anatomia do padrão global (Figma `54349:2008`): rótulo de 14 px **Medium**
/// abafado com altura de linha 24 e `pb 4` antes do controle — não o 12 px
/// SemiBold escuro de antes. O `helpIcon` de 16 px cobre o
/// `Icon / QuestionCircleOutlined` da referência, que explica o campo sem
/// gastar uma linha de hint.
///
/// Desvio do React: não existe `htmlFor`/`id` de DOM no Flutter; associe rótulo e
/// controle usando o mesmo `FocusNode`/`Semantics` no widget filho, se necessário.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.error,
    this.required = false,
    this.helpIcon,
  });

  final String label;
  final Widget child;
  final String? hint;
  final String? error;
  final bool required;

  /// Ícone de ajuda de 16 px ao lado do rótulo (Figma 54349:2011). Puramente
  /// visual: a explicação em si continua sendo trabalho do [hint].
  final AppIconData? helpIcon;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      container: true,
      label: required ? '$label, obrigatório' : label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.md,
                  fontWeight: AppTypography.weightMedium,
                  color: semantic.fgMuted,
                ),
              ),
              if (required)
                const Text(
                  '*',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.md,
                    fontWeight: AppTypography.weightMedium,
                    color: AppColors.feedbackErrorText,
                  ),
                ),
              if (helpIcon != null) ...[
                const SizedBox(width: AppSpacing.space1),
                AppIcon(
                  helpIcon!,
                  size: AppSize.iconSm,
                  color: semantic.fgSubtle,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          child,
          if (error != null) ...[
            const SizedBox(height: AppSpacing.space2),
            Semantics(
              liveRegion: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon(
                    AppIcons.alertCircle,
                    size: AppSize.iconXs,
                    color: AppColors.feedbackErrorText,
                  ),
                  const SizedBox(width: AppSpacing.space1),
                  Flexible(
                    child: Text(
                      error!,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.sm,
                        fontWeight: AppTypography.weightMedium,
                        color: AppColors.feedbackErrorText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (hint != null) ...[
            const SizedBox(height: AppSpacing.space2),
            Text(
              hint!,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.sm,
                color: semantic.fgSubtle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

WidgetbookComponent buildFormFieldWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'FormField',
    useCases: [
      WidgetbookUseCase(
        name: 'Estados',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppFormField(
                  label: 'Nome da fazenda',
                  required: true,
                  helpIcon: AppIcons.helpCircle,
                  hint: 'Como aparece nos relatórios',
                  child: AppTextInput(placeholder: 'Fazenda Boa Vista'),
                ),
                SizedBox(height: AppSpacing.space6),
                AppFormField(
                  label: 'CNPJ',
                  required: true,
                  error: 'CNPJ inválido',
                  child: AppTextInput(
                    placeholder: '00.000.000/0000-00',
                    invalid: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
