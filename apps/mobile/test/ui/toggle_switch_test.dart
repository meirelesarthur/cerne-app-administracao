import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/toggle_switch.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppToggleSwitch', () {
    testWidgets('renderiza sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppToggleSwitch(
            checked: false,
            onChanged: (_) {},
            label: 'Notificações',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onChanged ao tocar', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _wrap(
          AppToggleSwitch(
            checked: false,
            onChanged: (v) => result = v,
            label: 'Notificações',
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(result, isTrue);
    });

    testWidgets('disabled=true ignora o toque', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppToggleSwitch(
            checked: false,
            onChanged: (_) => tapped = true,
            label: 'Notificações',
            disabled: true,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
