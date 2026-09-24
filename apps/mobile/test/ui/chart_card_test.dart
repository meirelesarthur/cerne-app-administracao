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

    testWidgets('sem dados mostra a mensagem no lugar do gráfico', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppChartCard(
            title: 'Valor cotado por tipo',
            footnote: 'Nota que some sem dados',
            isEmpty: true,
            child: Text('conteúdo'),
          ),
        ),
      );

      expect(find.text('conteúdo'), findsNothing);
      expect(find.text('Nota que some sem dados'), findsNothing);
      expect(
        find.text('Sem dados no período. Ajuste o filtro acima.'),
        findsOneWidget,
      );
    });

    testWidgets('ajuda abre a definição do gráfico', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppChartCard(
            title: 'Vida útil consumida',
            help: 'Quanto do valor já foi depreciado.',
            child: Text('conteúdo'),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('O que é Vida útil consumida?'));
      await tester.pumpAndSettle();
      expect(find.text('Quanto do valor já foi depreciado.'), findsOneWidget);
    });
  });
}
