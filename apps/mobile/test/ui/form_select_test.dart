import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/form_select.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

const _options = [
  AppFormSelectOption(value: 'soja', label: 'Soja'),
  AppFormSelectOption(value: 'milho', label: 'Milho'),
];

void main() {
  group('AppFormSelect', () {
    testWidgets('renderiza o placeholder sem exceções', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppFormSelect(
            options: _options,
            placeholder: 'Selecione a cultura',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Selecione a cultura'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onChanged ao selecionar uma opção', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          AppFormSelect(
            options: _options,
            placeholder: 'Selecione a cultura',
            onChanged: (v) => selected = v,
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Milho').last);
      await tester.pumpAndSettle();

      expect(selected, 'milho');
    });
  });
}
