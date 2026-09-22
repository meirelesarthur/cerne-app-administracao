import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../mocks/bank_mocks.dart';
import '../../../shared/rise_in.dart';
import '../../../shared/simulated_load.dart';
import '../../../shell/state/prototype_session_store.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../mocks/hub_apps.dart';
import 'administrative_home_screen.dart';
import '../../../design/generated/app_layout.dart';

/// Home do hub agregador — espelha `HubHome.tsx`: Banking no centro da
/// experiência (saldo + ações rápidas + últimas movimentações) e grid de
/// mini-apps injetável via catálogo.
class HubHomeScreen extends ConsumerStatefulWidget {
  const HubHomeScreen({super.key});

  @override
  ConsumerState<HubHomeScreen> createState() => _HubHomeScreenState();
}

class _HubHomeScreenState extends ConsumerState<HubHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final shell = ref.watch(shellStoreProvider);
    final balanceHidden = shell.balanceHidden;
    final profile = ref.watch(prototypeSessionProvider).profile;
    if (profile == UserAccessProfile.administration) {
      return const AdministrativeHomeScreen();
    }
    // A pílula de crédito pré-aprovado saiu do header global (ver plano de
    // UX): permanece só como este card.
    const showCreditoDestaque = true;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        RiseIn(
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
        const SizedBox(height: AppSpacing.space6),

        // Ações rápidas do Banking.
        RiseIn(
          index: 1,
          child: Row(
            children: [
              Expanded(
                child: AppQuickAction(
                  icon: AppIcons.zap,
                  label: 'Pix',
                  onPressed: () => context.go('/bank/pagamentos'),
                ),
              ),
              Expanded(
                child: AppQuickAction(
                  icon: AppIcons.scanLine,
                  label: 'Pagar',
                  onPressed: () => context.go('/bank/pagamentos'),
                ),
              ),
              Expanded(
                child: AppQuickAction(
                  icon: AppIcons.arrowLeftRight,
                  label: 'Transferir',
                  onPressed: () => context.go('/bank/pagamentos'),
                ),
              ),
              Expanded(
                child: AppQuickAction(
                  icon: AppIcons.receipt,
                  label: 'Extrato',
                  onPressed: () => context.go('/bank/extrato'),
                ),
              ),
            ],
          ),
        ),
        if (showCreditoDestaque) ...[
          const SizedBox(height: AppSpacing.space6),

          // Destaque de crédito — deep link entre módulos.
          RiseIn(
            index: 2,
            child: AppCard(
              interactive: true,
              onTap: () => context.go('/credito'),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brand600,
                    ),
                    child: const AppIcon(
                      AppIcons.handCoins,
                      size: AppSize.iconMd,
                      color: AppColors.neutral0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Crédito Agro'),
                            SizedBox(width: AppSpacing.space2),
                            AppChip(
                              tone: AppChipTone.brand,
                              child: Text('Pré-aprovado'),
                            ),
                          ],
                        ),
                        Text(
                          CreditoPreaprovado.valor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          CreditoPreaprovado.condicao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const AppIcon(AppIcons.arrowRight, size: AppSize.iconSmPlus),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space6),

        // Grid de mini-apps — injeção contínua via catálogo.
        RiseIn(
          index: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppSectionTitle(child: Text('Seus apps')),
                  AppButton(
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.sm,
                    rightIcon: const AppIcon(
                      AppIcons.arrowRight,
                      size: AppSize.iconXs,
                    ),
                    onPressed: () => context.go('/inicio/apps'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.space3,
                crossAxisSpacing: AppSpacing.space3,
                childAspectRatio: 1.6,
                children: [
                  for (final app in hubApps)
                    AppMiniAppTile(
                      icon: app.icon,
                      name: app.name,
                      description: app.description,
                      badge: app.badge,
                      onTap: app.route != null
                          ? () => context.go(app.route!)
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        // Últimas movimentações — Banking sempre à mão.
        RiseIn(
          index: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppSectionTitle(child: Text('Últimas movimentações')),
                  AppButton(
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.sm,
                    rightIcon: const AppIcon(
                      AppIcons.arrowRight,
                      size: AppSize.iconXs,
                    ),
                    onPressed: () => context.go('/bank/extrato'),
                    child: const Text('Extrato'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              AppCard(
                padded: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                  ),
                  child: Column(
                    children: [
                      for (final tx in transacoes.take(3))
                        AppTransactionListItem(
                          transaction: tx,
                          onTap: () => showAppTransactionDetailSheet(
                            context,
                            transaction: tx,
                            hidden: balanceHidden,
                          ),
                          showDivider: tx != transacoes.take(3).last,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
