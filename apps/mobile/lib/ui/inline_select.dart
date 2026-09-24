import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'app_icon.dart';
import 'bottom_sheet.dart';
import 'form_select.dart';
import 'pressable.dart';

/// Seletor discreto de filtro: só o valor atual e um chevron, sem borda,
/// fundo ou contorno — cabe à direita de um título de seção sem disputar
/// espaço com ele. Tocar abre a dock inferior ([showAppBottomSheet]) com as
/// opções; a escolhida leva um check.
///
/// Diferente de [AppFormSelect] (campo de formulário, com caixa e rótulo) e
/// de `AppSearchSelect` (lista longa com busca): aqui são poucas opções que
/// filtram a tela, não um dado a ser salvo. Reusa [AppFormSelectOption] para
/// não haver dois contratos de opção no catálogo.
class AppInlineSelect extends StatelessWidget {
  const AppInlineSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.sheetTitle,
    this.semanticLabel,
  });

  final List<AppFormSelectOption> options;
  final String value;
  final ValueChanged<String> onChanged;

  /// Título da dock inferior (ex.: "Status da OS").
  final String? sheetTitle;

  /// Rótulo acessível do controle; padrão: [sheetTitle].
  final String? semanticLabel;

  String get _currentLabel => options
      .firstWhere(
        (option) => option.value == value,
        orElse: () => options.first,
      )
      .label;

  Future<void> _open(BuildContext context) async {
    final chosen = await showAppBottomSheet<String>(
      context,
      title: sheetTitle,
      child: _InlineSelectOptions(options: options, value: value),
    );
    if (chosen != null && chosen != value) onChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final label = _currentLabel;

    return AppPressable(
      semanticLabel: '${semanticLabel ?? sheetTitle ?? 'Filtro'}: $label',
      onPressed: () => _open(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space1,
          vertical: AppSpacing.space2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.md,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.accentDefault,
              ),
            ),
            const SizedBox(width: AppSpacing.space1),
            AppIcon(
              AppIcons.chevronDown,
              size: AppSize.iconSm,
              color: semantic.accentDefault,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineSelectOptions extends StatelessWidget {
  const _InlineSelectOptions({required this.options, required this.value});

  final List<AppFormSelectOption> options;
  final String value;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in options)
          AppPressable(
            semanticLabel: option.label,
            selected: option.value == value,
            onPressed: () => Navigator.of(context).pop(option.value),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              constraints: const BoxConstraints(minHeight: AppSpacing.space12),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
              ),
              decoration: BoxDecoration(
                color: option.value == value ? semantic.accentSubtle : null,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: AppTypography.xl,
                        fontWeight: option.value == value
                            ? AppTypography.weightSemibold
                            : AppTypography.weightMedium,
                        color: option.value == value
                            ? semantic.accentDefault
                            : semantic.fgDefault,
                      ),
                    ),
                  ),
                  if (option.value == value)
                    AppIcon(
                      AppIcons.check,
                      size: AppSize.iconSmPlus,
                      color: semantic.accentDefault,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

WidgetbookComponent buildInlineSelectWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'InlineSelect',
    useCases: [
      WidgetbookUseCase(
        name: 'Filtro ao lado do título',
        builder: (context) => const _InlineSelectPreview(),
      ),
    ],
  );
}

class _InlineSelectPreview extends StatefulWidget {
  const _InlineSelectPreview();

  @override
  State<_InlineSelectPreview> createState() => _InlineSelectPreviewState();
}

class _InlineSelectPreviewState extends State<_InlineSelectPreview> {
  String _value = 'todas';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Ordens de serviço',
              style: TextStyle(
                fontSize: AppTypography.xlPlus,
                fontWeight: AppTypography.weightSemibold,
              ),
            ),
          ),
          AppInlineSelect(
            sheetTitle: 'Status da OS',
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            options: const [
              AppFormSelectOption(value: 'todas', label: 'Todas'),
              AppFormSelectOption(value: 'aguardando', label: 'Aguardando'),
              AppFormSelectOption(value: 'execucao', label: 'Em execução'),
              AppFormSelectOption(value: 'finalizadas', label: 'Finalizadas'),
            ],
          ),
        ],
      ),
    );
  }
}
