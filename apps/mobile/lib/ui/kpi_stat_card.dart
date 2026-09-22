import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

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
  });

  final String label;
  final String value;
  final String? caption;
  final AppKpiStatTone tone;

  Color _valueColor(AppSemanticColors s) => switch (tone) {
    AppKpiStatTone.neutral => s.fgDefault,
    AppKpiStatTone.positive => AppColors.feedbackSuccessText,
    AppKpiStatTone.negative => AppColors.feedbackErrorText,
    AppKpiStatTone.warning => AppColors.feedbackWarningText,
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
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.md,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTypography.xlPlus,
              fontWeight: AppTypography.weightSemibold,
              height: AppTypography.lineHeightTight,
              color: _valueColor(semantic),
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
                  label: 'Receita do mês',
                  value: 'R\$ 42.300',
                  caption: '+8% vs. mês anterior',
                ),
              ),
              SizedBox(
                width: 160,
                child: AppKpiStatCard(
                  label: 'Saldo em caixa',
                  value: 'R\$ 128.450',
                  tone: AppKpiStatTone.positive,
                  caption: 'Disponível',
                ),
              ),
              SizedBox(
                width: 160,
                child: AppKpiStatCard(
                  label: 'Despesas',
                  value: 'R\$ 9.870',
                  tone: AppKpiStatTone.negative,
                ),
              ),
              SizedBox(
                width: 160,
                child: AppKpiStatCard(
                  label: 'Vencimentos',
                  value: '3',
                  tone: AppKpiStatTone.warning,
                  caption: 'Próximos 7 dias',
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
