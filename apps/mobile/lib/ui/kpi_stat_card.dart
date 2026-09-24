import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

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
