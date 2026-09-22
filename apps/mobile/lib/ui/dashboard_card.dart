import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'sparkline_area.dart';
import '../design/generated/app_layout.dart';

/// Espelha `DashboardCard.tsx` — bloco de KPI dos dashboards de fazendas.
/// `variant` cobre o claro padrão (`light`) e as superfícies escuras
/// categorizadas de `t.component.dashboardTile` (spec §6.6), representadas em
/// Dart por `AppComponentColors` (`app_colors.dart`).
enum AppDashboardCardVariant {
  light,
  revenue,
  expense,
  finance,
  production,
  dark,
}

class AppDashboardCard extends StatelessWidget {
  const AppDashboardCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.delta,
    this.spark,
    this.variant = AppDashboardCardVariant.light,
    this.disabled = false,
    this.disabledLabel = 'Indisponível no momento',
    this.onTap,
  });

  final AppIconData icon;
  final String label;
  final String value;

  /// Variação percentual; positivo = verde, negativo = vermelho.
  final double? delta;
  final List<double>? spark;

  /// Claro (padrão do print) ou escuro categorizado (spec §6.6).
  final AppDashboardCardVariant variant;

  /// Estado desativado (ex.: bloco produtivo/reprodutivo, spec §4.1).
  final bool disabled;
  final String disabledLabel;
  final VoidCallback? onTap;

  bool get _dark => variant != AppDashboardCardVariant.light;

  Color? get _tileBg => switch (variant) {
    AppDashboardCardVariant.light => null,
    AppDashboardCardVariant.revenue => AppComponentColors.dashboardTileRevenue,
    AppDashboardCardVariant.expense => AppComponentColors.dashboardTileExpense,
    AppDashboardCardVariant.finance => AppComponentColors.dashboardTileFinance,
    AppDashboardCardVariant.production =>
      AppComponentColors.dashboardTileProduction,
    AppDashboardCardVariant.dark => AppComponentColors.dashboardTileDark,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    if (disabled) {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: BoxDecoration(
              color: semantic.bgSubtle,
              borderRadius: BorderRadius.circular(AppRadius.xl2),
              border: Border.all(color: semantic.borderDefault),
            ),
            child: Opacity(
              opacity: 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSpacing.space10,
                    height: AppSpacing.space10,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: AppIcon(
                      icon,
                      size: AppSize.iconSmPlus,
                      color: AppColors.neutral500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space3),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: AppTypography.md,
                        fontWeight: AppTypography.weightMedium,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space1),
                    child: Text(
                      '—',
                      style: TextStyle(
                        fontSize: AppTypography.xl2,
                        fontWeight: AppTypography.weightBold,
                        color: semantic.fgSubtle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.space3,
            top: AppSpacing.space3,
            child: AppIcon(
              AppIcons.lock,
              size: AppSize.iconXs,
              color: semantic.fgSubtle,
            ),
          ),
          Positioned(
            left: AppSpacing.space4,
            right: AppSpacing.space4,
            bottom: AppSpacing.space2,
            child: Text(
              disabledLabel,
              style: TextStyle(
                fontSize: AppTypography.xs,
                fontWeight: AppTypography.weightMedium,
                color: semantic.fgSubtle,
              ),
            ),
          ),
        ],
      );
    }

    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: _dark ? _tileBg : semantic.bgKpi,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: _dark ? null : Border.all(color: semantic.borderTint),
        boxShadow: semantic.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.space10,
                height: AppSpacing.space10,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  color: _dark
                      ? AppColors.neutral0.withValues(alpha: 0.15)
                      : semantic.accentSubtle,
                  border: _dark ? null : Border.all(color: semantic.borderTint),
                ),
                child: AppIcon(
                  icon,
                  size: AppSize.iconSmPlus,
                  color: _dark ? AppColors.neutral0 : semantic.accentDefault,
                ),
              ),
              if (delta != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      delta! >= 0 ? AppIcons.trendingUp : AppIcons.trendingDown,
                      size: AppSize.iconXs,
                      color: _dark
                          ? AppColors.neutral0.withValues(alpha: 0.9)
                          : (delta! >= 0
                                ? semantic.accentDefault
                                : AppColors.red600),
                    ),
                    const SizedBox(width: AppSpacing.half),
                    Text(
                      '${delta! >= 0 ? '+' : ''}${delta!.toStringAsFixed(delta! % 1 == 0 ? 0 : 1)}%',
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        fontWeight: AppTypography.weightSemibold,
                        color: _dark
                            ? AppColors.neutral0.withValues(alpha: 0.9)
                            : (delta! >= 0
                                  ? semantic.accentDefault
                                  : AppColors.red600),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space3),
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.md,
                fontWeight: AppTypography.weightMedium,
                color: _dark
                    ? AppColors.neutral0.withValues(alpha: 0.75)
                    : semantic.fgMuted,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space1),
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.xl2,
                fontWeight: AppTypography.weightBold,
                height: AppTypography.lineHeightTight,
                color: _dark ? AppColors.neutral0 : semantic.fgDefault,
              ),
            ),
          ),
          if (spark != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space2),
              child: LayoutBuilder(
                builder: (context, constraints) => AppSparklineArea(
                  data: spark!,
                  color: _dark
                      ? AppColors.neutral0.withValues(alpha: 0.9)
                      : semantic.accentDefault,
                  width: constraints.maxWidth,
                  height: 34,
                ),
              ),
            ),
        ],
      ),
    );

    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        child: content,
      ),
    );
  }
}

WidgetbookComponent buildDashboardCardWidgetbookComponent() {
  const sample = [12.0, 18.0, 15.0, 24.0, 20.0, 30.0, 26.0, 34.0];

  return WidgetbookComponent(
    name: 'DashboardCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Claro',
        builder: (context) => Center(
          child: SizedBox(
            width: 200,
            child: AppDashboardCard(
              icon: AppIcons.wallet,
              label: 'Receita do mês',
              value: 'R\$ 24.500',
              delta: 8.4,
              spark: sample,
              onTap: () {},
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Categorias escuras',
        builder: (context) => Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: AppDashboardCard(
                  icon: AppIcons.trendingUp,
                  label: 'Receitas',
                  value: 'R\$ 24.500',
                  delta: 8.4,
                  variant: AppDashboardCardVariant.revenue,
                  onTap: () {},
                ),
              ),
              SizedBox(
                width: 200,
                child: AppDashboardCard(
                  icon: AppIcons.trendingDown,
                  label: 'Despesas',
                  value: 'R\$ 9.200',
                  delta: -3.1,
                  variant: AppDashboardCardVariant.expense,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Desativado',
        builder: (context) => const Center(
          child: SizedBox(
            width: 200,
            child: AppDashboardCard(
              icon: AppIcons.egg,
              label: 'Reprodutivo',
              value: '0',
              disabled: true,
            ),
          ),
        ),
      ),
    ],
  );
}
