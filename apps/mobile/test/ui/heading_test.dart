import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/heading.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppHeading', () {
    testWidgets('renderiza todos os níveis sem exceção', (tester) async {
      for (final level in AppHeadingLevel.values) {
        await tester.pumpWidget(
          _wrap(AppHeading(level: level, child: const Text('Título'))),
        );
        expect(find.text('Título'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('AppSectionTitle', () {
    testWidgets('renderiza o texto sem exceção', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSectionTitle(child: Text('Quick Actions'))),
      );

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
