import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/page_dots.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppPageDots', () {
    testWidgets('renderiza a quantidade correta de dots', (tester) async {
      await tester.pumpWidget(_wrap(const AppPageDots(count: 4, active: 0)));

      expect(
        find.bySemanticsLabel(RegExp(r'^Página \d de 4$')),
        findsNWidgets(4),
      );
    });

    testWidgets('dispara onSelect com o índice tocado', (tester) async {
      int? selected;
      await tester.pumpWidget(
        _wrap(AppPageDots(count: 3, active: 0, onSelect: (i) => selected = i)),
      );

      await tester.tap(find.bySemanticsLabel('Página 2 de 3'));
      await tester.pump();

      expect(selected, 1);
    });

    testWidgets('sem onSelect não dispara toque e não quebra', (tester) async {
      await tester.pumpWidget(_wrap(const AppPageDots(count: 3, active: 1)));

      await tester.tap(
        find.bySemanticsLabel('Página 1 de 3'),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
