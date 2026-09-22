import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/shell/components/credito_pill.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppCreditoPill', () {
    testWidgets('renderiza o valor mock sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const AppCreditoPill()));

      expect(find.text('R\$ 480.000,00'), findsOneWidget);
      expect(find.text('crédito pré aprovado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppCreditoPill(onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(AppCreditoPill));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('sem onTap ignora o toque', (tester) async {
      await tester.pumpWidget(_wrap(const AppCreditoPill()));

      await tester.tap(find.byType(AppCreditoPill), warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
