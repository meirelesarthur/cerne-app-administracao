import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_consultas.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashConsultas', () {
    testWidgets('renderiza sem exceção com Lotes selecionado por padrão', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashConsultas()));
      await tester.pumpAndSettle();

      expect(find.text('Consultas Gerenciais'), findsWidgets);
      expect(
        find.text('Somente leitura — dados espelhados do web.'),
        findsOneWidget,
      );
      expect(find.text('Lote 42'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'troca para a seção de Localização (esquema ilustrativo dos lotes)',
      (tester) async {
        await tester.pumpWidget(_wrap(const DashConsultas()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Localização'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('não georreferenciado'),
          findsOneWidget,
        );
        expect(find.text('Lote 42 · Curral 02'), findsOneWidget);
        expect(find.text('Lote 33 · Curral 01'), findsOneWidget);
        // Sem busca nem paginação aqui: é um esquema visual, não uma lista.
        expect(find.byType(AppPagination), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('permite buscar e paginar os registros de Lotes', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashConsultas()));
      await tester.pumpAndSettle();

      // 4 lotes, 3 por página: a primeira página traz os 3 primeiros e
      // esconde o quarto até avançar.
      expect(find.text('Lote 42'), findsOneWidget);
      expect(find.text('Lote 07'), findsOneWidget);
      expect(find.text('Lote 33'), findsNothing);
      expect(find.byType(AppPagination), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Próxima página'));
      await tester.pumpAndSettle();
      expect(find.text('Lote 33'), findsOneWidget);
      expect(find.text('Lote 42'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'Curral 05');
      await tester.pumpAndSettle();
      expect(find.text('Lote 19'), findsOneWidget);
      expect(find.text('Lote 33'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('troca de seção limpa a busca e a página anteriores', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashConsultas()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Curral 05');
      await tester.pumpAndSettle();
      expect(find.text('Lote 19'), findsOneWidget);
      expect(find.text('Lote 42'), findsNothing);

      await tester.tap(find.text('Estoque'));
      await tester.pumpAndSettle();

      expect(find.text('Ração Engorda'), findsOneWidget);
      expect(find.text('Herbicida'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
