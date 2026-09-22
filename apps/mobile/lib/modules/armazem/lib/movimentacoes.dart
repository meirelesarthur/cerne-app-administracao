import '../../../ui/ui.dart' show AppTransactionItem, AppTransactionDirection;
import '../mocks/estoque_mocks.dart';

/// Adapta uma [Movimentacao] do Armazém para o shape de [AppTransactionItem],
/// permitindo reutilizar o `AppTransactionListItem` (direção com ícone + cor,
/// nunca só cor) já usado no Banking — fonte única de verdade (Lei 2). Espelha
/// `src/modules/armazem/lib/movimentacoes.ts`.
AppTransactionItem toTransactionItem(Movimentacao mov) {
  final isEntrada = mov.tipo == MovimentacaoTipo.entrada;
  return AppTransactionItem(
    id: mov.id,
    title: mov.item,
    subtitle: isEntrada ? mov.origem : mov.destino,
    time: mov.tempo,
    value: mov.quantidade,
    direction: isEntrada
        ? AppTransactionDirection.income
        : AppTransactionDirection.expense,
  );
}
