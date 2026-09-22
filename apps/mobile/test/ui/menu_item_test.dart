import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/menu_item.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppMenuItem', () {
    testWidgets('dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppMenuItem(
            icon: AppIcons.user,
            label: 'Perfil',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Perfil'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('sem onTap não mostra chevron e ignora toque', (tester) async {
      await tester.pumpWidget(_wrap(const AppMenuItem(label: 'Sem ação')));

      expect(findAppIcon(AppIcons.chevronRight), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza todas as combinações de tone/variant sem exceções', (
      tester,
    ) async {
      for (final tone in AppMenuItemTone.values) {
        for (final variant in AppMenuItemVariant.values) {
          await tester.pumpWidget(
            _wrap(
              AppMenuItem(
                icon: AppIcons.bell,
                label: 'Item',
                description: 'Descrição',
                tone: tone,
                variant: variant,
                active: true,
                onTap: () {},
              ),
            ),
          );
          expect(tester.takeException(), isNull);
        }
      }
    });
  });
}
