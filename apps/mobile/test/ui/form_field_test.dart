import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/form_field.dart';
import 'package:cerne_app/ui/text_input.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppFormField', () {
    testWidgets('renderiza label, hint e o controle filho sem exceções', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppFormField(
            label: 'Nome',
            hint: 'Como aparece nos relatórios',
            child: AppTextInput(placeholder: 'Fazenda Boa Vista'),
          ),
        ),
      );

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Como aparece nos relatórios'), findsOneWidget);
      expect(find.text('Fazenda Boa Vista'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mostra erro no lugar do hint quando error é informado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppFormField(
            label: 'CNPJ',
            hint: 'Não deveria aparecer',
            error: 'CNPJ inválido',
            child: AppTextInput(),
          ),
        ),
      );

      expect(find.text('CNPJ inválido'), findsOneWidget);
      expect(find.text('Não deveria aparecer'), findsNothing);
    });

    testWidgets('required=true mostra asterisco', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppFormField(
            label: 'Nome',
            required: true,
            child: AppTextInput(),
          ),
        ),
      );

      // Sem espaço antes: no Figma o marcador cola no rótulo ("Batida de dieta*").
      expect(find.text('*'), findsOneWidget);
    });
  });
}
