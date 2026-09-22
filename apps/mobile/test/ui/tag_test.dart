import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/tag.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppTag', () {
    testWidgets('renderiza o conteúdo sem exceções', (tester) async {
      await tester.pumpWidget(_wrap(const AppTag(child: Text('Safra 24/25'))));

      expect(find.text('Safra 24/25'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza dentro de gbMode sem exceções', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(AppThemeVariant.gbMode),
          home: const Scaffold(body: AppTag(child: Text('Talhão 12'))),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
