import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/transaction_list_item.dart';

import 'golden_helpers.dart';

const _income = AppTransactionItem(
  id: '1',
  title: 'Venda de soja',
  subtitle: 'Cooperativa Central',
  time: '09:14',
  value: 'R\$ 12.400,00',
  direction: AppTransactionDirection.income,
);

const _expense = AppTransactionItem(
  id: '2',
  title: 'Compra de insumos',
  time: '14:02',
  value: 'R\$ 3.180,50',
  direction: AppTransactionDirection.expense,
);

void main() {
  goldenTest(
    'AppTransactionListItem — direções e temas',
    fileName: 'app_transaction_list_item',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final variant in AppThemeVariant.values) ...[
          GoldenTestScenario(
            name: '${variant.name}_income',
            child: SizedBox(
              width: 320,
              child: themedGolden(
                variant,
                const AppTransactionListItem(transaction: _income),
              ),
            ),
          ),
          GoldenTestScenario(
            name: '${variant.name}_expense',
            child: SizedBox(
              width: 320,
              child: themedGolden(
                variant,
                const AppTransactionListItem(transaction: _expense),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
