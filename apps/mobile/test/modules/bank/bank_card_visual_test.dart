import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/components/bank_card_visual.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('BankCardVisual', () {
    testWidgets('renderiza dados do cartão mock sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const BankCardVisual()));

      expect(find.text('GB Corp · Crédito'), findsOneWidget);
      expect(find.text('ARTHUR M'), findsOneWidget);
      expect(find.text('Mastercard'), findsOneWidget);
      expect(find.textContaining('4821'), findsWidgets);
      expect(find.text('08/29'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('showNumber=false oculta o número mascarado', (tester) async {
      await tester.pumpWidget(_wrap(const BankCardVisual(showNumber: false)));

      expect(find.textContaining('•••• ••••'), findsNothing);
      expect(find.text('Final 4821'), findsOneWidget);
    });
  });
}
