import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/tooltip.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppTooltip', () {
    testWidgets('não mostra o conteúdo antes do toque', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTooltip(
            content: 'Texto do tooltip',
            child: AppIcon(AppIcons.info),
          ),
        ),
      );

      expect(find.text('Texto do tooltip'), findsNothing);
    });

    testWidgets('mostra e esconde o conteúdo ao alternar toque', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppTooltip(
            content: 'Texto do tooltip',
            child: AppIcon(AppIcons.info),
          ),
        ),
      );

      await tester.tap(findAppIcon(AppIcons.info));
      await tester.pump();
      expect(find.text('Texto do tooltip'), findsOneWidget);

      await tester.tap(findAppIcon(AppIcons.info));
      await tester.pump();
      expect(find.text('Texto do tooltip'), findsNothing);
    });
  });
}
