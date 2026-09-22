import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/armazem/lib/movimentacoes.dart';
import 'package:cerne_app/modules/armazem/mocks/estoque_mocks.dart';
import 'package:cerne_app/ui/transaction_list_item.dart';

const _entrada = Movimentacao(
  id: 'mov-e',
  tipo: MovimentacaoTipo.entrada,
  item: 'Soja em grão',
  quantidade: '120 t',
  unidadeId: 'un-1',
  origem: 'NF-e 4821 · Cooperativa Agrovale',
  destino: 'Silo 01 — Soja',
  tempo: 'hoje, 07:40',
  nota: 'nota',
  responsavel: 'Carlos Andrade',
  veiculo: 'Carreta bitrem · ABC-1234',
);

const _saida = Movimentacao(
  id: 'mov-s',
  tipo: MovimentacaoTipo.saida,
  item: 'Ração bovina',
  quantidade: '48 sacas',
  unidadeId: 'un-3',
  origem: 'Galpão de insumos',
  destino: 'Fazenda Santa Rita',
  tempo: 'hoje, 06:55',
  nota: 'nota',
  responsavel: 'Marina Souza',
  veiculo: 'Caminhão toco · DEF-5678',
);

void main() {
  group('toTransactionItem', () {
    test('entrada usa a origem como subtítulo e direção income', () {
      final item = toTransactionItem(_entrada);

      expect(item.id, 'mov-e');
      expect(item.title, 'Soja em grão');
      expect(item.subtitle, 'NF-e 4821 · Cooperativa Agrovale');
      expect(item.time, 'hoje, 07:40');
      expect(item.value, '120 t');
      expect(item.direction, AppTransactionDirection.income);
    });

    test('saída usa o destino como subtítulo e direção expense', () {
      final item = toTransactionItem(_saida);

      expect(item.id, 'mov-s');
      expect(item.title, 'Ração bovina');
      expect(item.subtitle, 'Fazenda Santa Rita');
      expect(item.direction, AppTransactionDirection.expense);
    });
  });
}
