import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../mocks/bank_mocks.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';

enum _Filtro { tudo, income, expense }

/// Extrato do GB Bank (New-UI): saldo compacto + filtro de direção (entradas/
/// saídas) sobre a lista de movimentações completa. Espelha `ExtratoScreen.tsx`.
class ExtratoScreen extends ConsumerStatefulWidget {
  const ExtratoScreen({super.key});

  @override
  ConsumerState<ExtratoScreen> createState() => _ExtratoScreenState();
}

class _ExtratoScreenState extends ConsumerState<ExtratoScreen> {
  _Filtro _filtro = _Filtro.tudo;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final balanceHidden = ref.watch(shellStoreProvider).balanceHidden;

    final transacoesFiltradas = transacoes.where((tx) {
      return switch (_filtro) {
        _Filtro.tudo => true,
        _Filtro.income => tx.direction == AppTransactionDirection.income,
        _Filtro.expense => tx.direction == AppTransactionDirection.expense,
      };
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(level: AppHeadingLevel.h3, child: Text('Extrato')),
        const SizedBox(height: AppSpacing.space1),
        Row(
          children: [
            Text(
              'Saldo disponível: ',
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
            Text(
              balanceHidden ? '••••••' : Saldo.valor,
              style: TextStyle(
                fontSize: AppTypography.sm,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space5),
        Row(
          children: [
            AppButton(
              variant: _filtro == _Filtro.tudo
                  ? AppButtonVariant.primary
                  : AppButtonVariant.secondary,
              size: AppButtonSize.sm,
              onPressed: () => setState(() => _filtro = _Filtro.tudo),
              child: const Text('Tudo'),
            ),
            const SizedBox(width: AppSpacing.space2),
            AppButton(
              variant: _filtro == _Filtro.income
                  ? AppButtonVariant.primary
                  : AppButtonVariant.secondary,
              size: AppButtonSize.sm,
              onPressed: () => setState(() => _filtro = _Filtro.income),
              child: const Text('Entradas'),
            ),
            const SizedBox(width: AppSpacing.space2),
            AppButton(
              variant: _filtro == _Filtro.expense
                  ? AppButtonVariant.primary
                  : AppButtonVariant.secondary,
              size: AppButtonSize.sm,
              onPressed: () => setState(() => _filtro = _Filtro.expense),
              child: const Text('Saídas'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space5),
        if (transacoesFiltradas.isEmpty)
          const AppEmptyState(
            icon: AppIcons.inbox,
            title: 'Nada por aqui',
            description: 'Não há movimentações para este filtro.',
          )
        else
          AppCard(
            padded: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              child: Column(
                children: [
                  for (final tx in transacoesFiltradas)
                    AppTransactionListItem(
                      transaction: tx,
                      onTap: () => showAppTransactionDetailSheet(
                        context,
                        transaction: tx,
                        hidden: balanceHidden,
                      ),
                      showDivider: tx != transacoesFiltradas.last,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
