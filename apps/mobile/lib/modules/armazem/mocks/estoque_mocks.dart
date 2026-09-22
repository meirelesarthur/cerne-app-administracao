/// Mocks determinísticos da visão de Estoque do módulo Armazém — espelha
/// `src/modules/armazem/mocks/estoque.ts`.
library;

/// KPIs de topo da home do Armazém.
class Kpis {
  static const ocupacao = '72%';
  static const ocupacaoPct = 72;
  static const skus = '148';
  static const alertas = '3';
}

enum UnidadeStatus { ok, atencao, critico }

class Unidade {
  const Unidade({
    required this.id,
    required this.nome,
    required this.produto,
    required this.capacidade,
    required this.ocupacaoPct,
    required this.status,
    required this.endereco,
  });

  final String id;
  final String nome;
  final String produto;
  final String capacidade;
  final int ocupacaoPct;
  final UnidadeStatus status;

  /// Endereço mock exibido no detalhe da unidade.
  final String endereco;
}

/// Unidades de armazenagem (silos, galpões, câmaras) com nível de ocupação.
const List<Unidade> unidades = [
  Unidade(
    id: 'un-1',
    nome: 'Silo 01 — Soja',
    produto: 'Soja em grão',
    capacidade: '12.000 t',
    ocupacaoPct: 84,
    status: UnidadeStatus.ok,
    endereco: 'Rod. BR-153, km 42 — Rio Verde/GO',
  ),
  Unidade(
    id: 'un-2',
    nome: 'Silo 02 — Milho',
    produto: 'Milho em grão',
    capacidade: '12.000 t',
    ocupacaoPct: 95,
    status: UnidadeStatus.atencao,
    endereco: 'Rod. BR-153, km 43 — Rio Verde/GO',
  ),
  Unidade(
    id: 'un-3',
    nome: 'Galpão de insumos',
    produto: 'Fertilizantes e defensivos',
    capacidade: '3.500 t',
    ocupacaoPct: 58,
    status: UnidadeStatus.ok,
    endereco: 'Av. dos Agricultores, 1200 — Rio Verde/GO',
  ),
  Unidade(
    id: 'un-4',
    nome: 'Câmara fria — Vacinas',
    produto: 'Imunobiológicos',
    capacidade: '2.400 doses',
    ocupacaoPct: 31,
    status: UnidadeStatus.critico,
    endereco: 'Rua das Indústrias, 88 — Rio Verde/GO',
  ),
];

class ItemEstoque {
  const ItemEstoque({
    required this.id,
    required this.unidadeId,
    required this.produto,
    required this.quantidadeLabel,
    required this.capacidadeLabel,
    required this.ocupacaoPct,
    required this.status,
  });

  final String id;
  final String unidadeId;
  final String produto;
  final String quantidadeLabel;
  final String capacidadeLabel;
  final int ocupacaoPct;
  final UnidadeStatus status;
}

/// Itens armazenados por unidade — granularidade abaixo do agregado de
/// [unidades], usada na aba Estoque (spec D2.1).
const List<ItemEstoque> itensEstoque = [
  ItemEstoque(
    id: 'it-1',
    unidadeId: 'un-1',
    produto: 'Soja em grão',
    quantidadeLabel: '10.080 t',
    capacidadeLabel: '12.000 t',
    ocupacaoPct: 84,
    status: UnidadeStatus.ok,
  ),
  ItemEstoque(
    id: 'it-2',
    unidadeId: 'un-2',
    produto: 'Milho em grão',
    quantidadeLabel: '11.400 t',
    capacidadeLabel: '12.000 t',
    ocupacaoPct: 95,
    status: UnidadeStatus.atencao,
  ),
  ItemEstoque(
    id: 'it-3',
    unidadeId: 'un-3',
    produto: 'Fertilizante NPK',
    quantidadeLabel: '900 t',
    capacidadeLabel: '1.500 t',
    ocupacaoPct: 60,
    status: UnidadeStatus.ok,
  ),
  ItemEstoque(
    id: 'it-4',
    unidadeId: 'un-3',
    produto: 'Defensivos agrícolas',
    quantidadeLabel: '380 t',
    capacidadeLabel: '800 t',
    ocupacaoPct: 48,
    status: UnidadeStatus.ok,
  ),
  ItemEstoque(
    id: 'it-5',
    unidadeId: 'un-3',
    produto: 'Ração bovina',
    quantidadeLabel: '750 t',
    capacidadeLabel: '1.200 t',
    ocupacaoPct: 63,
    status: UnidadeStatus.ok,
  ),
  ItemEstoque(
    id: 'it-6',
    unidadeId: 'un-4',
    produto: 'Vacina febre aftosa',
    quantidadeLabel: '340 doses',
    capacidadeLabel: '1.400 doses',
    ocupacaoPct: 24,
    status: UnidadeStatus.critico,
  ),
  ItemEstoque(
    id: 'it-7',
    unidadeId: 'un-4',
    produto: 'Vacina brucelose',
    quantidadeLabel: '404 doses',
    capacidadeLabel: '1.000 doses',
    ocupacaoPct: 40,
    status: UnidadeStatus.atencao,
  ),
];

enum MovimentacaoTipo { entrada, saida }

class Movimentacao {
  const Movimentacao({
    required this.id,
    required this.tipo,
    required this.item,
    required this.quantidade,
    required this.unidadeId,
    required this.origem,
    required this.destino,
    required this.tempo,
    required this.nota,
    required this.responsavel,
    required this.veiculo,
  });

  final String id;
  final MovimentacaoTipo tipo;
  final String item;

  /// magnitude formatada, sem sinal (ex.: "120 t") — sinal e cor derivam da
  /// direção (Lei 3, nunca só cor).
  final String quantidade;
  final String unidadeId;
  final String origem;
  final String destino;
  final String tempo;
  final String nota;
  final String responsavel;
  final String veiculo;
}

/// Últimas movimentações de entrada e saída registradas no armazém.
const List<Movimentacao> movimentacoes = [
  Movimentacao(
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
  ),
  Movimentacao(
    id: 'mov-2',
    tipo: MovimentacaoTipo.saida,
    item: 'Ração bovina',
    quantidade: '48 sacas',
    unidadeId: 'un-3',
    origem: 'Galpão de insumos',
    destino: 'Fazenda Santa Rita',
    tempo: 'hoje, 06:55',
    nota: 'Reposição programada de arraçoamento do confinamento.',
    responsavel: 'Marina Souza',
    veiculo: 'Caminhão toco · DEF-5678',
  ),
  Movimentacao(
    id: 'mov-3',
    tipo: MovimentacaoTipo.entrada,
    item: 'Fertilizante NPK',
    quantidade: '8 t',
    unidadeId: 'un-3',
    origem: 'NF-e 4795 · Fornecedor Agrovale',
    destino: 'Galpão de insumos',
    tempo: 'ontem, 17:20',
    nota: 'Compra via Marketplace, entrega parcial da NF-e 4795.',
    responsavel: 'Carlos Andrade',
    veiculo: 'Caminhão baú · GHI-9012',
  ),
  Movimentacao(
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
  ),
  Movimentacao(
    id: 'mov-5',
    tipo: MovimentacaoTipo.saida,
    item: 'Milho em grão',
    quantidade: '65 t',
    unidadeId: 'un-2',
    origem: 'Silo 02 — Milho',
    destino: 'Venda · Cliente 1182',
    tempo: 'ontem, 09:30',
    nota: 'Venda spot liquidada, escoamento por carreta graneleira.',
    responsavel: 'Paulo Ribeiro',
    veiculo: 'Carreta graneleira · MNO-7890',
  ),
];

class Alerta {
  const Alerta({required this.id, required this.titulo, required this.detalhe});

  final String id;
  final String titulo;
  final String detalhe;
}

/// Alertas ativos que exigem ação no armazém.
const List<Alerta> alertas = [
  Alerta(
    id: 'al-1',
    titulo: 'Vacina febre aftosa abaixo do mínimo',
    detalhe: 'Estoque atual cobre menos de 5 dias de aplicação prevista.',
  ),
  Alerta(
    id: 'al-2',
    titulo: 'Silo 02 acima de 90% da capacidade',
    detalhe: 'Avaliar escoamento antes da próxima colheita de milho.',
  ),
];

class Relatorio {
  const Relatorio({
    required this.id,
    required this.nome,
    required this.periodo,
    required this.disponivel,
  });

  final String id;
  final String nome;
  final String periodo;
  final bool disponivel;
}

/// Relatórios mockados da aba "Relatórios" (spec D2.5).
const List<Relatorio> relatorios = [
  Relatorio(
    id: 'rel-1',
    nome: 'Ocupação por unidade',
    periodo: 'Julho/2026',
    disponivel: true,
  ),
  Relatorio(
    id: 'rel-2',
    nome: 'Movimentações consolidadas',
    periodo: '2º trimestre 2026',
    disponivel: true,
  ),
  Relatorio(
    id: 'rel-3',
    nome: 'Perdas e quebras de estoque',
    periodo: 'Junho/2026',
    disponivel: false,
  ),
];
