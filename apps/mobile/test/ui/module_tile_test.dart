import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/module_tile.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child, {double width = 402}) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
  group('AppModuleTile', () {
    testWidgets('mostra rótulo e ícone do módulo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTile(
            icon: AppIcons.confinamento,
            label: 'Confinamento',
          ),
        ),
      );

      expect(find.text('Confinamento'), findsOneWidget);
      expect(findAppIcon(AppIcons.confinamento), findsOneWidget);
    });

    testWidgets('mantém a altura do padrão global', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTile(icon: AppIcons.pecuaria, label: 'Pecuária'),
          width: 180,
        ),
      );

      expect(
        tester.getSize(find.byType(AppModuleTile)).height,
        AppModuleTile.height,
      );
    });

    testWidgets('rótulo de duas linhas não estica o ladrilho', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTile(
            icon: AppIcons.sincronizar,
            label: 'Sincronizar aplicativo',
          ),
          width: 180,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(AppModuleTile)).height,
        AppModuleTile.height,
      );
    });

    testWidgets('variante de módulo usa card maior e mantém o resumo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTile(
            icon: AppIcons.warehouse,
            label: 'Meus Currais',
            description: 'Ações realizadas nos currais',
            layout: AppModuleTileLayout.module,
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(AppModuleTile)).height,
        AppModuleTile.moduleHeight,
      );
      expect(find.text('Ações realizadas nos currais'), findsOneWidget);
    });

    testWidgets('o resumo só aparece quando informado', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTile(icon: AppIcons.warehouse, label: 'Meus Currais'),
        ),
      );
      expect(find.text('Ações realizadas nos currais'), findsNothing);

      await tester.pumpWidget(
        _wrap(
          const AppModuleTile(
            icon: AppIcons.warehouse,
            label: 'Meus Currais',
            description: 'Ações realizadas nos currais',
          ),
        ),
      );
      expect(find.text('Ações realizadas nos currais'), findsOneWidget);
    });

    testWidgets('dispara onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppModuleTile(
            icon: AppIcons.agricultura,
            label: 'Agricultura',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(AppModuleTile));
      expect(tapped, isTrue);
    });

    testWidgets('renderiza nos dois temas sem exceções', (tester) async {
      for (final variant in AppThemeVariant.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(variant),
            home: const Scaffold(
              body: SizedBox(
                width: 180,
                child: AppModuleTile(
                  icon: AppIcons.gestaoFrota,
                  label: 'Gestão de Frota',
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('AppModuleTileGrid', () {
    testWidgets('contagem par mantém duas colunas de larguras iguais', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTileGrid(
            tiles: [
              AppModuleTile(icon: AppIcons.confinamento, label: 'Confinamento'),
              AppModuleTile(icon: AppIcons.pecuaria, label: 'Pecuária'),
            ],
          ),
        ),
      );

      final tiles = tester
          .widgetList<AppModuleTile>(find.byType(AppModuleTile))
          .toList();
      expect(tiles, hasLength(2));
      final first = tester.getSize(find.byType(AppModuleTile).at(0));
      final second = tester.getSize(find.byType(AppModuleTile).at(1));
      expect(first.width, second.width);
      expect(first.width, lessThan(402 / 2));
    });

    testWidgets('o último ladrilho de uma contagem ímpar ocupa a linha', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTileGrid(
            tiles: [
              AppModuleTile(icon: AppIcons.confinamento, label: 'Confinamento'),
              AppModuleTile(icon: AppIcons.pecuaria, label: 'Pecuária'),
              AppModuleTile(
                icon: AppIcons.sincronizar,
                label: 'Sincronizar aplicativo',
              ),
            ],
          ),
        ),
      );

      final last = tester.getSize(find.byType(AppModuleTile).at(2));
      expect(last.width, 402);
    });

    testWidgets('a central interna mantém o último card na primeira coluna', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTileGrid(
            lastTileFullWidth: false,
            tiles: [
              AppModuleTile(icon: AppIcons.confinamento, label: 'Confinamento'),
              AppModuleTile(icon: AppIcons.pecuaria, label: 'Pecuária'),
              AppModuleTile(
                icon: AppIcons.ordemServico,
                label: 'Ordens pendentes',
              ),
            ],
          ),
        ),
      );

      final last = tester.getSize(find.byType(AppModuleTile).at(2));
      expect(last.width, lessThan(402));
      expect(last.width, greaterThan(402 / 3));
    });

    testWidgets('a altura total soma as fileiras e o gap', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppModuleTileGrid(
            tiles: [
              AppModuleTile(icon: AppIcons.confinamento, label: 'Confinamento'),
              AppModuleTile(icon: AppIcons.pecuaria, label: 'Pecuária'),
              AppModuleTile(icon: AppIcons.agricultura, label: 'Agricultura'),
            ],
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(AppModuleTileGrid)).height,
        AppModuleTile.height * 2 + AppModuleTileGrid.gap,
      );
    });
  });
}
