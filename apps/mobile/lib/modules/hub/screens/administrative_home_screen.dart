import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../mocks/bank_mocks.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';

/// Home do CERNE ADM: uma visão de Banking conectada à rotina da fazenda.
///
/// Os parceiros e a central de segurança são dados demonstrativos — não
/// criam uma segunda camada de navegação nem simulam uma integração financeira
/// real. Os cards só dão forma ao próximo passo do produto.
class AdministrativeHomeScreen extends ConsumerWidget {
  const AdministrativeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final balanceHidden = ref.watch(shellStoreProvider).balanceHidden;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        AppBalanceCard(
          label: 'Conta corrente',
          title: 'Conta GB Banking',
          accountLabel: 'Conta 48213-7 · Ag. 0001',
          value: Saldo.valor,
          hidden: balanceHidden,
          onToggleHidden: () =>
              ref.read(shellStoreProvider.notifier).toggleBalanceHidden(),
          note: 'R\$ 128.450,32 pré-aprovado',
          noteIcon: AppIcons.creditCardAccept,
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
        const SizedBox(height: AppSpacing.space6),
        const _AdminSectionHeader(title: 'Acesso rápido'),
        const SizedBox(height: AppSpacing.space3),
        const _DiscoveryRail(items: _adminQuickAccess),
        const SizedBox(height: AppSpacing.space6),
        const _AdminSectionHeader(title: 'Parceiros de crédito'),
        const SizedBox(height: AppSpacing.space3),
        for (var i = 0; i < _creditPartners.length; i++) ...[
          _CreditPartnerCard(partner: _creditPartners[i]),
          if (i != _creditPartners.length - 1)
            const SizedBox(height: AppSpacing.space2),
        ],
        const SizedBox(height: AppSpacing.space6),
        const _AdminSectionHeader(title: 'Central de Segurança'),
        const SizedBox(height: AppSpacing.space3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SecurityCard(
                title: 'Evolua seu crédito',
                onTap: () => context.go('/credito'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '2',
                        style: TextStyle(
                          fontSize: AppTypography.xl3,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                        children: [
                          TextSpan(
                            text: ' / 4',
                            style: TextStyle(
                              fontSize: AppTypography.md,
                              fontWeight: AppTypography.weightNormal,
                              color: semantic.fgMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    const _SecurityProgress(completed: 2, total: 4),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'Próximo: Comprovar renda',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _SecurityCard(
                title: 'Meus limites',
                onTap: () => context.go('/bank/limites'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'Gestão de limites diários',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: semantic.fgMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    AppIcon(
                      AppIcons.slidersHorizontal,
                      size: AppSize.iconXl,
                      color: semantic.fgMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
      ],
    );
  }
}

class _AdminSectionHeader extends StatelessWidget {
  const _AdminSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      header: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppHeading(child: Text(title)),
          AppIcon(
            AppIcons.chevronRight,
            size: AppSize.iconLg,
            color: semantic.fgDefault,
          ),
        ],
      ),
    );
  }
}

class _DiscoveryRail extends StatelessWidget {
  const _DiscoveryRail({required this.items});

  final List<_DiscoveryItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.space2),
        itemBuilder: (context, index) {
          final item = items[index];
          return AppDiscoveryTile(
            icon: item.icon,
            label: item.label,
            onTap: () => context.go(item.route),
          );
        },
      ),
    );
  }
}

class _CreditPartnerCard extends StatelessWidget {
  const _CreditPartnerCard({required this.partner});

  final _CreditPartner partner;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: partner.name,
      onPressed: () => context.go('/credito'),
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: Container(
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: semantic.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.space12,
              height: AppSpacing.space12,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: semantic.bgSurface,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                AppIcons.handCoins,
                size: AppSize.iconLg,
                color: semantic.accentDefault,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    partner.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.xl,
                      color: semantic.fgMuted,
                    ),
                  ),
                  Text(
                    partner.amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.xl,
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.accentDefault,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTag(
                  tone: partner.tone,
                  icon: partner.statusIcon,
                  child: Text(partner.status),
                ),
                const SizedBox(height: AppSpacing.half),
                Text(
                  partner.rate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: semantic.fgMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.title,
    required this.child,
    required this.onTap,
  });

  final String title;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: title,
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: semantic.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.xl,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            const Spacer(),
            child,
          ],
        ),
      ),
    );
  }
}

class _SecurityProgress extends StatelessWidget {
  const _SecurityProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: AppSpacing.space1,
              decoration: BoxDecoration(
                color: i < completed
                    ? semantic.accentDefault
                    : semantic.borderTint,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: AppSpacing.half),
        ],
      ],
    );
  }
}

class _DiscoveryItem {
  const _DiscoveryItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final AppIconData icon;
  final String route;
}

class _CreditPartner {
  const _CreditPartner({
    required this.name,
    required this.amount,
    required this.status,
    required this.rate,
    required this.tone,
    this.statusIcon,
  });

  final String name;
  final String amount;
  final String status;
  final String rate;
  final AppTagTone tone;
  final AppIconData? statusIcon;
}

const _adminQuickAccess = [
  _DiscoveryItem(
    label: 'Open Finance',
    icon: AppIcons.openFinance,
    route: '/bank',
  ),
  _DiscoveryItem(
    label: 'Fazendas',
    icon: AppIcons.sprout,
    route: '/fazendas',
  ),
  _DiscoveryItem(
    label: 'Gestão de Estoque',
    icon: AppIcons.boxes,
    route: '/armazem/estoque',
  ),
  _DiscoveryItem(
    label: 'Marketplace',
    icon: AppIcons.store,
    route: '/marketplace',
  ),
];

const _creditPartners = [
  _CreditPartner(
    name: 'Casa do adubo',
    amount: 'R\$ 720.000,00',
    status: 'Pré-aprovado',
    rate: 'a partir de 1,05% a.m.',
    tone: AppTagTone.success,
  ),
  _CreditPartner(
    name: 'Venagro',
    amount: 'R\$ 720.000,00',
    status: 'Em análise',
    rate: 'a partir de 1,05% a.m.',
    tone: AppTagTone.warning,
  ),
  _CreditPartner(
    name: 'NPK',
    amount: 'R\$ 720.000,00',
    status: 'Aprovado',
    rate: 'a partir de 1,05% a.m.',
    tone: AppTagTone.success,
    statusIcon: AppIcons.partyPopper,
  ),
];
