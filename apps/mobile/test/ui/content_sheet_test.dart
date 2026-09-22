import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/content_sheet.dart';

Widget _wrap(Widget child) {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(body: SizedBox(width: 402, height: 300, child: child)),
    ),
  );
}

void main() {
  group('AppContentSheet', () {
    testWidgets('renderiza cabeçalho e corpo na folha', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppContentSheet(
            header: Text('Fazenda Agro Pillatti'),
            child: Text('Conteúdo'),
          ),
        ),
      );

      expect(find.text('Fazenda Agro Pillatti'), findsOneWidget);
      expect(find.text('Conteúdo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('aceita conteúdo sem padding próprio', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppContentSheet(padded: false, child: SizedBox.expand())),
      );

      expect(find.byType(AppContentSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
