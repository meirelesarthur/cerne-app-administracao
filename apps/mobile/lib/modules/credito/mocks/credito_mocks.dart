/// Mocks do módulo Crédito — espelha `src/modules/credito/mocks/credito.ts`.
/// Determinísticos (sem `DateTime.now`/`Random`) e sem matemática financeira em
/// runtime: os valores de parcela já vêm pré-computados (tabela Price, ~1,3% a.m.)
/// para consumo direto pelas telas.
library;

/// Oferta de crédito pré-aprovado exibida no hero da Home do módulo.
class PreAprovado {
  static const valor = 'R\$ 480.000,00';
  static const validade = 'até 30/09';
  static const taxa = 'a partir de 1,29% a.m.';
}

class SimulacaoOpcao {
  const SimulacaoOpcao({
    required this.valor,
    required this.prazo,
    required this.parcela,
  });

  final String valor;
  final int prazo;
  final String parcela;
}

/// Matriz pré-computada de simulação: 3 valores × 3 prazos (12/24/36 meses).
const List<SimulacaoOpcao> simulacao = [
  SimulacaoOpcao(valor: 'R\$ 100.000', prazo: 12, parcela: 'R\$ 9.054,17'),
  SimulacaoOpcao(valor: 'R\$ 100.000', prazo: 24, parcela: 'R\$ 4.877,22'),
  SimulacaoOpcao(valor: 'R\$ 100.000', prazo: 36, parcela: 'R\$ 3.495,99'),
  SimulacaoOpcao(valor: 'R\$ 250.000', prazo: 12, parcela: 'R\$ 22.635,42'),
  SimulacaoOpcao(valor: 'R\$ 250.000', prazo: 24, parcela: 'R\$ 12.193,05'),
  SimulacaoOpcao(valor: 'R\$ 250.000', prazo: 36, parcela: 'R\$ 8.739,97'),
  SimulacaoOpcao(valor: 'R\$ 480.000', prazo: 12, parcela: 'R\$ 43.460,01'),
  SimulacaoOpcao(valor: 'R\$ 480.000', prazo: 24, parcela: 'R\$ 23.410,66'),
  SimulacaoOpcao(valor: 'R\$ 480.000', prazo: 36, parcela: 'R\$ 16.780,74'),
];

/// Valores disponíveis no simulador (colunas da matriz [simulacao]).
const List<String> valoresSimulacao = [
  'R\$ 100.000',
  'R\$ 250.000',
  'R\$ 480.000',
];

/// Prazos disponíveis no simulador, em meses (linhas da matriz [simulacao]).
const List<int> prazosSimulacao = [12, 24, 36];

class LinhaCredito {
  const LinhaCredito({
    required this.id,
    required this.nome,
    required this.taxa,
    required this.descricao,
  });

  final String id;
  final String nome;
  final String taxa;
  final String descricao;
}

/// Linhas de crédito ofertadas ao produtor.
const List<LinhaCredito> linhas = [
  LinhaCredito(
    id: 'custeio-safra',
    nome: 'Custeio Safra 25/26',
    taxa: '1,29% a.m.',
    descricao:
        'Capital de giro para insumos, sementes e defensivos do ciclo atual.',
  ),
  LinhaCredito(
    id: 'investimento-maquinas',
    nome: 'Investimento — Máquinas',
    taxa: '1,45% a.m.',
    descricao: 'Aquisição de tratores, colheitadeiras e implementos agrícolas.',
  ),
  LinhaCredito(
    id: 'cpr-financeira',
    nome: 'CPR Financeira',
    taxa: '1,19% a.m.',
    descricao:
        'Antecipação de recebíveis com lastro em Cédula de Produto Rural.',
  ),
  LinhaCredito(
    id: 'consorcio-agro',
    nome: 'Consórcio Agro',
    taxa: 'taxa adm 0,12% a.m.',
    descricao:
        'Planejamento de longo prazo para máquinas e equipamentos sem juros.',
  ),
];

/// Status possíveis de uma proposta de crédito — espelha `PropostaStatus`.
enum PropostaStatus { analise, aprovada, recusada, contratada }

/// Documento exigido para análise da proposta.
class DocumentoProposta {
  const DocumentoProposta({required this.nome, required this.enviado});

  final String nome;
  final bool enviado;
}

/// Datas das etapas percorridas pela proposta — alimenta a timeline do detalhe.
class HistoricoProposta {
  const HistoricoProposta({
    required this.enviada,
    this.analise,
    this.decisao,
    this.contratada,
  });

  final String enviada;
  final String? analise;
  final String? decisao;
  final String? contratada;
}

class Proposta {
  const Proposta({
    required this.id,
    required this.linha,
    required this.valor,
    required this.data,
    required this.status,
    required this.prazo,
    required this.taxa,
    required this.historico,
    required this.documentos,
  });

  final String id;
  final String linha;
  final String valor;
  final String data;
  final PropostaStatus status;
  final int prazo;
  final String taxa;
  final HistoricoProposta historico;
  final List<DocumentoProposta> documentos;
}

/// Propostas de crédito em andamento ou concluídas do produtor.
const List<Proposta> propostas = [
  Proposta(
    id: 'prop1',
    linha: 'Custeio Safra 25/26',
    valor: 'R\$ 250.000,00',
    data: '28/06',
    status: PropostaStatus.analise,
    prazo: 12,
    taxa: '1,29% a.m.',
    historico: HistoricoProposta(enviada: '28/06', analise: '29/06'),
    documentos: [
      DocumentoProposta(nome: 'CPF/CNPJ', enviado: true),
      DocumentoProposta(nome: 'Comprovante de renda', enviado: true),
      DocumentoProposta(nome: 'Matrícula do imóvel rural', enviado: false),
    ],
  ),
  Proposta(
    id: 'prop2',
    linha: 'Investimento — Máquinas',
    valor: 'R\$ 180.000,00',
    data: '15/06',
    status: PropostaStatus.aprovada,
    prazo: 24,
    taxa: '1,45% a.m.',
    historico: HistoricoProposta(
      enviada: '15/06',
      analise: '17/06',
      decisao: '20/06',
    ),
    documentos: [
      DocumentoProposta(nome: 'CPF/CNPJ', enviado: true),
      DocumentoProposta(nome: 'Comprovante de renda', enviado: true),
      DocumentoProposta(nome: 'Nota fiscal proforma', enviado: true),
    ],
  ),
  Proposta(
    id: 'prop3',
    linha: 'CPR Financeira',
    valor: 'R\$ 96.500,00',
    data: '02/05',
    status: PropostaStatus.contratada,
    prazo: 24,
    taxa: '1,19% a.m.',
    historico: HistoricoProposta(
      enviada: '02/05',
      analise: '04/05',
      decisao: '08/05',
      contratada: '12/05',
    ),
    documentos: [
      DocumentoProposta(nome: 'CPF/CNPJ', enviado: true),
      DocumentoProposta(nome: 'CPR assinada', enviado: true),
      DocumentoProposta(nome: 'Comprovante de safra', enviado: true),
    ],
  ),
  Proposta(
    id: 'prop4',
    linha: 'Consórcio Agro',
    valor: 'R\$ 120.000,00',
    data: '10/04',
    status: PropostaStatus.recusada,
    prazo: 36,
    taxa: 'taxa adm 0,12% a.m.',
    historico: HistoricoProposta(
      enviada: '10/04',
      analise: '12/04',
      decisao: '18/04',
    ),
    documentos: [
      DocumentoProposta(nome: 'CPF/CNPJ', enviado: true),
      DocumentoProposta(nome: 'Comprovante de renda', enviado: false),
    ],
  ),
];

/// Contrato de crédito ativo — origem de uma proposta contratada.
class Contrato {
  const Contrato({
    required this.id,
    required this.linha,
    required this.valor,
    required this.parcelasPagas,
    required this.parcelasTotal,
    required this.proximaParcela,
    required this.vencimento,
    required this.saldoDevedor,
  });

  final String id;
  final String linha;
  final String valor;
  final int parcelasPagas;
  final int parcelasTotal;
  final String proximaParcela;
  final String vencimento;
  final String saldoDevedor;
}

/// Contratos ativos do produtor (parcelas pré-computadas — ver nota acima).
const List<Contrato> contratos = [
  Contrato(
    id: 'contrato1',
    linha: 'CPR Financeira',
    valor: 'R\$ 96.500,00',
    parcelasPagas: 8,
    parcelasTotal: 24,
    proximaParcela: 'R\$ 4.520,33',
    vencimento: '05/08',
    saldoDevedor: 'R\$ 68.220,17',
  ),
  Contrato(
    id: 'contrato2',
    linha: 'Custeio Safra 24/25',
    valor: 'R\$ 150.000,00',
    parcelasPagas: 11,
    parcelasTotal: 12,
    proximaParcela: 'R\$ 13.187,50',
    vencimento: '20/07',
    saldoDevedor: 'R\$ 13.187,50',
  ),
];
