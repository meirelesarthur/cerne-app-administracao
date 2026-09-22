import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/bank/components/bank_flow_shell.dart';
import '../../helpers/cta_finder.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('BankFlowShell', () {
    testWidgets('renderiza título, conteúdo e botão primário', (tester) async {
      var primaryTapped = false;
      await tester.pumpWidget(
        _wrap(
          BankFlowShell(
            title: 'Pix',
            onBack: () {},
            primaryLabel: 'Revisar',
            onPrimary: () => primaryTapped = true,
            child: const Text('Conteúdo do fluxo'),
          ),
        ),
      );

      expect(find.text('Pix'), findsOneWidget);
      expect(find.text('Conteúdo do fluxo'), findsOneWidget);
      expect(findCta('Revisar'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(findCta('Revisar'));
      await tester.pump();
      expect(primaryTapped, isTrue);
    });

    testWidgets('sem primaryLabel oculta o rodapé', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BankFlowShell(
            title: 'Pix',
            onBack: () {},
            child: const Text('Conteúdo'),
          ),
        ),
      );

      expect(findCta('Revisar'), findsNothing);
    });

    testWidgets('botão de voltar dispara onBack', (tester) async {
      var backTapped = false;
      await tester.pumpWidget(
        _wrap(
          BankFlowShell(
            title: 'Pix',
            onBack: () => backTapped = true,
            child: const Text('Conteúdo'),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pump();

      expect(backTapped, isTrue);
    });
  });
}
