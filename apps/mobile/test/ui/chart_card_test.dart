import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/chart_card.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppChartCard', () {
    testWidgets('renderiza título e conteúdo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppChartCard(
            title: 'Receitas x Despesas',
            child: Text('conteúdo do gráfico'),
          ),
        ),
      );

      expect(find.text('Receitas x Despesas'), findsOneWidget);
      expect(find.text('conteúdo do gráfico'), findsOneWidget);
    });

    testWidgets('renderiza subtítulo e ação quando informados', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppChartCard(
            title: 'Produção mensal',
            subtitle: 'Últimos 6 meses',
            action: AppIcon(AppIcons.moreHorizontal),
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('Últimos 6 meses'), findsOneWidget);
      expect(findAppIcon(AppIcons.moreHorizontal), findsOneWidget);
    });
  });
}
