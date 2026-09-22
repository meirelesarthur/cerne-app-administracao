import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/sparkline_area.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppSparklineArea', () {
    testWidgets('pinta sem exceções com dados padrão', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSparklineArea(data: [1, 5, 3, 8, 4, 9])),
      );

      expect(find.byType(AppSparklineArea), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('aceita cor customizada sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSparklineArea(data: [1, 5, 3], color: Colors.blue)),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('com menos de 2 pontos não lança exceção', (tester) async {
      await tester.pumpWidget(_wrap(const AppSparklineArea(data: [1])));

      expect(tester.takeException(), isNull);
    });
  });
}
