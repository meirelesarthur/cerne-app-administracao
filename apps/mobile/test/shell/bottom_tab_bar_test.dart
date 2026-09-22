import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/shell/components/bottom_tab_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppBottomTabBar', () {
    testWidgets('renderiza os 6 módulos sem exceção', (tester) async {
      await tester.pumpWidget(
        _wrap(AppBottomTabBar(activeId: 'inicio', onModuleSelected: (_) {})),
      );

      expect(find.byTooltip('Início'), findsOneWidget);
      expect(find.byTooltip('Fazendas'), findsOneWidget);
      expect(find.byTooltip('Bank'), findsOneWidget);
      expect(find.byTooltip('Crédito'), findsOneWidget);
      expect(find.byTooltip('Marketplace'), findsOneWidget);
      expect(find.byTooltip('Armazém'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onModuleSelected com o id do módulo tocado', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          AppBottomTabBar(
            activeId: 'inicio',
            onModuleSelected: (id) => selected = id,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Fazendas'));
      await tester.pump();

      expect(selected, 'fazendas');
    });
  });
}
