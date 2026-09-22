import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/shell/components/context_tabs.dart';
import 'package:cerne_app/shell/module_config.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppContextTabs', () {
    final module = getModule('bank')!;

    testWidgets(
      'renderiza as abas navegáveis (sem a ação "Mais") sem exceção',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            AppContextTabs(
              module: module,
              activePath: '',
              onTabSelected: (_) {},
            ),
          ),
        );

        expect(find.text('Início'), findsOneWidget);
        expect(find.text('Extrato'), findsOneWidget);
        expect(find.text('Mais'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('dispara onTabSelected com o path relativo tocado', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          AppContextTabs(
            module: module,
            activePath: '',
            onTabSelected: (path) => selected = path,
          ),
        ),
      );

      await tester.tap(find.text('Extrato'));
      await tester.pump();

      expect(selected, 'extrato');
    });
  });
}
