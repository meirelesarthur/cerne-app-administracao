import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../mocks/bank_mocks.dart';
import '../../../shared/rise_in.dart';
import '../../../shared/simulated_load.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../../../design/generated/app_layout.dart';

/// Carteira do hub — espelha `CarteiraScreen.tsx`: visão condensada do Banking
/// sem sair do Início. A experiência completa vive no módulo GB Bank.
class CarteiraScreen extends ConsumerWidget {
  const CarteiraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final shell = ref.watch(shellStoreProvider);
    final balanceHidden = shell.balanceHidden;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        RiseIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeading(
                level: AppHeadingLevel.h3,
                child: Text('Carteira'),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'Resumo da sua conta GB Bank.',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        RiseIn(
          index: 1,
          child: SimulatedLoad(
            builder: (context, loading) => AppBalanceCard(
              value: Saldo.valor,
              accountLabel: Saldo.conta,
              hidden: balanceHidden,
              onToggleHidden: () =>
                  ref.read(shellStoreProvider.notifier).toggleBalanceHidden(),
              loading: loading,
              footer: Row(
                children: [
                  Expanded(
                    child: AppBalanceSummaryItem(
                      icon: const AppIcon(
                        AppIcons.arrowDownLeft,
                        size: AppSize.iconXs,
                      ),
                      label: 'Entradas no mês',
                      value: ResumoMes.entradas,
                      hidden: balanceHidden,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: AppBalanceSummaryItem(
                      icon: const AppIcon(
                        AppIcons.arrowUpRight,
                        size: AppSize.iconXs,
                      ),
                      label: 'Saídas no mês',
                      value: ResumoMes.saidas,
                      hidden: balanceHidden,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        RiseIn(
          index: 2,
          child: Row(
            children: [
              Expanded(
                child: AppKpiStatCard(
                  label: 'Entradas no mês',
                  value: balanceHidden ? '••••' : ResumoMes.entradas,
                  tone: AppKpiStatTone.positive,
                  caption: '+12% vs. mês anterior',
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: AppKpiStatCard(
                  label: 'Saídas no mês',
                  value: balanceHidden ? '••••' : ResumoMes.saidas,
                  caption: 'folha, insumos e energia',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
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
                      for (final tx in transacoes)
                        AppTransactionListItem(
                          transaction: tx,
                          onTap: () => showAppTransactionDetailSheet(
                            context,
                            transaction: tx,
                            hidden: balanceHidden,
                          ),
                          showDivider: tx != transacoes.last,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        RiseIn(
          index: 4,
          child: AppButton(
            fullWidth: true,
            size: AppButtonSize.lg,
            leftIcon: const AppIcon(
              AppIcons.landmark,
              size: AppSize.iconSmPlus,
            ),
            onPressed: () => context.go('/bank'),
            child: const Text('Abrir GB Bank completo'),
          ),
        ),
      ],
    );
  }
}
