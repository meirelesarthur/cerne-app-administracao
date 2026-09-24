import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/splash_screen.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: child,
  ),
);

void main() {
  group('AppSplashScreen', () {
    testWidgets('monta a marca, mostra o nome e avisa no fim', (tester) async {
      var done = 0;
      await tester.pumpWidget(_wrap(AppSplashScreen(onDone: () => done++)));

      expect(find.text('CERNE'), findsOneWidget);
      expect(find.text('OPERAÇÃO DE CAMPO'), findsOneWidget);
      expect(done, 0);

      await tester.pumpAndSettle();
      expect(done, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('textos sem o sublinhado de "texto sem Material"', (
      tester,
    ) async {
      // Aberta fora de um Scaffold, sem Material o Flutter pinta o aviso
      // amarelo (sublinhado duplo) nos textos.
      await tester.pumpWidget(
        MaterialApp(home: AppSplashScreen(onDone: () {})),
      );
      for (final texto in ['CERNE', 'OPERAÇÃO DE CAMPO']) {
        final rich = tester.widget<RichText>(
          find.descendant(
            of: find.text(texto),
            matching: find.byType(RichText),
          ),
        );
        expect(
          rich.text.style?.decoration,
          isNot(TextDecoration.underline),
          reason: texto,
        );
      }
      await tester.pumpAndSettle();
    });

    testWidgets('tocar pula a abertura e avisa uma vez só', (tester) async {
      var done = 0;
      await tester.pumpWidget(_wrap(AppSplashScreen(onDone: () => done++)));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(AppSplashScreen));
      expect(done, 1);

      await tester.pumpAndSettle();
      expect(done, 1);
    });

    testWidgets('sem animações mostra o quadro final e segue', (tester) async {
      var done = 0;
      await tester.pumpWidget(
        _wrap(AppSplashScreen(onDone: () => done++), disableAnimations: true),
      );
      expect(done, 0);

      await tester.pump(const Duration(seconds: 1));
      expect(done, 1);
    });
  });
}
