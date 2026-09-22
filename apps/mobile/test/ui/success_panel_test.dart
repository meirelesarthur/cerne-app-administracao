import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/success_panel.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppSuccessPanel', () {
    testWidgets('renderiza título, descrição e ícone padrão', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppSuccessPanel(
            title: 'Operação concluída',
            description: Text('Detalhes da operação.'),
          ),
        ),
      );

      expect(find.text('Operação concluída'), findsOneWidget);
      expect(find.text('Detalhes da operação.'), findsOneWidget);
      expect(findAppIcon(AppIcons.checkCircle2), findsOneWidget);
    });

    testWidgets('aceita ícone customizado e ações', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppSuccessPanel(
            title: 'Título',
            icon: AppIcons.info,
            actions: ElevatedButton(
              onPressed: () {},
              child: const Text('Continuar'),
            ),
          ),
        ),
      );

      expect(findAppIcon(AppIcons.info), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    });
  });
}
