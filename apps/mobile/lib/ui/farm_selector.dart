import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Seletor de fazenda do cabeçalho global (Figma `54300-2458`).
///
/// É o **único bloco que as duas homes compartilham** — ver §4 da esteira do
/// padrão global: ADM e Operação não dividem conteúdo, dividem contexto. Toda
/// tela do app responde "de qual fazenda estamos falando", e é esta faixa que
/// responde.
///
/// Anatomia do Figma: ícone de 20 px no acento da marca, nome em 16 px na
/// mesma cor, caret de 20 px à direita da linha inteira.
class AppFarmSelector extends StatelessWidget {
  const AppFarmSelector({super.key, required this.farmName, this.onTap});

  /// Nome da fazenda em contexto.
  final String farmName;

  /// Abre a troca de fazenda. Nulo deixa a faixa como leitura de contexto —
  /// sem caret e sem alvo de toque.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final row = Row(
      children: [
        AppIcon(
          AppIcons.fazenda,
          size: AppSize.iconMd,
          color: semantic.accentDefault,
        ),
        const SizedBox(width: AppSpacing.space2),
        Expanded(
          child: Text(
            farmName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppTypography.xl,
              color: semantic.accentDefault,
            ),
          ),
        ),
        if (onTap != null)
          AppIcon(
            AppIcons.chevronDown,
            size: AppSize.iconMd,
            color: semantic.accentDefault,
          ),
      ],
    );

    if (onTap == null) {
      return Semantics(label: 'Fazenda $farmName', child: row);
    }

    return AppPressable(
      semanticLabel: 'Fazenda $farmName. Trocar de fazenda',
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
        child: row,
      ),
    );
  }
}

WidgetbookComponent buildFarmSelectorWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'FarmSelector',
    useCases: [
      WidgetbookUseCase(
        name: 'Com troca de fazenda',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppFarmSelector(
            farmName: 'Fazenda Agro Pillatti',
            onTap: () {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Somente leitura de contexto',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppFarmSelector(farmName: 'Fazenda Santa Helena'),
        ),
      ),
      WidgetbookUseCase(
        name: 'Nome longo',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppFarmSelector(
            farmName: 'Fazenda Nossa Senhora Aparecida do Vale Verde',
            onTap: () {},
          ),
        ),
      ),
    ],
  );
}
