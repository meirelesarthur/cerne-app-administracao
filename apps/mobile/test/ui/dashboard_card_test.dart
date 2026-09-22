import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/dashboard_card.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppDashboardCard', () {
    testWidgets('renderiza label e valor, e dispara onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppDashboardCard(
            icon: AppIcons.wallet,
            label: 'Receita do mês',
            value: 'R\$ 24.500',
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Receita do mês'), findsOneWidget);
      expect(find.text('R\$ 24.500'), findsOneWidget);

      await tester.tap(find.byType(AppDashboardCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('mostra delta positivo e negativo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppDashboardCard(
            icon: AppIcons.trendingUp,
            label: 'Receitas',
            value: 'R\$ 1.000',
            delta: 8.4,
          ),
        ),
      );
      expect(find.text('+8.4%'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const AppDashboardCard(
            icon: AppIcons.trendingDown,
            label: 'Despesas',
            value: 'R\$ 500',
            delta: -3.1,
          ),
        ),
      );
      expect(find.text('-3.1%'), findsOneWidget);
    });

    testWidgets('estado disabled ignora toque e mostra cadeado', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppDashboardCard(
            icon: AppIcons.egg,
            label: 'Reprodutivo',
            value: '0',
            disabled: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(findAppIcon(AppIcons.lock), findsOneWidget);
      expect(find.text('Indisponível no momento'), findsOneWidget);

      await tester.tap(find.byType(AppDashboardCard), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('renderiza todas as variantes sem exceções', (tester) async {
      for (final variant in AppDashboardCardVariant.values) {
        await tester.pumpWidget(
          _wrap(
            AppDashboardCard(
              icon: AppIcons.wallet,
              label: 'Label',
              value: '1',
              variant: variant,
              spark: const [1, 2, 3, 4],
              onTap: () {},
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
