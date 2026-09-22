import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/generated/app_layout.dart';
import 'package:cerne_app/design/generated/app_radius.dart';
import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/design/theme/app_theme_extension.dart';
import 'package:cerne_app/ui/action_bar.dart';
import 'package:cerne_app/ui/content_sheet.dart';
import 'package:cerne_app/ui/page_scaffold.dart';
import 'package:cerne_app/ui/step_progress.dart';

Widget _wrap(Widget child) {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: child,
    ),
  );
}

void main() {
  group('AppPageScaffold — anatomia do padrão global', () {
    testWidgets('a faixa do topo tem exatamente 64 px', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppPageScaffold(title: 'Novo animal', child: Text('Corpo')),
        ),
      );

      expect(
        tester.getSize(find.byType(AppPageHeaderBand)).height,
        AppLayout.headerH,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a folha sangra nas laterais e desce até a base da tela', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppPageScaffold(title: 'Novo animal', child: Text('Corpo')),
        ),
      );

      final screen = tester.getSize(find.byType(MaterialApp));
      final sheet = tester.getRect(find.byType(AppContentSheet));

      expect(sheet.left, 0);
      expect(sheet.right, screen.width);
      expect(sheet.bottom, screen.height);
    });

    testWidgets('a folha arredonda só as quinas de cima, em raio 20', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppPageScaffold(title: 'Novo animal', child: Text('Corpo')),
        ),
      );

      final decoration = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(AppContentSheet),
              matching: find.byType(Container),
            ),
          )
          .map((container) => container.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((box) => box.borderRadius != null);

      expect(
        decoration.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(AppRadius.surface)),
      );
    });

    testWidgets('a folha é branca — a superfície do cadastro, não um cartão', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppPageScaffold(title: 'Novo animal', child: Text('Corpo')),
        ),
      );

      final context = tester.element(find.byType(AppContentSheet));
      final semantic = Theme.of(context).extension<AppSemanticColors>()!;

      expect(
        tester.widget<AppContentSheet>(find.byType(AppContentSheet)).color,
        semantic.bgSurface,
      );
      // E o canvas atrás continua no cinza que faz o raio de cima aparecer.
      expect(semantic.bgSurface, isNot(semantic.bgCanvas));
    });

    testWidgets('a régua de etapas fica dentro da folha, não acima dela', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppPageScaffold(
            title: 'Nova pesagem',
            totalSteps: 4,
            currentStep: 2,
            child: Text('Corpo'),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(AppContentSheet),
          matching: find.byType(AppStepProgress),
        ),
        findsOneWidget,
      );
      // E o topo da régua está abaixo da faixa de 64 px — a régua não invade o
      // cromo de navegação, onde só cabem título, voltar e opções.
      expect(
        tester.getRect(find.byType(AppStepProgress)).top,
        greaterThanOrEqualTo(AppLayout.headerH),
      );
    });

    testWidgets('o rodapé de ação fica dentro da folha e não rola', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppPageScaffold(
            title: 'Novo animal',
            actionBar: AppActionBar(
              primaryLabel: 'Salvar registro',
              onPrimary: () {},
            ),
            child: const Text('Corpo'),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(AppContentSheet),
          matching: find.byType(AppActionBar),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byType(AppActionBar),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    });
  });

  group('showAppDetailPage', () {
    testWidgets('abre a visualização em tela cheia e volta pelo cabeçalho', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAppDetailPage<void>(
                  context,
                  title: 'Detalhe da movimentação',
                  child: const Text('18,4 t de milho grão'),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Tela cheia, não folha inferior: a lista de origem sai da árvore.
      expect(find.byType(AppPageScaffold), findsOneWidget);
      expect(find.text('18,4 t de milho grão'), findsOneWidget);
      expect(find.text('Abrir'), findsNothing);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.byType(AppPageScaffold), findsNothing);
      expect(find.text('Abrir'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
