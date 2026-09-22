import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/illustration_slot.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppIllustrationSlot', () {
    testWidgets('renderiza fallback com ícone sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppIllustrationSlot(alt: 'Onboarding', icon: AppIcons.sprout),
        ),
      );

      expect(find.byType(AppIllustrationSlot), findsOneWidget);
      expect(find.bySemanticsLabel('Onboarding'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza fallback vazio (sem ícone) sem exceções', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppIllustrationSlot(alt: 'Estado vazio')),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza hero full-bleed com fallback sem exceções', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SizedBox(
            height: 240,
            child: AppIllustrationSlot(
              alt: 'Onboarding — hero',
              icon: AppIcons.sprout,
              fullBleed: true,
            ),
          ),
        ),
      );

      expect(find.byType(AppIllustrationSlot), findsOneWidget);
      expect(find.bySemanticsLabel('Onboarding — hero'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
