import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/empty_state.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppEmptyState', () {
    testWidgets('renderiza título, descrição, ícone e ação', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppEmptyState(
            icon: AppIcons.inbox,
            title: 'Nenhum lançamento encontrado',
            description: 'Ajuste os filtros.',
            action: ElevatedButton(
              onPressed: () {},
              child: const Text('Recarregar'),
            ),
          ),
        ),
      );

      expect(find.text('Nenhum lançamento encontrado'), findsOneWidget);
      expect(find.text('Ajuste os filtros.'), findsOneWidget);
      expect(findAppIcon(AppIcons.inbox), findsOneWidget);
      expect(find.text('Recarregar'), findsOneWidget);
    });

    testWidgets('funciona sem ícone, descrição ou ação', (tester) async {
      await tester.pumpWidget(_wrap(const AppEmptyState(title: 'Sem dados')));

      expect(find.text('Sem dados'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
