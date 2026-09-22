import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/armazem/components/movimentacao_detail_sheet.dart';
import 'package:cerne_app/modules/armazem/mocks/estoque_mocks.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

const _entrada = Movimentacao(
  id: 'mov-1',
  tipo: MovimentacaoTipo.entrada,
  item: 'Soja em grão',
  quantidade: '120 t',
  unidadeId: 'un-1',
  origem: 'NF-e 4821 · Cooperativa Agrovale',
  destino: 'Silo 01 — Soja',
  tempo: 'hoje, 07:40',
  nota: 'Recebimento de safra 24/25, lote conferido na balança rodoviária.',
  responsavel: 'Carlos Andrade',
  veiculo: 'Carreta bitrem · ABC-1234',
);

const _saida = Movimentacao(
  id: 'mov-4',
  tipo: MovimentacaoTipo.saida,
  item: 'Vacina febre aftosa',
  quantidade: '320 doses',
  unidadeId: 'un-4',
  origem: 'Câmara fria — Vacinas',
  destino: 'Fazenda Boa Vista',
  tempo: 'ontem, 14:05',
  nota: 'Aplicação em lote programada pelo calendário sanitário.',
  responsavel: 'Dra. Renata Lima',
  veiculo: 'Utilitário refrigerado · JKL-3456',
);

void main() {
  group('showMovimentacaoDetailSheet', () {
    testWidgets(
      'entrada mostra chip "Entrada", valor com "+" e origem/destino',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showMovimentacaoDetailSheet(
                  context,
                  movimentacao: _entrada,
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('abrir'));
        await tester.pumpAndSettle();

        expect(find.text('Detalhe da movimentação'), findsOneWidget);
        expect(find.text('Entrada'), findsOneWidget);
        expect(find.text('+ 120 t'), findsOneWidget);
        expect(find.text('Soja em grão'), findsOneWidget);
        expect(find.text('NF-e 4821 · Cooperativa Agrovale'), findsOneWidget);
        expect(find.text('Silo 01 — Soja'), findsOneWidget);
        expect(find.text('Carlos Andrade'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('saída mostra chip "Saída" e valor com "−"', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  showMovimentacaoDetailSheet(context, movimentacao: _saida),
              child: const Text('abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Saída'), findsOneWidget);
      expect(find.text('− 320 doses'), findsOneWidget);
      expect(find.text('Câmara fria — Vacinas'), findsOneWidget);
      expect(find.text('Fazenda Boa Vista'), findsOneWidget);
    });
  });
}
