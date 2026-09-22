import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_ordem_servico.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashOrdemServico', () {
    testWidgets('lista as OS da fazenda e oferece a criação de uma nova', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      expect(find.text('Criar OS'), findsOneWidget);
      expect(
        find.text('OS #2201 · Reparo de cerca do Talhão 04'),
        findsOneWidget,
      );
      expect(
        find.text('OS #2170 · Construção de bebedouro no Piquete 07'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtra por status via as abas segmentadas', (tester) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AppSegmentedTabs),
          matching: find.text('Aguardando'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('OS #2201 · Reparo de cerca do Talhão 04'),
        findsOneWidget,
      );
      expect(
        find.text('OS #2170 · Construção de bebedouro no Piquete 07'),
        findsNothing,
      );
    });

    testWidgets('filtra por data de prazo e permite limpar o filtro', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      // Nenhum mock tem prazo hoje — o filtro "Hoje" deve esvaziar a lista.
      await tester.tap(find.text('Hoje'));
      await tester.pumpAndSettle();

      expect(
        find.text('OS #2201 · Reparo de cerca do Talhão 04'),
        findsNothing,
      );
      expect(find.text('Nenhuma OS encontrada'), findsOneWidget);

      await tester.tap(find.text('Todas as datas'));
      await tester.pumpAndSettle();

      expect(
        find.text('OS #2201 · Reparo de cerca do Talhão 04'),
        findsOneWidget,
      );
    });

    testWidgets('cria uma nova OS a partir do formulário', (tester) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Criar OS').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(AppTextInput).at(0),
        'Reparo do moinho de vento',
      );
      await tester.enterText(
        find.byType(AppTextInput).at(1),
        'Pasto 12',
      );
      await tester.enterText(find.byType(AppDateInput).last, '30/12/2026');
      await tester.enterText(
        find.byType(AppTextarea),
        'Substituir a hélice do moinho danificada pelo vento forte.',
      );
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(AppButton, 'Criar OS').last;
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('Reparo do moinho de vento'), findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.textContaining('Reparo do moinho de vento'),
            matching: find.byType(AppCard),
          ),
          matching: find.text('Aguardando'),
        ),
        findsOneWidget,
      );
    });
  });
}
