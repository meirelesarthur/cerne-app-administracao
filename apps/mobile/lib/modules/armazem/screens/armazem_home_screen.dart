import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../shared/simulated_load.dart';
import '../../../ui/ui.dart';
import '../components/movimentacao_detail_sheet.dart';
import '../components/unidade_card.dart';
import '../components/unidade_detail_sheet.dart';
import 'package:cerne_app/modules/armazem/lib/movimentacoes.dart';
import '../mocks/estoque_mocks.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Home do módulo Armazém: ocupação e alertas em destaque, unidades de
/// armazenagem (cards interativos com detalhe) e últimas movimentações
/// físicas (itens interativos com detalhe) — spec D2. Espelha
/// `ArmazemHome.tsx`.
class ArmazemHomeScreen extends StatelessWidget {
  const ArmazemHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        RiseIn(
          child: SimulatedLoad(
            builder: (context, loading) {
              if (loading) {
                return const Row(
                  children: [
                    Expanded(
                      child: AppSkeleton(
                        height: 74,
                        rounded: AppSkeletonRadius.xl,
                      ),
                    ),
                    SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: AppSkeleton(
                        height: 74,
                        rounded: AppSkeletonRadius.xl,
                      ),
                    ),
                    SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: AppSkeleton(
                        height: 74,
                        rounded: AppSkeletonRadius.xl,
                      ),
                    ),
                  ],
                );
              }
              return const Row(
                children: [
                  Expanded(
                    child: AppKpiStatCard(
                      label: 'Ocupação total',
                      value: Kpis.ocupacao,
                    ),
                  ),
                  SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: AppKpiStatCard(
                      label: 'SKUs em estoque',
                      value: Kpis.skus,
                    ),
                  ),
                  SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: AppKpiStatCard(
                      label: 'Alertas',
                      value: Kpis.alertas,
                      tone: AppKpiStatTone.warning,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        RiseIn(
          index: 1,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      height: AppSpacing.space8,
                      width: AppSpacing.space8,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amber50,
                      ),
                      child: const AppIcon(
                        AppIcons.triangleAlert,
                        size: AppSize.iconSm,
                        color: AppColors.amber600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    const AppHeading(
                      level: AppHeadingLevel.h4,
                      child: Text('Alertas'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                for (final alerta in alertas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                alerta.titulo,
                                style: TextStyle(
                                  fontWeight: AppTypography.weightSemibold,
                                  color: semantic.fgDefault,
                                ),
                              ),
                              Text(
                                alerta.detalhe,
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  color: semantic.fgMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const AppChip(
                          tone: AppChipTone.amber,
                          child: Text('Ação sugerida'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        RiseIn(
          index: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(child: Text('Unidades de armazenagem')),
              const SizedBox(height: AppSpacing.space2),
              for (final unidade in unidades)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                  child: UnidadeCard(
                    unidade: unidade,
                    onTap: () =>
                        showUnidadeDetailSheet(context, unidade: unidade),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        RiseIn(
          index: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(child: Text('Movimentações recentes')),
              const SizedBox(height: AppSpacing.space2),
              AppCard(
                padded: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                  ),
                  child: Column(
                    children: [
                      for (final mov in movimentacoes)
                        AppTransactionListItem(
                          transaction: toTransactionItem(mov),
                          onTap: () => showMovimentacaoDetailSheet(
                            context,
                            movimentacao: mov,
                          ),
                          showDivider: mov != movimentacoes.last,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        RiseIn(
          index: 4,
          child: AppCard(
            interactive: true,
            onTap: () => context.go('/marketplace'),
            child: Row(
              children: [
                Container(
                  height: AppSpacing.space10 + AppSpacing.space1,
                  width: AppSpacing.space10 + AppSpacing.space1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: semantic.accentDefault,
                  ),
                  child: const AppIcon(
                    AppIcons.shoppingBag,
                    size: AppSize.iconMd,
                    color: AppColors.neutral0,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reponha insumos no Marketplace',
                        style: TextStyle(
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      Text(
                        'Compre direto dos fornecedores parceiros',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: semantic.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIcon(
                  AppIcons.arrowRight,
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
