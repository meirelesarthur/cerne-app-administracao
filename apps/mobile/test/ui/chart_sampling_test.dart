import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/bar_chart.dart';
import 'package:cerne_app/ui/bullet_chart.dart';
import 'package:cerne_app/ui/chart_sampling.dart';
import 'package:cerne_app/ui/line_chart.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  test('amostra uniformemente e preserva as extremidades', () {
    final indexes = sampleChartIndexes(1000, 10);

    expect(indexes, hasLength(10));
    expect(indexes.first, 0);
    expect(indexes.last, 999);
    expect(indexes.toSet(), hasLength(10));
  });

  testWidgets('limita barras e bullets de bases grandes', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            AppBarChart(
              maxItems: 3,
              data: [
                for (var i = 0; i < 20; i++)
                  AppBarDatum(label: 'Item $i', value: i.toDouble()),
              ],
            ),
            AppBulletChart(
              maxItems: 3,
              data: [
                for (var i = 0; i < 20; i++)
                  AppBulletDatum(
                    label: 'Item $i',
                    value: i.toDouble(),
                    target: 20,
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(
      find.text('Exibindo 3 de 20. Use os filtros para detalhar.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('amostra séries longas antes da pintura', (tester) async {
    final labels = [for (var i = 0; i < 1000; i++) '$i'];
    await tester.pumpWidget(
      _wrap(
        AppLineChart(
          maxPoints: 24,
          labels: labels,
          series: [
            AppLineSeries(
              label: 'Série',
              points: [for (var i = 0; i < 1000; i++) i.toDouble()],
            ),
          ],
        ),
      ),
    );

    expect(find.byType(AppLineChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
