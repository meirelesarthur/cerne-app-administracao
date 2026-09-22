import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/bottom_sheet.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('showAppBottomSheet', () {
    testWidgets('abre e mostra título e conteúdo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppBottomSheet<void>(
                context,
                title: 'Detalhes',
                child: const Text('Conteúdo do sheet'),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhes'), findsOneWidget);
      expect(find.text('Conteúdo do sheet'), findsOneWidget);
    });

    testWidgets('fecha ao tocar na barreira', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppBottomSheet<void>(
                context,
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

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.text('Conteúdo'), findsNothing);
    });
  });
}
