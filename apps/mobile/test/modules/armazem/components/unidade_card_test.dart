import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/armazem/components/unidade_card.dart';
import 'package:cerne_app/modules/armazem/mocks/estoque_mocks.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

const _unidade = Unidade(
  id: 'un-2',
  nome: 'Silo 02 — Milho',
  produto: 'Milho em grão',
  capacidade: '12.000 t',
  ocupacaoPct: 95,
  status: UnidadeStatus.atencao,
  endereco: 'Rod. BR-153, km 43 — Rio Verde/GO',
);

void main() {
  group('UnidadeCard', () {
    testWidgets('renderiza nome, produto, chip de status e ocupação', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UnidadeCard(unidade: _unidade)));

      expect(find.text('Silo 02 — Milho'), findsOneWidget);
      expect(find.text('Milho em grão · 12.000 t'), findsOneWidget);
      expect(find.text('Atenção'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dispara onTap ao tocar', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(UnidadeCard(unidade: _unidade, onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(UnidadeCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
