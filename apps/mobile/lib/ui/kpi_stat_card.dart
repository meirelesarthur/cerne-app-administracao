import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/generated/app_layout.dart';
import '../design/theme/app_theme_extension.dart';
import 'app_icon.dart';
import 'help_button.dart';

/// Espelha `KpiStatCard.tsx` — card-resumo compacto para as linhas de KPIs do
/// topo dos dashboards.
///
/// Anatomia do padrão global (Figma `54347:967`): superfície elevada com raio
/// [AppRadius.tile] (20), `px 12 / py 16` e sombra `AppShadows.tile`; rótulo de
/// 14 px SemiBold escuro no topo, valor em 18 px SemiBold e legenda de 12 px
/// abafada na base — a leitura é do rótulo para o número, não o contrário.
///
/// O tom `'default'` do React (palavra reservada em Dart) foi portado como
/// [AppKpiStatTone.neutral].
enum AppKpiStatTone { neutral, positive, negative, warning }

class AppKpiStatCard extends StatelessWidget {
  const AppKpiStatCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.tone = AppKpiStatTone.neutral,
    this.help,
  });

  final String label;
  final String value;
  final String? caption;
  final AppKpiStatTone tone;

  /// Definição da métrica, aberta pelo [AppHelpButton] ao lado do rótulo —
  /// para siglas e cálculos que o gestor não precisa decorar.
  final String? help;

  /// O tom nunca é só cor (WCAG 1.4.1): positivo, atenção e negativo ganham
  /// um ícone ao lado do valor e uma palavra para leitores de tela.
  (AppIconData, String)? get _status => switch (tone) {
    AppKpiStatTone.neutral => null,
    AppKpiStatTone.positive => (AppIcons.checkCircle2, 'bom'),
    AppKpiStatTone.warning => (AppIcons.triangleAlert, 'atenção'),
    AppKpiStatTone.negative => (AppIcons.circleAlert, 'crítico'),
  };

  Color _valueColor(AppSemanticColors s) => switch (tone) {
    AppKpiStatTone.neutral => s.fgDefault,
    AppKpiStatTone.positive => s.toneBrandFg,
    AppKpiStatTone.negative => s.toneRedFg,
    AppKpiStatTone.warning => s.toneAmberFg,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: semantic.bgRaised,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        boxShadow: AppShadows.tile,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ),
              if (help case final texto?) ...[
                const SizedBox(width: AppSpacing.half),
                SizedBox.square(
                  dimension: AppSize.iconSm,
                  child: OverflowBox(
                    maxWidth: AppSize.control,
                    maxHeight: AppSize.control,
                    child: AppHelpButton(title: label, text: texto),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          Semantics(
            label: _status == null ? null : '$value, ${_status!.$2}',
            excludeSemantics: _status != null,
            child: Row(
              children: [
                if (_status case (final icone, _)) ...[
                  AppIcon(
                    icone,
                    size: AppSize.iconSm,
                    color: _valueColor(semantic),
                  ),
                  const SizedBox(width: AppSpacing.space1),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: AppTypography.xlPlus,
                      fontWeight: AppTypography.weightSemibold,
                      height: AppTypography.lineHeightTight,
                      color: _valueColor(semantic),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.half),
            Text(
              caption!,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

WidgetbookComponent buildKpiStatCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'KpiStatCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Tons',
        builder: (context) => const Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 160,
                child: AppKpiStatCard(
                  label: 'Animais no cocho',
                  value: '1.240',
                  caption: '+3% vs. semana anterior',
                ),
              ),
              SizedBox(
                width: 160,
                child: AppKpiStatCard(
                  label: 'GMD médio',
                  value: '1,42 kg',
                  tone: AppKpiStatTone.positive,
                  caption: 'Acima da meta',
                  help: 'Ganho médio diário por cabeça, em kg.',
                ),
              ),
              SizedBox(
                width: 160,
                child: AppKpiStatCard(
                  label: 'Sobra de cocho',
                  value: '6,8%',
                  tone: AppKpiStatTone.negative,
                ),
              ),
              SizedBox(
                width: 160,
                child: AppKpiStatCard(
                  label: 'OS atrasadas',
                  value: '3',
                  tone: AppKpiStatTone.warning,
                  caption: 'Prazo vencido',
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
