import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/checkbox.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppCheckbox', () {
    testWidgets('renderiza o label sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppCheckbox(
            checked: false,
            onChanged: (_) {},
            label: 'Aceito os termos',
          ),
        ),
      );

      expect(find.text('Aceito os termos'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onChanged com o valor invertido ao tocar', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        _wrap(
          AppCheckbox(
            checked: false,
            onChanged: (v) => result = v,
            label: 'Marcar',
          ),
        ),
      );

      await tester.tap(find.text('Marcar'));
      await tester.pump();

      expect(result, isTrue);
    });
  });
}
