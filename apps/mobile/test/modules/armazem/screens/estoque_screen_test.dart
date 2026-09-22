import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/armazem/screens/estoque_screen.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('EstoqueScreen', () {
    testWidgets('sem filtro inicial, lista todos os itens de estoque', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const EstoqueScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Todas as unidades'), findsOneWidget);
      expect(find.text('Soja em grão'), findsOneWidget);
      expect(find.text('Fertilizante NPK'), findsOneWidget);
      expect(find.text('Vacina febre aftosa'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('com initialUnidadeId, chega já filtrada pela unidade', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        _wrap(const EstoqueScreen(initialUnidadeId: 'un-3')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fertilizante NPK'), findsOneWidget);
      expect(find.text('Defensivos agrícolas'), findsOneWidget);
      expect(find.text('Ração bovina'), findsOneWidget);
      // Itens de outras unidades não aparecem.
      expect(find.text('Soja em grão'), findsNothing);
      expect(find.text('Vacina febre aftosa'), findsNothing);
    });

    testWidgets('trocar a unidade no seletor refiltra a lista', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const EstoqueScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Silo 02 — Milho').last);
      await tester.pumpAndSettle();

      expect(find.text('Milho em grão'), findsOneWidget);
      expect(find.text('Soja em grão'), findsNothing);
    });

    // Não há caso hoje em que uma unidade real tenha zero itens em
    // `itensEstoque` — o `AppEmptyState` da tela existe para essa
    // eventualidade futura, mas não é exercitável com os mocks atuais sem
    // forçar um `initialUnidadeId` inválido (o que quebra a asserção do
    // `DropdownButtonFormField`, um bug de robustez separado e fora do
    // escopo desta cobertura — ver tarefa sinalizada).
  });
}
