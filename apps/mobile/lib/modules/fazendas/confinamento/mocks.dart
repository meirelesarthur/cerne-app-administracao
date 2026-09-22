/// Mocks determinísticos do submódulo Confinamento — sem `DateTime.now()`,
/// mesmo padrão de `mocks/dashboards_mocks.dart`. Cobre o exemplo real citado
/// na própria especificação funcional (plano "Inicial": Adaptação 1–15d,
/// Crescimento 16–60d, Engorda 61–120d).
library;

import 'models.dart';

const patios = <Patio>[
  Patio(id: 'pt1', nome: 'Pátio 01'),
  Patio(id: 'pt2', nome: 'Pátio 02'),
];

const setores = <Setor>[
  Setor(id: 'st1', nome: 'Setor A', patioId: 'pt1'),
  Setor(id: 'st2', nome: 'Setor B', patioId: 'pt1'),
  Setor(id: 'st3', nome: 'Setor C', patioId: 'pt2'),
  Setor(id: 'st4', nome: 'Setor D', patioId: 'pt2'),
];

final currais = <CurralInfo>[
  CurralInfo(
    id: 'c1',
    nome: 'Curral 01',
    setorId: 'st1',
    capacidade: 100,
    situacao: CurralSituacao.ocupado,
    dietaAtualId: 'd2',
    indicadores: IndicadoresLote(
      machos: 50,
      femeas: 28,
      pesoMedioAtualKg: 412,
      entrada: DateTime(2026, 6, 10),
      saidaPrevista: DateTime(2026, 10, 8),
      diasConfinamento: 45,
      gmdKg: 1.62,
      gmdPrevistoKg: 1.55,
    ),
  ),
  CurralInfo(
    id: 'c2',
    nome: 'Curral 02',
    setorId: 'st1',
    capacidade: 100,
    situacao: CurralSituacao.ocupado,
    dietaAtualId: 'd2',
    indicadores: IndicadoresLote(
      machos: 60,
      femeas: 35,
      pesoMedioAtualKg: 398,
      entrada: DateTime(2026, 6, 12),
      saidaPrevista: DateTime(2026, 10, 10),
      diasConfinamento: 43,
      gmdKg: 1.41,
      gmdPrevistoKg: 1.55,
    ),
  ),
  CurralInfo(
    id: 'c3',
    nome: 'Curral 03',
    setorId: 'st2',
    capacidade: 100,
    situacao: CurralSituacao.ocupado,
    dietaAtualId: 'd3',
    indicadores: IndicadoresLote(
      machos: 55,
      femeas: 45,
      pesoMedioAtualKg: 470,
      entrada: DateTime(2026, 5, 2),
      saidaPrevista: DateTime(2026, 8, 30),
      diasConfinamento: 89,
      gmdKg: 1.68,
      gmdPrevistoKg: 1.6,
    ),
  ),
  const CurralInfo(
    id: 'c4',
    nome: 'Curral 04',
    setorId: 'st2',
    capacidade: 100,
    situacao: CurralSituacao.vazioSanitario,
  ),
  CurralInfo(
    id: 'c5',
    nome: 'Curral 05',
    setorId: 'st3',
    capacidade: 100,
    situacao: CurralSituacao.ocupado,
    dietaAtualId: 'd1',
    indicadores: IndicadoresLote(
      machos: 40,
      femeas: 20,
      pesoMedioAtualKg: 320,
      entrada: DateTime(2026, 8),
      saidaPrevista: DateTime(2026, 11, 29),
      diasConfinamento: 12,
      gmdKg: 1.2,
      gmdPrevistoKg: 1.3,
    ),
  ),
  const CurralInfo(
    id: 'c6',
    nome: 'Curral 06',
    setorId: 'st3',
    capacidade: 100,
    situacao: CurralSituacao.limpeza,
  ),
  CurralInfo(
    id: 'c7',
    nome: 'Curral 07',
    setorId: 'st4',
    capacidade: 100,
    situacao: CurralSituacao.ocupado,
    dietaAtualId: 'd3',
    indicadores: IndicadoresLote(
      machos: 62,
      femeas: 48,
      pesoMedioAtualKg: 452,
      entrada: DateTime(2026, 5, 15),
      saidaPrevista: DateTime(2026, 9, 12),
      diasConfinamento: 76,
      gmdKg: 1.55,
      gmdPrevistoKg: 1.6,
    ),
  ),
  const CurralInfo(
    id: 'c8',
    nome: 'Curral 08',
    setorId: 'st4',
    capacidade: 100,
    situacao: CurralSituacao.interditado,
  ),
];

const dietas = <Dieta>[
  Dieta(
    id: 'd1',
    produto: 'Dieta Adaptação',
    quantidadeReferencia: 1000,
    unidade: 'kg',
    objetivo: DietaObjetivo.adaptacao,
    ingredientes: [
      Ingrediente(
        produto: 'Silagem de Milho',
        quantidade: 550,
        valorUnitario: 0.42,
        percentualMs: 32,
      ),
      Ingrediente(
        produto: 'Farelo de Soja',
        quantidade: 250,
        valorUnitario: 2.1,
        percentualMs: 88,
      ),
      Ingrediente(
        produto: 'Núcleo Mineral',
        quantidade: 200,
        valorUnitario: 3.4,
        percentualMs: 95,
      ),
    ],
  ),
  Dieta(
    id: 'd2',
    produto: 'Dieta Crescimento',
    quantidadeReferencia: 1000,
    unidade: 'kg',
    objetivo: DietaObjetivo.crescimento,
    ingredientes: [
      Ingrediente(
        produto: 'Silagem de Milho',
        quantidade: 450,
        valorUnitario: 0.42,
        percentualMs: 32,
      ),
      Ingrediente(
        produto: 'Milho Moído',
        quantidade: 350,
        valorUnitario: 1.15,
        percentualMs: 87,
      ),
      Ingrediente(
        produto: 'Núcleo Mineral',
        quantidade: 200,
        valorUnitario: 3.4,
        percentualMs: 95,
      ),
    ],
  ),
  Dieta(
    id: 'd3',
    produto: 'Dieta Engorda',
    quantidadeReferencia: 1000,
    unidade: 'kg',
    objetivo: DietaObjetivo.terminacao,
    ingredientes: [
      Ingrediente(
        produto: 'Milho Moído',
        quantidade: 600,
        valorUnitario: 1.15,
        percentualMs: 87,
      ),
      Ingrediente(
        produto: 'Farelo de Soja',
        quantidade: 180,
        valorUnitario: 2.1,
        percentualMs: 88,
      ),
      Ingrediente(
        produto: 'Núcleo Mineral',
        quantidade: 220,
        valorUnitario: 3.4,
        percentualMs: 95,
      ),
    ],
  ),
];

/// Exemplo real citado na spec §4.2: Adaptação do 1º ao 15º dia, Crescimento
/// do 16º ao 60º, Engorda do 61º ao 120º.
const planoFases = PlanoFases(
  id: 'pf1',
  nome: 'Inicial',
  etapas: [
    EtapaFase(
      ordem: 1,
      dietaId: 'd1',
      regra: RegraTroca.porDias,
      inicio: 1,
      fim: 15,
    ),
    EtapaFase(
      ordem: 2,
      dietaId: 'd2',
      regra: RegraTroca.porDias,
      inicio: 16,
      fim: 60,
    ),
    EtapaFase(
      ordem: 3,
      dietaId: 'd3',
      regra: RegraTroca.porDias,
      inicio: 61,
      fim: 120,
    ),
  ],
);

/// Batelada já pesada (Precisão consultável em Relatórios).
const bateladaConcluida = Batelada(
  id: 'bt1',
  dietaId: 'd2',
  vagaoDestino: 'Vagão Misturador 01',
  quantidadeProduzida: 5000,
  itens: [
    ItemBatelada(
      produto: 'Silagem de Milho',
      armazem: 'Armazém A',
      quantidadePrevista: 2250,
      quantidadeRealizada: 2210,
    ),
    ItemBatelada(
      produto: 'Milho Moído',
      armazem: 'Armazém A',
      quantidadePrevista: 1750,
      quantidadeRealizada: 1780,
    ),
    ItemBatelada(
      produto: 'Núcleo Mineral',
      armazem: 'Armazém B',
      quantidadePrevista: 1000,
      quantidadeRealizada: 995,
    ),
  ],
);

/// Trato diário em andamento — dois currais já concluídos, um pendente.
const tratoDiarioEmAndamento = TratoDiario(
  id: 'td1',
  bateladaId: 'bt1',
  lancamentos: [
    LancamentoCurral(
      curralId: 'c1',
      quantidadePlanejada: 850,
      quantidadeFornecida: 850,
      concluido: true,
    ),
    LancamentoCurral(
      curralId: 'c2',
      quantidadePlanejada: 920,
      quantidadeFornecida: 900,
      concluido: true,
    ),
  ],
);

final leituraCochoRecente = LeituraCocho(
  id: 'lc1',
  dataHora: DateTime(2026, 8, 23, 7, 30),
  responsavel: 'João Oliveira',
  avaliacoes: [
    AvaliacaoCurral(
      curralId: 'c1',
      escore: EscoreCocho.ideal,
      ajusteProximoTratoPct: EscoreCocho.ideal.ajusteSugeridoPct,
      sobrasKg: 4,
      sobrasPct: 2,
      aspecto: AspectoSobras.fresco,
      comportamento: ComportamentoAnimal.calmos,
    ),
    AvaliacaoCurral(
      curralId: 'c2',
      escore: EscoreCocho.sobrasModeradas,
      ajusteProximoTratoPct: EscoreCocho.sobrasModeradas.ajusteSugeridoPct,
      sobrasKg: 62,
      sobrasPct: 9,
      aspecto: AspectoSobras.umido,
      comportamento: ComportamentoAnimal.indiferentes,
      ocorrencias: const [
        Ocorrencia(
          tipo: OcorrenciaTipo.infraestrutura,
          prioridade: OcorrenciaPrioridade.media,
          descricao: 'Bebedouro com vazamento no canto direito do curral.',
        ),
      ],
    ),
    AvaliacaoCurral(
      curralId: 'c3',
      escore: EscoreCocho.sobrasExcessivas,
      ajusteProximoTratoPct: EscoreCocho.sobrasExcessivas.ajusteSugeridoPct,
      sobrasKg: 140,
      sobrasPct: 18,
      aspecto: AspectoSobras.mofado,
      comportamento: ComportamentoAnimal.apaticos,
      ocorrencias: const [
        Ocorrencia(
          tipo: OcorrenciaTipo.animal,
          prioridade: OcorrenciaPrioridade.alta,
          descricao:
              'Dois animais com sinais de apatia e recusa de deslocamento até o cocho.',
        ),
      ],
    ),
  ],
);

/// Ordens criadas pelo ADM no app web (banco compartilhado) — o Operacional só
/// confirma a execução (decisão de perfil confirmada com o time).
const ordensPendentes = <OrdemPendente>[
  OrdemPendente(
    id: 'op1',
    tipo: OrdemTipo.transferenciaLote,
    curralOrigemId: 'c3',
    curralDestinoId: 'c6',
    status: OrdemStatus.pendente,
    observacao: 'Curral 06 liberado da limpeza — mover lote antes da engorda.',
  ),
  OrdemPendente(
    id: 'op2',
    tipo: OrdemTipo.trocaDieta,
    curralOrigemId: 'c5',
    novaDietaId: 'd2',
    status: OrdemStatus.pendente,
    observacao: 'Antecipar troca para Crescimento por recomendação técnica.',
  ),
];
