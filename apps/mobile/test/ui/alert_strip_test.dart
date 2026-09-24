import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/alert_strip.dart';
import 'package:cerne_app/ui/app_icon.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

const _items = [
  AppAlertItem(label: 'primeiro', value: '1', icon: AppIcons.circleAlert),
  AppAlertItem(label: 'segundo', value: '2', icon: AppIcons.circleAlert),
  AppAlertItem(label: 'terceiro', value: '3', icon: AppIcons.circleAlert),
];

void main() {
  group('AppAlertStrip', () {
    testWidgets('sem maxItems mostra todos os alertas', (tester) async {
      await tester.pumpWidget(_wrap(const AppAlertStrip(items: _items)));

      expect(find.text('primeiro'), findsOneWidget);
      expect(find.text('terceiro'), findsOneWidget);
    });

    testWidgets('maxItems mostra só os primeiros, na ordem recebida', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppAlertStrip(items: _items, maxItems: 2)),
      );

      expect(find.text('primeiro'), findsOneWidget);
      expect(find.text('segundo'), findsOneWidget);
      expect(find.text('terceiro'), findsNothing);
    });
  });
}
