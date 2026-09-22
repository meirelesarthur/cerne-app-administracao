import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/generated/app_layout.dart';
import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/stepper.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppStepper', () {
    testWidgets('renderiza o valor e o sufixo sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(AppStepper(value: 3, onChanged: (_) {}, suffix: 'sc')),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('sc'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppStepper)).height,
        AppSize.controlLg,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('botão + dispara onChanged incrementado', (tester) async {
      num? result;
      await tester.pumpWidget(
        _wrap(AppStepper(value: 3, onChanged: (v) => result = v)),
      );

      await tester.tap(find.bySemanticsLabel('Aumentar'));
      await tester.pump();

      expect(result, 4);
    });

    testWidgets('botão - respeita o mínimo (fica desabilitado)', (
      tester,
    ) async {
      num? result;
      await tester.pumpWidget(
        _wrap(AppStepper(value: 0, onChanged: (v) => result = v)),
      );

      await tester.tap(find.bySemanticsLabel('Diminuir'));
      await tester.pump();

      expect(result, isNull);
    });
  });
}
