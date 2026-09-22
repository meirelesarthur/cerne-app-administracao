import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/farm_selector.dart';
import 'package:cerne_app/ui/search_field.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(
    body: Center(child: SizedBox(width: 370, child: child)),
  ),
);

void main() {
  group('AppFarmSelector', () {
    testWidgets('mostra a fazenda em contexto com o ícone do domínio', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppFarmSelector(farmName: 'Fazenda Agro Pillatti')),
      );

      expect(find.text('Fazenda Agro Pillatti'), findsOneWidget);
      expect(findAppIcon(AppIcons.fazenda), findsOneWidget);
    });

    testWidgets('sem onTap não oferece caret nem alvo de toque', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppFarmSelector(farmName: 'Fazenda Santa Helena')),
      );

      expect(findAppIcon(AppIcons.chevronDown), findsNothing);
    });

    testWidgets('com onTap oferece o caret e dispara a troca', (tester) async {
      var trocou = false;
      await tester.pumpWidget(
        _wrap(
          AppFarmSelector(
            farmName: 'Fazenda Agro Pillatti',
            onTap: () => trocou = true,
          ),
        ),
      );

      expect(findAppIcon(AppIcons.chevronDown), findsOneWidget);
      await tester.tap(find.byType(AppFarmSelector));
      expect(trocou, isTrue);
    });

    testWidgets('nome longo não estoura a linha', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppFarmSelector(
            farmName: 'Fazenda Nossa Senhora Aparecida do Vale Verde',
            onTap: () {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('AppSearchField', () {
    testWidgets('mostra o placeholder padrão e o ícone de busca', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppSearchField()));

      expect(find.text('Procurando por algo?'), findsOneWidget);
      expect(findAppIcon(AppIcons.aiSearch), findsOneWidget);
    });

    testWidgets('mantém a altura do padrão global', (tester) async {
      await tester.pumpWidget(_wrap(const AppSearchField()));

      expect(
        tester.getSize(find.byType(AppSearchField)).height,
        AppSearchField.height,
      );
    });

    testWidgets('placeholder próprio substitui o padrão', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSearchField(placeholder: 'Buscar em Confinamento')),
      );

      expect(find.text('Buscar em Confinamento'), findsOneWidget);
      expect(find.text('Procurando por algo?'), findsNothing);
    });

    testWidgets('abre a busca ao tocar', (tester) async {
      var abriu = false;
      await tester.pumpWidget(_wrap(AppSearchField(onTap: () => abriu = true)));

      await tester.tap(find.byType(AppSearchField));
      expect(abriu, isTrue);
    });

    testWidgets('renderiza nos dois temas sem exceções', (tester) async {
      for (final variant in AppThemeVariant.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(variant),
            home: const Scaffold(
              body: SizedBox(width: 370, child: AppSearchField()),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
