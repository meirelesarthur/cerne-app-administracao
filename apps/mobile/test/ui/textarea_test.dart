import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/textarea.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppTextarea', () {
    testWidgets('renderiza sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppTextarea(placeholder: 'Observações')),
      );

      expect(find.text('Observações'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onChanged ao digitar', (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(AppTextarea(onChanged: (v) => changed = v)),
      );

      await tester.enterText(find.byType(TextFormField), 'Colheita concluída');
      await tester.pump();

      expect(changed, 'Colheita concluída');
    });

    testWidgets('enabled=false desabilita o campo', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextarea(enabled: false)));

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });
  });
}
