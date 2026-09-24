import 'models.dart';

/// Catálogos demonstrativos que alimentam o formulário completo de OS.
///
/// No produto real essas opções vêm dos cadastros da fazenda. O protótipo
/// guarda aqui uma fonte única para as listas e suas relações em cascata.
const operacoesAgricolasOs = <String>[
  'Preparo do Solo',
  'Plantio',
  'Adubação',
  'Tratos Culturais',
  'Tratos Fitossanitários',
  'Irrigação',
  'Colheita',
  'Pós Colheita',
  'Armazenagem',
  'Conservação do Solo',
  'Transporte Agrícola',
  'Análise de Solo',
  'Poda e Condução',
  'Roçada',
  'Manutenção Agrícola',
];

const operacoesPecuariasOs = <String>[
  'Alimentação Animal',
  'Manejo Sanitário',
  'Manejo Reprodutivo',
  'Manejo de Rebanho',
  'Ordenha',
];

const operacoesComunsOs = <String>[
  'Manutenção de Infraestrutura',
  'Limpeza e Conservação',
  'Transporte Interno',
];

/// A agricultura não oferece as cinco operações exclusivas da pecuária.
const operacoesPorUso = <UsoOs, List<String>>{
  UsoOs.agricultura: [
    ...operacoesAgricolasOs,
    ...operacoesComunsOs,
  ],
  UsoOs.pecuaria: [
    ...operacoesPecuariasOs,
    ...operacoesComunsOs,
  ],
  UsoOs.ambos: [
    ...operacoesAgricolasOs,
    ...operacoesPecuariasOs,
    ...operacoesComunsOs,
  ],
};

/// Relação operação → atividades. As opções são estáticas e mantêm o par
/// válido ao trocar de operação.
const atividadesPorOperacao = <String, List<String>>{
  'Preparo do Solo': [
    'Aração',
    'Gradagem Aradora',
    'Subsolagem',
    'Calagem',
    'Nivelamento',
  ],
  'Plantio': ['Plantio Mecanizado', 'Plantio Manual', 'Semeadura a Lanço'],
  'Adubação': [
    'Adubação de Base',
    'Adubação de Cobertura',
    'Adubação Foliar',
  ],
  'Tratos Culturais': [
    'Capina Mecanizada',
    'Roçagem',
    'Desbaste',
    'Replantio',
  ],
  'Tratos Fitossanitários': [
    'Aplicação de Herbicida',
    'Aplicação de Fungicida',
    'Aplicação de Inseticida',
    'Pulverização Mecanizada',
  ],
  'Irrigação': ['Irrigação por Aspersão', 'Irrigação por Pivô', 'Reparo de Irrigação'],
  'Colheita': ['Colheita Mecanizada', 'Colheita Manual', 'Recolhimento de Grãos'],
  'Pós Colheita': ['Secagem', 'Classificação de Produto', 'Beneficiamento'],
  'Armazenagem': ['Recebimento', 'Secagem', 'Classificação de Produto'],
  'Conservação do Solo': ['Curva de Nível', 'Subsolagem', 'Cobertura Vegetal'],
  'Transporte Agrícola': ['Transporte de Insumos', 'Transporte de Safra'],
  'Análise de Solo': ['Coleta de Amostra', 'Correção do Solo'],
  'Poda e Condução': ['Poda de Formação', 'Poda de Produção', 'Amarração'],
  'Roçada': ['Roçada Manual', 'Roçada Mecanizada'],
  'Manutenção Agrícola': ['Revisão de Máquinas', 'Reparo de Implementos'],
  'Alimentação Animal': ['Distribuição de Ração', 'Fornecimento de Sal Mineral'],
  'Manejo Sanitário': [
    'Vacinação',
    'Vermifugação',
    'Aplicação de Medicamentos',
    'Inspeção Sanitária',
  ],
  'Manejo Reprodutivo': ['Inseminação', 'Diagnóstico de Gestação', 'Estação de Monta'],
  'Manejo de Rebanho': [
    'Transferência de Lote',
    'Apartação',
    'Pesagem',
    'Identificação Animal',
  ],
  'Ordenha': ['Ordenha Mecânica', 'Higienização de Equipamento', 'Resfriamento do Leite'],
  'Manutenção de Infraestrutura': [
    'Reparo de Cerca',
    'Manutenção de Curral',
    'Reparo de Estradas',
  ],
  'Limpeza e Conservação': ['Limpeza de Curral', 'Limpeza de Galpão', 'Desinfecção'],
  'Transporte Interno': ['Deslocamento de Equipamento', 'Movimentação de Carga'],
};

List<String> atividadesParaOperacao(String? operacao) =>
    atividadesPorOperacao[operacao] ?? const <String>[];

class AreaOsCadastro {
  const AreaOsCadastro({required this.nome, required this.hectares});

  final String nome;
  final num hectares;
}

const areasOs = <AreaOsCadastro>[
  AreaOsCadastro(nome: 'Talhão 01 — Sede', hectares: 42.4),
  AreaOsCadastro(nome: 'Talhão 02 — Lavoura Norte', hectares: 65.3),
  AreaOsCadastro(nome: 'Talhão 03 — Milho Safrinha', hectares: 38.4),
  AreaOsCadastro(nome: 'Gleba Café 01', hectares: 31.8),
  AreaOsCadastro(nome: 'Pasto 04 — Recria', hectares: 74),
  AreaOsCadastro(nome: 'Piquete 12 — Maternidade', hectares: 18.6),
  AreaOsCadastro(nome: 'Curral 02', hectares: 1.2),
  AreaOsCadastro(nome: 'Galpão de Máquinas', hectares: 0.4),
];

class CulturaVariedadeOsCadastro {
  const CulturaVariedadeOsCadastro({
    required this.cultura,
    required this.variedade,
  });

  final String cultura;
  final String variedade;

  String get rotulo => '$cultura — $variedade';
}

const culturasVariedadesOs = <CulturaVariedadeOsCadastro>[
  CulturaVariedadeOsCadastro(cultura: 'Soja', variedade: 'TMG 2383'),
  CulturaVariedadeOsCadastro(cultura: 'Soja', variedade: 'Bônus IPRO'),
  CulturaVariedadeOsCadastro(cultura: 'Milho', variedade: 'DKB 360 PRO3'),
  CulturaVariedadeOsCadastro(cultura: 'Milho', variedade: 'AG 8700'),
  CulturaVariedadeOsCadastro(cultura: 'Café', variedade: 'Catuaí Vermelho 144'),
  CulturaVariedadeOsCadastro(cultura: 'Cana-de-açúcar', variedade: 'RB867515'),
  CulturaVariedadeOsCadastro(cultura: 'Braquiária', variedade: 'Marandu'),
];

class LoteOsCadastro {
  const LoteOsCadastro({
    required this.nome,
    required this.especie,
    required this.categoria,
    required this.quantidade,
  });

  final String nome;
  final String especie;
  final String categoria;
  final int quantidade;
}

const lotesOs = <LoteOsCadastro>[
  LoteOsCadastro(
    nome: 'Lote 12 — Recria',
    especie: 'Bovinos',
    categoria: 'Novilhas',
    quantidade: 128,
  ),
  LoteOsCadastro(
    nome: 'Lote 04 — Engorda',
    especie: 'Bovinos',
    categoria: 'Machos',
    quantidade: 96,
  ),
  LoteOsCadastro(
    nome: 'Lote 19 — Matrizes',
    especie: 'Bovinos',
    categoria: 'Vacas',
    quantidade: 84,
  ),
  LoteOsCadastro(
    nome: 'Lote 07 — Terminação',
    especie: 'Suínos',
    categoria: 'Terminação',
    quantidade: 240,
  ),
  LoteOsCadastro(
    nome: 'Lote 02 — Poedeiras',
    especie: 'Aves',
    categoria: 'Poedeiras',
    quantidade: 850,
  ),
];

class CategoriaZootecnicaOsCadastro {
  const CategoriaZootecnicaOsCadastro({
    required this.especie,
    required this.categoria,
  });

  final String especie;
  final String categoria;

  String get rotulo => '$especie — $categoria';
}

const categoriasZootecnicasOs = <CategoriaZootecnicaOsCadastro>[
  CategoriaZootecnicaOsCadastro(especie: 'Bovinos', categoria: 'Bezerros'),
  CategoriaZootecnicaOsCadastro(especie: 'Bovinos', categoria: 'Novilhas'),
  CategoriaZootecnicaOsCadastro(especie: 'Bovinos', categoria: 'Machos'),
  CategoriaZootecnicaOsCadastro(especie: 'Bovinos', categoria: 'Vacas'),
  CategoriaZootecnicaOsCadastro(especie: 'Bovinos', categoria: 'Touros'),
  CategoriaZootecnicaOsCadastro(especie: 'Suínos', categoria: 'Matrizes'),
  CategoriaZootecnicaOsCadastro(especie: 'Suínos', categoria: 'Terminação'),
  CategoriaZootecnicaOsCadastro(especie: 'Aves', categoria: 'Poedeiras'),
  CategoriaZootecnicaOsCadastro(especie: 'Aves', categoria: 'Frangos de corte'),
];

const categoriasPorEspecieOs = <String, List<String>>{
  'Bovinos': ['Bezerros', 'Novilhas', 'Novilhos', 'Machos', 'Vacas', 'Touros'],
  'Suínos': ['Matrizes', 'Terminação'],
  'Aves': ['Poedeiras', 'Frangos de corte'],
};

class ResponsavelOsCadastro {
  const ResponsavelOsCadastro({required this.nome, required this.funcao});

  final String nome;
  final String funcao;
}

const responsaveisOs = <ResponsavelOsCadastro>[
  ResponsavelOsCadastro(nome: 'João Oliveira', funcao: 'Gerente de fazenda'),
  ResponsavelOsCadastro(nome: 'Maria Souza', funcao: 'Técnica agrícola'),
  ResponsavelOsCadastro(nome: 'Carlos Dias', funcao: 'Supervisor de campo'),
  ResponsavelOsCadastro(nome: 'Ana Costa', funcao: 'Médica veterinária'),
  ResponsavelOsCadastro(nome: 'Pedro Almeida', funcao: 'Encarregado de produção'),
];

class ExecutorMaoDeObraOsCadastro {
  const ExecutorMaoDeObraOsCadastro({
    required this.nome,
    required this.tipo,
    this.funcao,
    this.custoHora,
  });

  final String nome;
  final TipoMaoDeObraOs tipo;
  final String? funcao;
  final num? custoHora;
}

const executoresMaoDeObraOs = <ExecutorMaoDeObraOsCadastro>[
  ExecutorMaoDeObraOsCadastro(
    nome: 'João Oliveira',
    tipo: TipoMaoDeObraOs.funcionario,
    funcao: 'Tratorista Agrícola',
    custoHora: 28.5,
  ),
  ExecutorMaoDeObraOsCadastro(
    nome: 'Maria Souza',
    tipo: TipoMaoDeObraOs.funcionario,
    funcao: 'Técnica Agrícola',
    custoHora: 42,
  ),
  ExecutorMaoDeObraOsCadastro(
    nome: 'Carlos Dias',
    tipo: TipoMaoDeObraOs.funcionario,
    funcao: 'Operador de Máquinas',
    custoHora: 32,
  ),
  ExecutorMaoDeObraOsCadastro(
    nome: 'Trabalhador Rural',
    tipo: TipoMaoDeObraOs.funcao,
    custoHora: 14.2,
  ),
  ExecutorMaoDeObraOsCadastro(
    nome: 'Tratorista Agrícola',
    tipo: TipoMaoDeObraOs.funcao,
    custoHora: 26,
  ),
  ExecutorMaoDeObraOsCadastro(
    nome: 'Operador de Máquinas',
    tipo: TipoMaoDeObraOs.funcao,
    custoHora: 30,
  ),
  ExecutorMaoDeObraOsCadastro(
    nome: 'Agro Serviços Cerrado',
    tipo: TipoMaoDeObraOs.fornecedor,
    custoHora: 95,
  ),
  ExecutorMaoDeObraOsCadastro(
    nome: 'Pulverização Horizonte',
    tipo: TipoMaoDeObraOs.fornecedor,
    custoHora: 180,
  ),
];

List<ExecutorMaoDeObraOsCadastro> executoresPorTipoMaoDeObraOs(
  TipoMaoDeObraOs? tipo,
) => [
  for (final executor in executoresMaoDeObraOs)
    if (tipo == null || executor.tipo == tipo) executor,
];

class EquipamentoOsCadastro {
  const EquipamentoOsCadastro({
    required this.nome,
    required this.tipo,
    required this.unidadeUso,
    this.custoPorUnidade,
  });

  final String nome;
  final String tipo;
  final String unidadeUso;
  final num? custoPorUnidade;
}

const equipamentosOs = <EquipamentoOsCadastro>[
  EquipamentoOsCadastro(
    nome: 'Trator John Deere 6110',
    tipo: 'Máquina',
    unidadeUso: 'Hora',
    custoPorUnidade: 185,
  ),
  EquipamentoOsCadastro(
    nome: 'Colheitadeira CR7',
    tipo: 'Máquina',
    unidadeUso: 'Hora',
    custoPorUnidade: 620,
  ),
  EquipamentoOsCadastro(
    nome: 'Pulverizador Autopropelido',
    tipo: 'Máquina',
    unidadeUso: 'Hora',
    custoPorUnidade: 240,
  ),
  EquipamentoOsCadastro(
    nome: 'Grade Aradora',
    tipo: 'Implemento',
    unidadeUso: 'Hora',
    custoPorUnidade: 60,
  ),
  EquipamentoOsCadastro(
    nome: 'Caminhão Boiadeiro',
    tipo: 'Veículo',
    unidadeUso: 'km',
    custoPorUnidade: 4.8,
  ),
  EquipamentoOsCadastro(
    nome: 'Retroescavadeira',
    tipo: 'Máquina',
    unidadeUso: 'Hora',
    custoPorUnidade: 210,
  ),
];

class ProdutoEstoqueOsCadastro {
  const ProdutoEstoqueOsCadastro({
    required this.produto,
    required this.armazem,
    required this.unidade,
    required this.saldo,
  });

  final String produto;
  final String armazem;
  final String unidade;
  final num saldo;
}

const itensEstoqueOs = <ProdutoEstoqueOsCadastro>[
  ProdutoEstoqueOsCadastro(
    produto: 'Fertilizante NPK 20-05-20',
    armazem: 'Depósito B',
    unidade: 'kg',
    saldo: 22000,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Semente de Soja TMG 2383',
    armazem: 'Depósito B',
    unidade: 'kg',
    saldo: 9600,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Semente de Braquiária',
    armazem: 'Depósito B',
    unidade: 'kg',
    saldo: 1200,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Herbicida Glifosato 480 SL',
    armazem: 'Armazém A',
    unidade: 'L',
    saldo: 640,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Fungicida Azoxistrobina',
    armazem: 'Armazém A',
    unidade: 'L',
    saldo: 85,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Ração Engorda 18%',
    armazem: 'Armazém A',
    unidade: 'kg',
    saldo: 12400,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Sal Mineral Proteinado',
    armazem: 'Armazém A',
    unidade: 'kg',
    saldo: 3150,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Vacina Aftosa',
    armazem: 'Farmácia',
    unidade: 'Unidade',
    saldo: 500,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Vermífugo Injetável',
    armazem: 'Farmácia',
    unidade: 'L',
    saldo: 18,
  ),
  ProdutoEstoqueOsCadastro(
    produto: 'Diesel S10',
    armazem: 'Tanque Diesel',
    unidade: 'L',
    saldo: 14800,
  ),
];

List<String> get armazensInsumosOs => [
  for (final nome in itensEstoqueOs.map((item) => item.armazem).toSet()) nome,
];

List<ProdutoEstoqueOsCadastro> produtosComSaldoOs(String? armazem) => [
  for (final item in itensEstoqueOs)
    if (item.armazem == armazem && item.saldo > 0) item,
];

ProdutoEstoqueOsCadastro? produtoEstoqueOs(String? armazem, String? produto) {
  for (final item in itensEstoqueOs) {
    if (item.armazem == armazem && item.produto == produto) return item;
  }
  return null;
}

class ProdutoProducaoOsCadastro {
  const ProdutoProducaoOsCadastro({
    required this.produto,
    required this.unidade,
  });

  final String produto;
  final String unidade;
}

const armazensProducaoOs = <String>[
  'Armazém de Grãos',
  'Silo 01',
  'Tanque de Leite',
];

const produtosProducaoOs = <ProdutoProducaoOsCadastro>[
  ProdutoProducaoOsCadastro(produto: 'Soja em grão', unidade: 'Saca'),
  ProdutoProducaoOsCadastro(produto: 'Milho em grão', unidade: 'Saca'),
  ProdutoProducaoOsCadastro(produto: 'Leite resfriado', unidade: 'L'),
  ProdutoProducaoOsCadastro(produto: 'Café beneficiado', unidade: 'Saca'),
  ProdutoProducaoOsCadastro(produto: 'Bezerro desmamado', unidade: 'Cabeça'),
];

const produtosPorArmazemProducaoOs = <String, List<String>>{
  'Armazém de Grãos': ['Soja em grão', 'Milho em grão'],
  'Silo 01': ['Soja em grão', 'Milho em grão', 'Café beneficiado'],
  'Tanque de Leite': ['Leite resfriado'],
};

const episOs = <String>[
  'Luvas nitrílicas',
  'Óculos de proteção',
  'Respirador semifacial',
  'Macacão impermeável',
  'Bota de segurança',
  'Capacete com jugular',
  'Protetor auricular',
  'Avental impermeável',
];

AreaOsCadastro? areaOsPorNome(String? nome) {
  for (final area in areasOs) {
    if (area.nome == nome) return area;
  }
  return null;
}

CulturaVariedadeOsCadastro? culturaVariedadeOsPorRotulo(String? rotulo) {
  for (final item in culturasVariedadesOs) {
    if (item.rotulo == rotulo) return item;
  }
  return null;
}

LoteOsCadastro? loteOsPorNome(String? nome) {
  for (final lote in lotesOs) {
    if (lote.nome == nome) return lote;
  }
  return null;
}

ExecutorMaoDeObraOsCadastro? executorMaoDeObraOsPorNome(
  TipoMaoDeObraOs? tipo,
  String? nome,
) {
  for (final executor in executoresMaoDeObraOs) {
    if (executor.tipo == tipo && executor.nome == nome) return executor;
  }
  return null;
}

EquipamentoOsCadastro? equipamentoOsPorNome(String? nome) {
  for (final equipamento in equipamentosOs) {
    if (equipamento.nome == nome) return equipamento;
  }
  return null;
}
