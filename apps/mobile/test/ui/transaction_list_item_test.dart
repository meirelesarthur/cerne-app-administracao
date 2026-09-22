import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/transaction_list_item.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppTransactionListItem', () {
    const income = AppTransactionItem(
      id: '1',
      title: 'Venda de soja',
      subtitle: 'Cooperativa Central',
      time: '09:12',
      value: 'R\$ 12.400,00',
      direction: AppTransactionDirection.income,
    );

    const expense = AppTransactionItem(
      id: '2',
      title: 'Compra de insumos',
      time: 'Ontem',
      value: 'R\$ 3.850,00',
      direction: AppTransactionDirection.expense,
    );

    testWidgets('renderiza título, valor com sinal e horário', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppTransactionListItem(transaction: income)),
      );

      expect(find.text('Venda de soja'), findsOneWidget);
      expect(find.text('Cooperativa Central'), findsOneWidget);
      expect(find.text('+ R\$ 12.400,00'), findsOneWidget);
      expect(find.text('09:12'), findsOneWidget);
    });

    testWidgets('saída usa sinal negativo e não quebra sem subtítulo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppTransactionListItem(transaction: expense)),
      );

      expect(find.text('− R\$ 3.850,00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppTransactionListItem(
            transaction: income,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Venda de soja'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
