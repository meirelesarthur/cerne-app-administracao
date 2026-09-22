/// Mocks determinísticos de pedidos do Marketplace — espelha
/// `src/modules/marketplace/mocks/pedidos.ts`.
library;

/// Status possíveis de um pedido do Marketplace (protótipo).
enum PedidoStatus { entregue, emTransporte, processando }

/// Item de linha de um pedido (nome do produto + quantidade), dados mockados.
class PedidoItem {
  const PedidoItem({required this.nome, required this.quantidade});

  final String nome;
  final int quantidade;
}

/// Pedido do Marketplace (dados determinísticos, protótipo).
class Pedido {
  const Pedido({
    required this.id,
    required this.numero,
    required this.data,
    required this.itens,
    required this.valor,
    required this.status,
  });

  final String id;
  final String numero;

  /// data já formatada, ex.: '08/07/2026'
  final String data;
  final List<PedidoItem> itens;

  /// valor total já formatado em BRL, ex.: 'R$ 489,90'
  final String valor;
  final PedidoStatus status;
}

const List<Pedido> pedidos = [
  Pedido(
    id: 'pedido-1',
    numero: '#48213',
    data: '08/07/2026',
    itens: [
      PedidoItem(nome: 'Semente de soja Intacta', quantidade: 2),
      PedidoItem(nome: 'Ureia 45% granulada', quantidade: 5),
    ],
    valor: 'R\$ 1.729,30',
    status: PedidoStatus.emTransporte,
  ),
  Pedido(
    id: 'pedido-2',
    numero: '#47905',
    data: '29/06/2026',
    itens: [PedidoItem(nome: 'Ração confinamento 30kg', quantidade: 10)],
    valor: 'R\$ 985,00',
    status: PedidoStatus.entregue,
  ),
  Pedido(
    id: 'pedido-3',
    numero: '#48260',
    data: '11/07/2026',
    itens: [PedidoItem(nome: 'Arame liso 500m', quantidade: 3)],
    valor: 'R\$ 839,70',
    status: PedidoStatus.processando,
  ),
];
