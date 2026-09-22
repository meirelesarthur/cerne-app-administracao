import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/donut_chart.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppDonutChart', () {
    const sample = [
      AppDonutSlice(label: 'Soja', value: 45),
      AppDonutSlice(label: 'Milho', value: 30),
      AppDonutSlice(label: 'Algodão', value: 15),
    ];

    testWidgets('pinta sem exceções com dados padrão', (tester) async {
      await tester.pumpWidget(_wrap(const AppDonutChart(data: sample)));

      expect(find.byType(AppDonutChart), findsOneWidget);
      expect(find.text('Soja'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renderiza rótulo/valor central sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppDonutChart(
            data: sample,
            centerValue: '90 ha',
            centerLabel: 'total',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('lida com lista vazia sem exceções', (tester) async {
      await tester.pumpWidget(_wrap(const AppDonutChart(data: [])));

      expect(tester.takeException(), isNull);
    });
  });
}
