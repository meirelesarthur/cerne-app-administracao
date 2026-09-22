import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/design/theme/app_theme_extension.dart';
import 'package:cerne_app/ui/card.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('AppCard', () {
    testWidgets('renderiza conteúdo sem exceção (variant surface e ink)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppCard(child: Text('Conteúdo'))));
      expect(find.text('Conteúdo'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _wrap(const AppCard(variant: AppCardVariant.ink, child: Text('Ink'))),
      );
      expect(find.text('Ink'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('inset é bloco cinza sem elevação, para folha branca', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppCard(variant: AppCardVariant.inset, child: Text('Inset')),
        ),
      );

      final context = tester.element(find.byType(AppCard));
      final semantic = Theme.of(context).extension<AppSemanticColors>()!;
      final decoration =
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byType(AppCard),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;

      expect(decoration.color, semantic.bgSheet);
      // Sem sombra: sobre branco, a separação vem da cor do bloco, não de uma
      // elevação que o branco-no-branco não sustenta.
      expect(decoration.boxShadow, isNull);
      // E o `surface` continua branco com sombra, para a folha cinza.
      await tester.pumpWidget(_wrap(const AppCard(child: Text('Surface'))));
      final surface =
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byType(AppCard),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(surface.color, semantic.bgRaised);
      expect(surface.boxShadow, isNotNull);
    });

    testWidgets('interactive dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppCard(
            interactive: true,
            onTap: () => tapped = true,
            child: const Text('Toque aqui'),
          ),
        ),
      );

      await tester.tap(find.text('Toque aqui'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('sem interactive não registra InkWell clicável', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppCard(child: Text('Estático'))));
      expect(find.byType(InkWell), findsNothing);
    });
  });
}
