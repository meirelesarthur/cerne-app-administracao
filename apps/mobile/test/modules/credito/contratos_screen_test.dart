import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/credito/screens/contratos_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('ContratosScreen', () {
    testWidgets('renderiza os contratos ativos com progresso de parcelas', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const ContratosScreen()));

      expect(find.text('Contratos'), findsOneWidget);
      expect(find.text('CPR Financeira'), findsOneWidget);
      expect(find.text('Custeio Safra 24/25'), findsOneWidget);
      expect(find.text('8 de 24 parcelas pagas'), findsOneWidget);
      expect(find.text('11 de 12 parcelas pagas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'tocar em um contrato abre o bottom sheet com próxima parcela, vencimento e saldo',
      (tester) async {
        await tester.pumpWidget(_wrap(const ContratosScreen()));

        await tester.tap(find.text('CPR Financeira'));
        await tester.pumpAndSettle();

        // O rótulo do campo de leitura aparece em versalete (`AppReviewList`).
        expect(find.text('PRÓXIMA PARCELA'), findsOneWidget);
        expect(find.text('R\$ 4.520,33'), findsOneWidget);
        expect(find.text('VENCIMENTO'), findsOneWidget);
        expect(find.text('05/08'), findsOneWidget);
        expect(find.text('SALDO DEVEDOR'), findsOneWidget);
        expect(find.text('R\$ 68.220,17'), findsOneWidget);
      },
    );
  });
}
