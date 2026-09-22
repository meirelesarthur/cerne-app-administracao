import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/components/shortcut_grid.dart';
import 'package:cerne_app/ui/app_icon.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('ShortcutGrid', () {
    testWidgets('renderiza todos os atalhos e dispara onTap', (tester) async {
      var tapped = '';
      await tester.pumpWidget(
        _wrap(
          ShortcutGrid(
            items: [
              Shortcut(
                id: 'a',
                label: 'Financeiro',
                icon: AppIcons.wallet,
                onTap: () => tapped = 'a',
              ),
              Shortcut(
                id: 'b',
                label: 'Pecuária',
                icon: AppIcons.beef,
                onTap: () => tapped = 'b',
              ),
            ],
          ),
        ),
      );

      expect(find.text('Financeiro'), findsOneWidget);
      expect(find.text('Pecuária'), findsOneWidget);

      await tester.tap(find.text('Pecuária'));
      await tester.pump();

      expect(tapped, 'b');
      expect(tester.takeException(), isNull);
    });
  });
}
