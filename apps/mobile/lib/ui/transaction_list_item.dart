import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'package:cerne_app/design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';

/// Direção do lançamento — espelha `'in' | 'out'` de `TransactionItem` (React).
enum AppTransactionDirection { income, expense }

/// Espelha `TransactionItem` (interface) de `TransactionListItem.tsx`.
///
/// Modelo de dados público — também consumido por `TransactionDetailSheet`
/// (`transaction_detail_sheet.dart`).
class AppTransactionItem {
  const AppTransactionItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.time,
    required this.value,
    required this.direction,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String time;

  /// Valor formatado sem sinal (ex.: "R$ 12.400,00") — o sinal (+/−) é
  /// derivado de [direction] na renderização.
  final String value;

  final AppTransactionDirection direction;
}

/// Linha de extrato do Banking (New-UI): direção com ícone + cor (nunca cor
/// sozinha), valores tabulares para alinhamento perfeito de colunas numéricas.
class AppTransactionListItem extends StatelessWidget {
  const AppTransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    // O React usa `:last-child` no pai para omitir a borda inferior do
    // último item; em Flutter isso é responsabilidade explícita de quem
    // monta a lista (ex.: `ListView.separated`), daí este flag.
    this.showDivider = true,
  });

  final AppTransactionItem transaction;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final isIn = transaction.direction == AppTransactionDirection.income;

    final content = Row(
      children: [
        Container(
          width: AppSpacing.space10,
          height: AppSpacing.space10,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            color: isIn ? semantic.accentSubtle : semantic.bgSubtle,
          ),
          child: AppIcon(
            isIn ? AppIcons.arrowDownLeft : AppIcons.arrowUpRight,
            size: AppSize.iconSmPlus,
            color: isIn ? semantic.accentDefault : semantic.fgMuted,
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                transaction.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              if (transaction.subtitle != null)
                Text(
                  transaction.subtitle!,
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
        const SizedBox(width: AppSpacing.space3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIn ? '+' : '−'} ${transaction.value}',
              style: TextStyle(
                fontSize: AppTypography.md,
                fontWeight: AppTypography.weightBold,
                color: isIn ? semantic.accentDefault : semantic.fgDefault,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              transaction.time,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgSubtle,
              ),
            ),
          ],
        ),
      ],
    );

    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: semantic.borderDefault)),
            )
          : null,
      child: content,
    );

    if (onTap == null) return row;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: row,
      ),
    );
  }
}

WidgetbookComponent buildTransactionListItemWidgetbookComponent() {
  final sample = const AppTransactionItem(
    id: '1',
    title: 'Venda de soja — lote 42',
    subtitle: 'Cooperativa Central',
    time: '09:12',
    value: 'R\$ 12.400,00',
    direction: AppTransactionDirection.income,
  );
  final sampleOut = const AppTransactionItem(
    id: '2',
    title: 'Compra de insumos',
    subtitle: 'Agropecuária Vale Verde',
    time: 'Ontem',
    value: 'R\$ 3.850,00',
    direction: AppTransactionDirection.expense,
  );

  return WidgetbookComponent(
    name: 'TransactionListItem',
    useCases: [
      WidgetbookUseCase(
        name: 'Entrada e saída',
        builder: (context) => Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTransactionListItem(transaction: sample, onTap: () {}),
                AppTransactionListItem(
                  transaction: sampleOut,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
