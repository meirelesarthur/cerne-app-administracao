import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/icon_button.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppIconButton', () {
    testWidgets('dispara onPressed ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppIconButton(
            icon: const AppIcon(AppIcons.plus),
            label: 'Adicionar',
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(AppIconButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('sem onPressed fica desabilitado (ignora toque)', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          const AppIconButton(icon: AppIcon(AppIcons.plus), label: 'Adicionar'),
        ),
      );

      await tester.tap(find.byType(AppIconButton), warnIfMissed: false);
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('renderiza todas as variantes e tamanhos sem exceções', (
      tester,
    ) async {
      for (final variant in AppIconButtonVariant.values) {
        for (final size in AppIconButtonSize.values) {
          await tester.pumpWidget(
            _wrap(
              AppIconButton(
                icon: const AppIcon(AppIcons.heart),
                label: 'X',
                variant: variant,
                size: size,
                onPressed: () {},
              ),
            ),
          );
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('todos os tamanhos preservam alvo mínimo de 44dp', (
      tester,
    ) async {
      for (final size in AppIconButtonSize.values) {
        await tester.pumpWidget(
          _wrap(
            AppIconButton(
              icon: const AppIcon(AppIcons.heart),
              label: 'Favoritar',
              size: size,
              onPressed: () {},
            ),
          ),
        );

        final dimensions = tester.getSize(find.byType(AppIconButton));
        expect(dimensions.width, greaterThanOrEqualTo(44));
        expect(dimensions.height, greaterThanOrEqualTo(44));
      }
    });
  });
}
