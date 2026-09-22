import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/icon_button.dart';
import 'package:cerne_app/ui/modal.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('showAppModal', () {
    testWidgets('abre e mostra título e conteúdo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppModal<void>(
                context,
                title: 'Confirmar ação',
                child: const Text('Conteúdo do modal'),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar ação'), findsOneWidget);
      expect(find.text('Conteúdo do modal'), findsOneWidget);
    });

    testWidgets('fecha ao tocar no botão de fechar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppModal<void>(
                context,
                title: 'Título',
                child: const Text('Conteúdo'),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Conteúdo'), findsOneWidget);

      await tester.tap(find.byType(AppIconButton));
      await tester.pumpAndSettle();

      expect(find.text('Conteúdo'), findsNothing);
    });

    testWidgets('renderiza rodapé quando informado', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppModal<void>(
                context,
                title: 'Título',
                child: const Text('Conteúdo'),
                footer: const Text('Confirmar'),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar'), findsOneWidget);
    });
  });
}
