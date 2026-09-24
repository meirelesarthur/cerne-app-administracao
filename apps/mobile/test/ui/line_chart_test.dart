import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/line_chart.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  group('AppLineChart', () {
    const labels = ['Jan', 'Fev', 'Mar'];
    const series = [
      AppLineSeries(label: 'Receita', points: [10, 20, 30]),
      AppLineSeries(label: 'Custo', points: [5, 8, 12]),
    ];

    testWidgets('tocar no gráfico mostra o valor exato de cada série', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppLineChart(
            series: series,
            labels: labels,
            formatValue: (v) => v.toStringAsFixed(0),
          ),
        ),
      );
      expect(find.text('Receita 30'), findsNothing);

      // Toque na borda direita: último ponto (Mar).
      final area = tester.getRect(find.byType(CustomPaint).last);
      await tester.tapAt(Offset(area.right - 2, area.center.dy));
      await tester.pump();

      expect(find.text('Mar'), findsWidgets);
      expect(find.text('Receita 30'), findsOneWidget);
      expect(find.text('Custo 12'), findsOneWidget);

      // Tocar de novo no mesmo ponto limpa a leitura.
      await tester.tapAt(Offset(area.right - 2, area.center.dy));
      await tester.pump();
      expect(find.text('Receita 30'), findsNothing);
    });

    testWidgets('resume as séries para leitores de tela', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          AppLineChart(
            series: series,
            labels: labels,
            formatValue: (v) => v.toStringAsFixed(0),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(RegExp('Receita de 10 a 30')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
