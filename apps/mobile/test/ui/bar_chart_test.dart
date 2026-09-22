import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/bar_chart.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppBarChart', () {
    const sample = [
      AppBarDatum(label: 'Jan', value: 42),
      AppBarDatum(label: 'Fev', value: 68),
      AppBarDatum(label: 'Mar', value: 91),
    ];

    testWidgets('pinta sem exceções com dados padrão', (tester) async {
      await tester.pumpWidget(_wrap(const AppBarChart(data: sample)));

      expect(find.byType(AppBarChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('aceita formatValue customizado sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppBarChart(
            data: sample,
            formatValue: (v) => 'R\$ ${v.toStringAsFixed(0)}',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('lida com lista vazia sem exceções', (tester) async {
      await tester.pumpWidget(_wrap(const AppBarChart(data: [])));

      expect(tester.takeException(), isNull);
    });
  });
}
