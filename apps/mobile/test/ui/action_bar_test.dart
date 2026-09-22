import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/action_bar.dart';

Widget _wrap(Widget child) {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(
        body: Align(alignment: Alignment.bottomCenter, child: child),
      ),
    ),
  );
}

void main() {
  group('AppActionBar', () {
    testWidgets('mostra CTA, escape e resumo de progresso', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppActionBar(
            primaryLabel: 'Próximo',
            secondaryLabel: 'Cancelar',
            summary: AppActionBarSummary(
              leadingLabel: 'Fornecido',
              leadingValue: '250kg',
              trailingLabel: 'Faltam',
              trailingValue: '250kg',
              value: 50,
            ),
          ),
        ),
      );

      expect(find.text('PRÓXIMO'), findsOneWidget);
      expect(find.text('CANCELAR'), findsOneWidget);
      expect(find.textContaining('Fornecido'), findsOneWidget);
      expect(find.textContaining('Faltam'), findsOneWidget);
    });

    testWidgets('dispara as duas ações', (tester) async {
      var primary = false;
      var secondary = false;
      await tester.pumpWidget(
        _wrap(
          AppActionBar(
            primaryLabel: 'Salvar',
            onPrimary: () => primary = true,
            secondaryLabel: 'Cancelar',
            onSecondary: () => secondary = true,
          ),
        ),
      );

      await tester.tap(find.text('SALVAR'));
      await tester.tap(find.text('CANCELAR'));
      expect(primary, isTrue);
      expect(secondary, isTrue);
    });
  });
}
