import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/error_state.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppErrorState', () {
    testWidgets('renderiza título e descrição padrão', (tester) async {
      await tester.pumpWidget(_wrap(const AppErrorState()));

      expect(find.text('Não foi possível carregar'), findsOneWidget);
      expect(
        find.text('Ocorreu um erro ao buscar os dados. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('mostra botão de retry e dispara onRetry ao tocar', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(AppErrorState(onRetry: () => retried = true)),
      );

      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('aceita título e descrição customizados', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppErrorState(
            title: 'Falha ao sincronizar',
            description: 'Verifique sua conexão.',
          ),
        ),
      );

      expect(find.text('Falha ao sincronizar'), findsOneWidget);
      expect(find.text('Verifique sua conexão.'), findsOneWidget);
    });
  });
}
