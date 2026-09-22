import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/text_input.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppTextInput', () {
    testWidgets('renderiza sem exceções e mostra o placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppTextInput(placeholder: 'Digite algo')),
      );

      expect(find.text('Digite algo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onChanged ao digitar', (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(AppTextInput(onChanged: (v) => changed = v)),
      );

      await tester.enterText(find.byType(TextFormField), 'Fazenda Boa Vista');
      await tester.pump();

      expect(changed, 'Fazenda Boa Vista');
    });

    testWidgets('invalid=true não impede a digitação', (tester) async {
      await tester.pumpWidget(_wrap(const AppTextInput(invalid: true)));
      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(find.text('abc'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
