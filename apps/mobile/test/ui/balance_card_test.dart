import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/balance_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppBalanceCard', () {
    testWidgets('renderiza valor e rótulos sem exceção', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppBalanceCard(
            value: 'R\$ 128.450,32',
            accountLabel: 'Conta GB Bank · Ag 0001',
          ),
        ),
      );

      expect(find.text('R\$ 128.450,32'), findsOneWidget);
      expect(find.text('Saldo disponível'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hidden=true oculta o valor', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppBalanceCard(value: 'R\$ 128.450,32', hidden: true)),
      );

      expect(find.text('R\$ 128.450,32'), findsNothing);
      expect(find.text('••••••'), findsOneWidget);
    });

    testWidgets('onToggleHidden dispara ao tocar no botão de olho', (
      tester,
    ) async {
      var toggled = false;
      await tester.pumpWidget(
        _wrap(
          AppBalanceCard(
            value: 'R\$ 1,00',
            onToggleHidden: () => toggled = true,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('loading=true mostra skeleton em vez do valor', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppBalanceCard(value: 'R\$ 1,00', loading: true)),
      );

      expect(find.text('R\$ 1,00'), findsNothing);
    });
  });

  group('AppBalanceSummaryItem', () {
    testWidgets('renderiza label e valor sem exceção', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppBalanceSummaryItem(label: 'Entradas', value: 'R\$ 100,00'),
        ),
      );

      expect(find.text('Entradas'), findsOneWidget);
      expect(find.text('R\$ 100,00'), findsOneWidget);
    });
  });
}
