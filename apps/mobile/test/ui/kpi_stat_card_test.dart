import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/kpi_stat_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppKpiStatCard', () {
    testWidgets('renderiza label, valor e caption', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppKpiStatCard(
            label: 'Receita',
            value: 'R\$ 1.000',
            caption: '+5%',
          ),
        ),
      );

      expect(find.text('Receita'), findsOneWidget);
      expect(find.text('R\$ 1.000'), findsOneWidget);
      expect(find.text('+5%'), findsOneWidget);
    });

    testWidgets('renderiza todos os tons sem exceção', (tester) async {
      for (final tone in AppKpiStatTone.values) {
        await tester.pumpWidget(
          _wrap(AppKpiStatCard(label: 'L', value: 'V', tone: tone)),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
