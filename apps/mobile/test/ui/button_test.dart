import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/button.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppButton', () {
    testWidgets('dispara onPressed ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppButton(onPressed: () => tapped = true, child: const Text('OK')),
        ),
      );

      await tester.tap(find.text('OK'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('sem onPressed fica desabilitado (ignora toque)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppButton(child: Text('Disabled'))));

      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('loading=true ignora toque e mostra o spinner', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppButton(
            loading: true,
            onPressed: () => tapped = true,
            child: const Text('Loading'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Loading'), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('renderiza todas as variantes e tamanhos sem exceções', (
      tester,
    ) async {
      for (final variant in AppButtonVariant.values) {
        for (final size in AppButtonSize.values) {
          await tester.pumpWidget(
            _wrap(
              AppButton(
                variant: variant,
                size: size,
                onPressed: () {},
                child: const Text('X'),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('tamanhos e variante link preservam alvo mínimo de 44dp', (
      tester,
    ) async {
      for (final variant in AppButtonVariant.values) {
        await tester.pumpWidget(
          _wrap(
            AppButton(
              variant: variant,
              size: AppButtonSize.sm,
              onPressed: () {},
              child: const Text('Alvo'),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(AppButton)).height,
          greaterThanOrEqualTo(44),
        );
      }
    });
  });
}
