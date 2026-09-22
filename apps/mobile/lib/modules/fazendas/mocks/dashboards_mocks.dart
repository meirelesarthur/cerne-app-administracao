/// Mocks dos dashboards administrativos de Fazendas (spec §4) — espelha
/// `src/modules/fazendas/mocks/dashboards.ts`. Porta os dados usados pelos
/// dashboards administrativos financeiro, pecuária, ativos, suprimentos, uso
/// e consultas. Determinístico, sem `DateTime.now`.
///
/// Confinamento tem mocks próprios, mais ricos (hierarquia Pátio → Setor →
/// Curral, Dieta, Fases, Batelada, Trato Diário, Leitura de Cocho): ver
/// `../confinamento/mocks.dart`.
library;

/* ---- Financeiro (§4.3) ---- */

class FinanceiroKpis {
  FinanceiroKpis._();

  static const aReceber = 'R\$ 1,82 mi';
  static const aPagar = 'R\$ 940 mil';
  static const atrasados = 'R\$ 128 mil';
  static const investimentos = 'R\$ 350 mil';
}

/// Um mês do resultado (§4.3). Receita e a composição do custo por centro
/// vivem juntas aqui para nada divergir: o custo total do mês, a barra por
/// centro de custo e a coluna empilhada saem todos desta mesma linha.
///
/// Valores em milhares de reais.
class ResultadoMes {
  const ResultadoMes({
    required this.label,
    required this.receita,
    required this.nutricao,
    required this.sanidade,
    required this.maoDeObra,
    required this.manutencao,
    required this.administrativo,
    required this.logistica,
  });

  final String label;
  final double receita;
  final double nutricao;
  final double sanidade;
  final double maoDeObra;
  final double manutencao;
  final double administrativo;
  final double logistica;

  double get custo =>
      nutricao + sanidade + maoDeObra + manutencao + administrativo + logistica;

  double get margem => receita - custo;

  /// Manutenção + administrativo + logística — a cauda que, separada, deixa a
  /// coluna empilhada ilegível.
  double get outros => manutencao + administrativo + logistica;
}

const List<ResultadoMes> resultadoMeses = [
  ResultadoMes(
    label: 'Jan',
    receita: 1820,
    nutricao: 496,
    sanidade: 160,
    maoDeObra: 300,
    manutencao: 103,
    administrativo: 47,
    logistica: 74,
  ),
  ResultadoMes(
    label: 'Fev',
    receita: 1960,
    nutricao: 521,
    sanidade: 168,
    maoDeObra: 315,
    manutencao: 108,
    administrativo: 50,
    logistica: 78,
  ),
  ResultadoMes(
    label: 'Mar',
    receita: 1740,
    nutricao: 458,
    sanidade: 148,
    maoDeObra: 277,
    manutencao: 95,
    administrativo: 43,
    logistica: 69,
  ),
  ResultadoMes(
    label: 'Abr',
    receita: 2280,
    nutricao: 487,
    sanidade: 157,
    maoDeObra: 295,
    manutencao: 101,
    administrativo: 46,
    logistica: 74,
  ),
  ResultadoMes(
    label: 'Mai',
    receita: 2143,
    nutricao: 481,
    sanidade: 155,
    maoDeObra: 291,
    manutencao: 100,
    administrativo: 45,
    logistica: 74,
  ),
  ResultadoMes(
    label: 'Jun',
    receita: 2400,
    nutricao: 462,
    sanidade: 149,
    maoDeObra: 279,
    manutencao: 96,
    administrativo: 44,
    logistica: 70,
  ),
];

/// Categorias da coluna empilhada, na ordem de baixo para cima.
const List<String> resultadoCategorias = [
  'Nutrição',
  'Sanidade',
  'Mão de obra',
  'Outros',
];

/// Item de despesa por centro de custo — consumido por `AppBarChart` (`AppBarDatum`).
class CentroCusto {
  const CentroCusto({required this.label, required this.value});

  final String label;
  final double value;
}

/// Despesa do mês corrente por centro de custo, derivada do último
/// [ResultadoMes] — não é uma segunda tabela de números, é o mesmo mês aberto
/// por centro. Ordenada do maior para o menor, que é como se lê a decisão.
final List<CentroCusto> centrosCusto = () {
  final mes = resultadoMeses.last;
  final itens = [
    CentroCusto(label: 'Nutrição', value: mes.nutricao),
    CentroCusto(label: 'Sanidade', value: mes.sanidade),
    CentroCusto(label: 'Mão de obra', value: mes.maoDeObra),
    CentroCusto(label: 'Manutenção', value: mes.manutencao),
    CentroCusto(label: 'Administrativo', value: mes.administrativo),
    CentroCusto(label: 'Logística', value: mes.logistica),
  ]..sort((a, b) => b.value.compareTo(a.value));
  return List<CentroCusto>.unmodifiable(itens);
}();

/* ---- Cartões de resultado (§4.3) ---- */

/// Cartão do topo do painel Resultado — consumido por `AppDashboardCard`.
class PecuariaFinanceiroItem {
  const PecuariaFinanceiroItem({
    required this.label,
    required this.value,
    required this.delta,
    required this.spark,
  });

  final String label;
  final String value;

  /// Variação percentual contra o mês anterior.
  final double delta;
  final List<double> spark;
}

/// "1100" → "R$ 1,1 mi"; "940" → "R$ 940 mil". Aproximação manual: o projeto
/// não tem `intl` instalado (mesmo padrão já usado em Suprimentos).
String formatMilhares(double milhares) {
  if (milhares.abs() >= 1000) {
    final mi = (milhares / 1000).toStringAsFixed(1).replaceAll('.', ',');
    return 'R\$ $mi mi';
  }
  return 'R\$ ${milhares.toStringAsFixed(0)} mil';
}

double _deltaPct(double atual, double anterior) =>
    anterior == 0 ? 0 : ((atual / anterior) - 1) * 100;

/// Receita, custo e margem do mês corrente — **derivados** de [resultadoMeses].
///
/// Antes eram três literais escritos à mão aqui e repetidos, com os mesmos
/// valores, na Home gerencial. Agora saem da série: o gráfico do painel e os
/// cartões não têm como divergir.
final List<PecuariaFinanceiroItem> pecuariaFinanceiro = () {
  final atual = resultadoMeses.last;
  final anterior = resultadoMeses[resultadoMeses.length - 2];
  return List<PecuariaFinanceiroItem>.unmodifiable([
    PecuariaFinanceiroItem(
      label: 'Receita',
      value: formatMilhares(atual.receita),
      delta: _deltaPct(atual.receita, anterior.receita),
      spark: [for (final m in resultadoMeses) m.receita],
    ),
    PecuariaFinanceiroItem(
      label: 'Custo',
      value: formatMilhares(atual.custo),
      delta: _deltaPct(atual.custo, anterior.custo),
      spark: [for (final m in resultadoMeses) m.custo],
    ),
    PecuariaFinanceiroItem(
      label: 'Margem',
      value: formatMilhares(atual.margem),
      delta: _deltaPct(atual.margem, anterior.margem),
      spark: [for (final m in resultadoMeses) m.margem],
    ),
  ]);
}();

/* ---- Ativos / Depreciação (§4.5) ---- */

enum AtivoEstado { ativo, manutencao }

class Ativo {
  const Ativo({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.ano,
    required this.aquisicaoMil,
    required this.depreciado,
    required this.proximaManutencao,
    required this.estado,
  });

  final String id;
  final String nome;
  final String categoria;

  /// Ano de aquisição do ativo.
  final int ano;

  /// Valor de aquisição em milhares de reais — a fonte numérica do ativo.
  /// `aquisicao` e `valorResidual` são derivados dele; antes eram três strings
  /// escritas à mão que podiam (e podem) divergir entre si.
  final double aquisicaoMil;

  final int depreciado;
  final String proximaManutencao;
  final AtivoEstado estado;

  String get aquisicao => formatMilhares(aquisicaoMil);

  /// Depreciação acumulada, em milhares.
  double get depreciacaoMil => aquisicaoMil * (depreciado / 100);

  /// Valor residual estimado (aquisição − depreciação acumulada).
  double get residualMil => aquisicaoMil - depreciacaoMil;

  String get valorResidual => formatMilhares(residualMil);
}

const List<Ativo> ativos = [
  Ativo(
    id: 'at1',
    nome: 'Trator John Deere 6110',
    categoria: 'Máquinas',
    ano: 2021,
    aquisicaoMil: 380,
    depreciado: 45,
    proximaManutencao: '15/07',
    estado: AtivoEstado.ativo,
  ),
  Ativo(
    id: 'at2',
    nome: 'Colheitadeira CR7',
    categoria: 'Máquinas',
    ano: 2022,
    aquisicaoMil: 620,
    depreciado: 30,
    proximaManutencao: '02/08',
    estado: AtivoEstado.ativo,
  ),
  Ativo(
    id: 'at3',
    nome: 'Caminhão Boiadeiro',
    categoria: 'Veículos',
    ano: 2020,
    aquisicaoMil: 240,
    depreciado: 68,
    proximaManutencao: '20/07',
    estado: AtivoEstado.manutencao,
  ),
  Ativo(
    id: 'at4',
    nome: 'Balança de Curral',
    categoria: 'Equipamentos',
    ano: 2023,
    aquisicaoMil: 45,
    depreciado: 20,
    proximaManutencao: '10/09',
    estado: AtivoEstado.ativo,
  ),
  Ativo(
    id: 'at5',
    nome: 'Pivô de Irrigação',
    categoria: 'Infraestrutura',
    ano: 2019,
    aquisicaoMil: 310,
    depreciado: 55,
    proximaManutencao: '28/08',
    estado: AtivoEstado.manutencao,
  ),
  Ativo(
    id: 'at6',
    nome: 'Pulverizador Autopropelido',
    categoria: 'Máquinas',
    ano: 2022,
    aquisicaoMil: 290,
    depreciado: 38,
    proximaManutencao: '05/08',
    estado: AtivoEstado.ativo,
  ),
];

/// Resumo do patrimônio — **derivado** de [ativos]. Os três valores eram
/// literais e não fechavam com a lista: a soma das aquisições dá 1,88 mi, mas a
/// depreciação acumulada real é ~810 mil, não os 720 mil que estavam escritos.
class AtivosResumo {
  AtivosResumo._();

  static double get totalMil =>
      ativos.fold<double>(0, (sum, a) => sum + a.aquisicaoMil);

  static double get depreciacaoMil =>
      ativos.fold<double>(0, (sum, a) => sum + a.depreciacaoMil);

  static double get liquidoMil => totalMil - depreciacaoMil;

  static String get total => formatMilhares(totalMil);
  static String get depreciacao => formatMilhares(depreciacaoMil);
  static String get liquido => formatMilhares(liquidoMil);
}

/* ---- Suprimentos (§4.4) — status PARCIAL: selo "Dados de exemplo" ---- */

enum CotacaoStatus { cotacao, aprovada, recusada }

enum CotacaoTipo { produto, servico, frete, manutencao }

class Cotacao {
  const Cotacao({
    required this.id,
    required this.fornecedor,
    required this.produto,
    required this.tipo,
    required this.totalValor,
    required this.itens,
    required this.status,
    required this.unidade,
    required this.precoAtual,
    required this.variacao,
    required this.validade,
    required this.historico,
  });

  final String id;
  final String fornecedor;

  /// Produto/serviço cotado — usado no cabeçalho do detalhe.
  final String produto;
  final CotacaoTipo tipo;

  /// Valor total cotado, em reais — fonte numérica; `total` é derivado dele.
  final double totalValor;

  final int itens;
  final CotacaoStatus status;

  /// Unidade de referência do preço unitário (ex.: "saca 40kg", "hora técnica").
  final String unidade;

  /// Preço unitário vigente, já formatado (tabular-nums na exibição).
  final String precoAtual;

  /// Variação percentual frente à cotação anterior; positivo = alta, negativo = queda.
  final double variacao;
  final String validade;

  /// Mini-histórico de preço unitário (3 pontos, mais recente por último).
  final List<double> historico;

  /// "48900" → "R\$ 48.900". Aproximação manual: o projeto não tem `intl`.
  String get total {
    final inteiro = totalValor.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < inteiro.length; i++) {
      if (i > 0 && (inteiro.length - i) % 3 == 0) buffer.write('.');
      buffer.write(inteiro[i]);
    }
    return 'R\$ $buffer';
  }
}

const List<Cotacao> cotacoes = [
  Cotacao(
    id: 'q1',
    fornecedor: 'Agropecuária Vale',
    produto: 'Ração Confinamento',
    tipo: CotacaoTipo.produto,
    totalValor: 48900,
    itens: 12,
    status: CotacaoStatus.aprovada,
    unidade: 'saca 40kg',
    precoAtual: 'R\$ 118,50',
    variacao: -2.4,
    validade: '18/07',
    historico: [124, 121, 118.5],
  ),
  Cotacao(
    id: 'q2',
    fornecedor: 'Nutrição Total',
    produto: 'Sal Mineral',
    tipo: CotacaoTipo.produto,
    totalValor: 132400,
    itens: 8,
    status: CotacaoStatus.cotacao,
    unidade: 'saca 25kg',
    precoAtual: 'R\$ 62,90',
    variacao: 1.8,
    validade: '22/07',
    historico: [60.4, 61.8, 62.9],
  ),
  Cotacao(
    id: 'q3',
    fornecedor: 'TransBoi Logística',
    produto: 'Frete Rodoviário',
    tipo: CotacaoTipo.frete,
    totalValor: 22100,
    itens: 3,
    status: CotacaoStatus.cotacao,
    unidade: 'km rodado',
    precoAtual: 'R\$ 4,35',
    variacao: 3.1,
    validade: '15/07',
    historico: [4.05, 4.2, 4.35],
  ),
  Cotacao(
    id: 'q4',
    fornecedor: 'MecAgro Serviços',
    produto: 'Revisão Hidráulica',
    tipo: CotacaoTipo.manutencao,
    totalValor: 15700,
    itens: 5,
    status: CotacaoStatus.recusada,
    unidade: 'hora técnica',
    precoAtual: 'R\$ 185,00',
    variacao: -5.6,
    validade: '10/07',
    historico: [205, 196, 185],
  ),
  Cotacao(
    id: 'q5',
    fornecedor: 'Veterinária Campo',
    produto: 'Vacina Aftosa (aplicação)',
    tipo: CotacaoTipo.servico,
    totalValor: 9300,
    itens: 4,
    status: CotacaoStatus.aprovada,
    unidade: 'dose',
    precoAtual: 'R\$ 7,80',
    variacao: 0.9,
    validade: '30/07',
    historico: [7.6, 7.7, 7.8],
  ),
  Cotacao(
    id: 'q6',
    fornecedor: 'Sementes Sul',
    produto: 'Semente Braquiária',
    tipo: CotacaoTipo.produto,
    totalValor: 61200,
    itens: 15,
    status: CotacaoStatus.cotacao,
    unidade: 'kg',
    precoAtual: 'R\$ 24,60',
    variacao: -3.5,
    validade: '25/07',
    historico: [26.1, 25.2, 24.6],
  ),
];

/* ---- Análise de Uso (§4.6) ---- */

class UsuarioAtivo {
  const UsuarioAtivo({
    required this.nome,
    required this.ultimoAcesso,
    required this.ativo,
  });

  final String nome;
  final String ultimoAcesso;
  final bool ativo;
}

class FazendaAtividade {
  const FazendaAtividade({
    required this.id,
    required this.nome,
    required this.online,
    required this.usuarios,
  });

  final String id;
  final String nome;
  final int online;
  final List<UsuarioAtivo> usuarios;
}

const List<FazendaAtividade> usoFazendas = [
  FazendaAtividade(
    id: 'f1',
    nome: 'Fazenda São Pedro',
    online: 3,
    usuarios: [
      UsuarioAtivo(nome: 'João Silva', ultimoAcesso: 'há 2 min', ativo: true),
      UsuarioAtivo(nome: 'Maria Souza', ultimoAcesso: 'há 4 min', ativo: true),
      UsuarioAtivo(nome: 'Pedro Alves', ultimoAcesso: 'há 1 min', ativo: true),
      UsuarioAtivo(nome: 'Ana Lima', ultimoAcesso: 'há 3 h', ativo: false),
    ],
  ),
  FazendaAtividade(
    id: 'f2',
    nome: 'Fazenda Santa Rita',
    online: 1,
    usuarios: [
      UsuarioAtivo(nome: 'Carlos Dias', ultimoAcesso: 'há 30 s', ativo: true),
      UsuarioAtivo(nome: 'Rita Nunes', ultimoAcesso: 'ontem', ativo: false),
    ],
  ),
  FazendaAtividade(
    id: 'f3',
    nome: 'Fazenda Boa Vista',
    online: 0,
    usuarios: [
      UsuarioAtivo(nome: 'Luís Prado', ultimoAcesso: 'há 2 dias', ativo: false),
    ],
  ),
];

/* ---- Consultas Gerenciais (§4.7) — read-only ---- */

class LinhaConsulta {
  const LinhaConsulta({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.meta,
  });

  final String id;
  final String titulo;
  final String subtitulo;
  final String meta;
}

const List<LinhaConsulta> lotes = [
  LinhaConsulta(
    id: 'l1',
    titulo: 'Lote 42',
    subtitulo: '128 cabeças · 18.240 kg',
    meta: 'Curral 02',
  ),
  LinhaConsulta(
    id: 'l2',
    titulo: 'Lote 19',
    subtitulo: '96 cabeças · 13.100 kg',
    meta: 'Curral 05',
  ),
  LinhaConsulta(
    id: 'l3',
    titulo: 'Lote 07',
    subtitulo: '150 cabeças · 22.500 kg',
    meta: 'Piquete 3',
  ),
  LinhaConsulta(
    id: 'l4',
    titulo: 'Lote 33',
    subtitulo: '64 cabeças · 9.800 kg',
    meta: 'Curral 01',
  ),
];

const List<LinhaConsulta> estoque = [
  LinhaConsulta(
    id: 'e1',
    titulo: 'Ração Engorda',
    subtitulo: 'Armazém A',
    meta: '12.400 kg',
  ),
  LinhaConsulta(
    id: 'e2',
    titulo: 'Sal Mineral',
    subtitulo: 'Armazém A',
    meta: '3.200 kg',
  ),
  LinhaConsulta(
    id: 'e3',
    titulo: 'Vacina Aftosa',
    subtitulo: 'Farmácia',
    meta: '540 doses',
  ),
  LinhaConsulta(
    id: 'e4',
    titulo: 'Herbicida',
    subtitulo: 'Depósito B',
    meta: '180 L',
  ),
];

const List<LinhaConsulta> pesagensDia = [
  LinhaConsulta(
    id: 'p1',
    titulo: 'Lote 42',
    subtitulo: '128 cabeças · 142 kg/cab',
    meta: '07:12',
  ),
  LinhaConsulta(
    id: 'p2',
    titulo: 'Lote 19',
    subtitulo: '96 cabeças · 136 kg/cab',
    meta: '08:03',
  ),
  LinhaConsulta(
    id: 'p3',
    titulo: 'Lote 07',
    subtitulo: '150 cabeças · 150 kg/cab',
    meta: '09:20',
  ),
];
