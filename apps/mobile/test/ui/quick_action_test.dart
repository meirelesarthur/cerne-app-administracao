import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/quick_action.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppQuickAction', () {
    testWidgets('renderiza ícone e rótulo sem exceção', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppQuickAction(
            icon: AppIcons.wallet,
            label: 'Carteira',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Carteira'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onPressed ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppQuickAction(
            icon: AppIcons.wallet,
            label: 'Carteira',
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(AppQuickAction));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
