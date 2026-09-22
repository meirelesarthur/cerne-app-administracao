import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/skeleton.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppSkeleton', () {
    testWidgets('renderiza e anima sem exceções', (tester) async {
      await tester.pumpWidget(_wrap(const AppSkeleton(width: 100, height: 16)));
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza todos os raios sem exceções', (tester) async {
      for (final rounded in AppSkeletonRadius.values) {
        await tester.pumpWidget(_wrap(AppSkeleton(rounded: rounded)));
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('AppCardSkeleton', () {
    testWidgets('renderiza sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox(width: 260, child: AppCardSkeleton())),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
