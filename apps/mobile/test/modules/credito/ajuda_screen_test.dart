import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/credito/screens/ajuda_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AjudaScreen', () {
    testWidgets('renderiza o FAQ e o banner de contato sem exceção', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AjudaScreen()));

      expect(find.text('Ajuda'), findsOneWidget);
      expect(
        find.text('Quanto tempo leva a análise de uma proposta?'),
        findsOneWidget,
      );
      expect(
        find.text('Como acompanho as parcelas de um contrato ativo?'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Não encontrou o que precisava? Fale com seu gerente de relacionamento.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
