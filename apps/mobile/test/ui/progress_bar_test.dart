import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/progress_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppProgressBar', () {
    testWidgets('renderiza o label quando showLabel é true', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppProgressBar(value: 42, showLabel: true)),
      );
      expect(find.text('42%'), findsOneWidget);
    });

    testWidgets('não estoura 100% mesmo com value > max', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppProgressBar(value: 150, showLabel: true)),
      );
      expect(find.text('150%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('colorByOccupancy renderiza sem exceções nas 3 faixas', (
      tester,
    ) async {
      for (final value in [10.0, 90.0, 120.0]) {
        await tester.pumpWidget(
          _wrap(AppProgressBar(value: value, colorByOccupancy: true)),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
