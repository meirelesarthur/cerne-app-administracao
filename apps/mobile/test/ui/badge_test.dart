import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/badge.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppBadge', () {
    testWidgets('renderiza o conteúdo sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const AppBadge(child: Text('3'))));

      expect(find.text('3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza todos os tons sem exceção', (tester) async {
      for (final tone in AppBadgeTone.values) {
        await tester.pumpWidget(
          _wrap(AppBadge(tone: tone, child: const Text('9'))),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
