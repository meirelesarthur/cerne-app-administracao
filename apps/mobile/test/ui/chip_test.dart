import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/chip.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppChip', () {
    testWidgets('renderiza o conteúdo sem exceção', (tester) async {
      await tester.pumpWidget(_wrap(const AppChip(child: Text('Neutro'))));

      expect(find.text('Neutro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza com ícone e todos os tons sem exceção', (
      tester,
    ) async {
      for (final tone in AppChipTone.values) {
        await tester.pumpWidget(
          _wrap(
            AppChip(
              tone: tone,
              icon: const AppIcon(AppIcons.check),
              child: const Text('Status'),
            ),
          ),
        );
        expect(find.text('Status'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
