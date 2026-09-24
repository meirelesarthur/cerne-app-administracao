import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:cerne_app/design/generated/app_layout.dart';
import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/pressable.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AppPressable', () {
    testWidgets(
      'minTouchTarget não estica um glifo menor que o alvo mínimo (regressão do ícone de ajuda)',
      (tester) async {
        // Reproduz o `AppHelpButton`: ícone de 16px dentro do alvo mínimo de
        // 48px. Sem o `Center` que decide o tamanho do ícone antes do
        // `ConstrainedBox`, a constraint mínima cascateava pelo `SizedBox`
        // interno do `HugeIcon` (`enforce`) e o desenho era esticado para
        // preencher os 48px inteiros.
        await tester.pumpWidget(
          _wrap(
            AppPressable(
              semanticLabel: 'Ajuda',
              onPressed: () {},
              child: const AppIcon(AppIcons.helpCircle, size: AppSize.iconSm),
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(HugeIcon)),
          const Size(AppSize.iconSm, AppSize.iconSm),
        );
        // O alvo de toque continua garantido em volta do ícone.
        expect(
          tester.getSize(find.byType(AppPressable)),
          const Size(AppSize.control, AppSize.control),
        );
      },
    );

    testWidgets('minTouchTarget: false não altera o tamanho do conteúdo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppPressable(
            semanticLabel: 'Ajuda',
            onPressed: () {},
            minTouchTarget: false,
            child: const AppIcon(AppIcons.helpCircle, size: AppSize.iconSm),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(HugeIcon)),
        const Size(AppSize.iconSm, AppSize.iconSm),
      );
      expect(
        tester.getSize(find.byType(AppPressable)),
        const Size(AppSize.iconSm, AppSize.iconSm),
      );
    });

    testWidgets('conteúdo maior que o alvo mínimo continua preenchendo tudo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            child: AppPressable(
              semanticLabel: 'Linha',
              onPressed: () {},
              child: const SizedBox(
                width: 200,
                height: 80,
                child: Text('Conteúdo'),
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AppPressable)), const Size(200, 80));
    });
  });
}
