import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/app_icon_tile.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppAppIconTile', () {
    testWidgets('renderiza ícone e rótulo sem exceção', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppAppIconTile(icon: AppIcons.layoutGrid, label: 'CERNE App'),
        ),
      );

      expect(find.text('CERNE App'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppAppIconTile(
            icon: AppIcons.shieldCheck,
            label: 'CERNE ADM',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('CERNE ADM'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('showLabel=false esconde o texto mas mantém o Semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppAppIconTile(
            icon: AppIcons.phone,
            label: 'Telefone',
            showLabel: false,
          ),
        ),
      );

      expect(find.text('Telefone'), findsNothing);
      expect(find.bySemanticsLabel('Telefone'), findsOneWidget);
    });
  });
}
