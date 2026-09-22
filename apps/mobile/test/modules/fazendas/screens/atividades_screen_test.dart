import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/atividades_screen.dart';

import '../../../support/test_viewport.dart';

void main() {
  group('AtividadesScreen', () {
    testWidgets('lista as atividades e abre o detalhe ao tocar', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: AtividadesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Atividades'), findsOneWidget);
      expect(find.text('Pesagem do Lote 42'), findsOneWidget);
      expect(find.text('Página 1 de 2'), findsOneWidget);

      await tester.tap(find.text('Pesagem do Lote 42').first);
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da atividade'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pagina as atividades e mantém o detalhe na página atual', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: AtividadesScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pesagem do Lote 42'), findsOneWidget);
      expect(find.text('Transferência de lote'), findsNothing);

      await tester.tap(find.byTooltip('Próxima página'));
      await tester.pumpAndSettle();

      expect(find.text('Página 2 de 2'), findsOneWidget);
      expect(find.text('Pesagem do Lote 42'), findsNothing);
      expect(find.text('Transferência de lote'), findsOneWidget);

      await tester.tap(find.text('Transferência de lote'));
      await tester.pumpAndSettle();

      // O detalhe agora é tela cheia, não folha inferior: ele cobre a lista,
      // então a régua de paginação sai da árvore enquanto está aberto. A
      // invariante que o teste protege — paginar e abrir um item não zera a
      // página — se verifica no retorno.
      expect(find.text('Detalhe da atividade'), findsOneWidget);
      expect(find.text('Página 2 de 2'), findsNothing);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('Página 2 de 2'), findsOneWidget);
      expect(find.text('Transferência de lote'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
