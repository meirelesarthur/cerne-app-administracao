/// Contrato de domínio do submódulo Confinamento (Cadastro + Nutrição), a
/// partir de `Especificacao_Funcional_Confinamento_AGRO365.docx` (ago/2026) e
/// do artefato de decisão por perfil ("Confinamento por Perfil").
///
/// Divisão de responsabilidade confirmada com o time:
/// - ADM enxerga só leitura (um único dashboard, `admin/dash_confinamento.dart`)
///   — cadastros (Pátio/Setor/Curral, Dieta, Fases) são feitos pelo app **web**,
///   que divide o mesmo banco; o app mobile nunca cria/edita essas entidades.
/// - Operacional lança o que acontece em campo (situação do curral, batelada,
///   trato diário, leitura de cocho, pesagem, sanitário, óbito) e confirma
///   ordens que o ADM já criou no web (transferência de lote, troca de dieta) —
///   nunca decide essas duas ações livremente.
///
/// Cada model comenta a tabela real equivalente, quando mapeada em
/// `docs/ajustes-banco-real/01-mapa-catalogo-banco.md`.
library;

/// Espelha `feedlot_corrals.status` — estado operacional do curral (spec §3.3).
enum CurralSituacao {
  vazio,
  vazioSanitario,
  ocupado,
  manutencao,
  limpeza,
  enfermaria,
  interditado,
}

extension CurralSituacaoLabel on CurralSituacao {
  String get label => switch (this) {
    CurralSituacao.vazio => 'Vazio',
    CurralSituacao.vazioSanitario => 'Vazio sanitário',
    CurralSituacao.ocupado => 'Ocupado',
    CurralSituacao.manutencao => 'Manutenção',
    CurralSituacao.limpeza => 'Limpeza',
    CurralSituacao.enfermaria => 'Enfermaria',
    CurralSituacao.interditado => 'Interditado',
  };

  /// Situações que carregam uma data de "Liberação em" (spec §3.3).
  bool get temLiberacaoPrevista => this != CurralSituacao.ocupado;
}

/// Pátio — maior divisão física do confinamento. Espelha `feedlot_yards`.
class Patio {
  const Patio({required this.id, required this.nome});

  final String id;
  final String nome;
}

/// Setor — subdivisão de um Pátio. Espelha `feedlot_sectors`.
class Setor {
  const Setor({required this.id, required this.nome, required this.patioId});

  final String id;
  final String nome;
  final String patioId;
}

/// Indicadores do lote alocado num curral, exibidos no Mapa (spec §4.6).
/// Calculados a partir do lote e do histórico de pesagens — nenhum campo é
/// digitado diretamente aqui.
class IndicadoresLote {
  const IndicadoresLote({
    required this.machos,
    required this.femeas,
    required this.pesoMedioAtualKg,
    required this.entrada,
    required this.saidaPrevista,
    required this.diasConfinamento,
    required this.gmdKg,
    required this.gmdPrevistoKg,
  });

  final int machos;
  final int femeas;
  final double pesoMedioAtualKg;
  final DateTime entrada;
  final DateTime saidaPrevista;
  final int diasConfinamento;
  final double gmdKg;
  final double gmdPrevistoKg;

  int get totalAnimais => machos + femeas;

  int get duracaoDias => saidaPrevista.difference(entrada).inDays;

  int get diasRestantes => (duracaoDias - diasConfinamento).clamp(0, 1 << 30);

  double get pesoPrevistoPosConfinamentoKg =>
      pesoMedioAtualKg + diasRestantes * gmdPrevistoKg;

  /// GMD observado ÷ GMD previsto, em %.
  int get indicadorDesempenhoPct =>
      gmdPrevistoKg == 0 ? 0 : ((gmdKg / gmdPrevistoKg) * 100).round();
}

/// Curral — unidade operacional central (spec §3.3 + §4.6). Espelha
/// `feedlot_corrals`; capacidade/ocupação alimentam `feedlot_corral_batches`.
class CurralInfo {
  const CurralInfo({
    required this.id,
    required this.nome,
    required this.setorId,
    required this.capacidade,
    required this.situacao,
    this.liberacaoEm,
    this.dietaAtualId,
    this.indicadores,
  });

  final String id;
  final String nome;
  final String setorId;
  final int capacidade;
  final CurralSituacao situacao;
  final DateTime? liberacaoEm;
  final String? dietaAtualId;
  final IndicadoresLote? indicadores;

  bool get ocupado => situacao == CurralSituacao.ocupado;

  int get ocupacaoAtual => indicadores?.totalAnimais ?? 0;

  CurralInfo copyWith({
    CurralSituacao? situacao,
    DateTime? liberacaoEm,
    bool clearLiberacao = false,
    String? dietaAtualId,
    IndicadoresLote? indicadores,
    bool clearIndicadores = false,
  }) {
    return CurralInfo(
      id: id,
      nome: nome,
      setorId: setorId,
      capacidade: capacidade,
      situacao: situacao ?? this.situacao,
      liberacaoEm: clearLiberacao ? null : (liberacaoEm ?? this.liberacaoEm),
      dietaAtualId: dietaAtualId ?? this.dietaAtualId,
      indicadores: clearIndicadores ? null : (indicadores ?? this.indicadores),
    );
  }
}

/// Ingrediente de uma Dieta (spec §4.1). Espelha `ingredients`.
class Ingrediente {
  const Ingrediente({
    required this.produto,
    required this.quantidade,
    required this.valorUnitario,
    required this.percentualMs,
  });

  final String produto;
  final double quantidade;
  final double valorUnitario;

  /// % de Matéria Seca — usada na Média MS não ponderada (spec §4.1).
  final double percentualMs;

  double get valorTotal => quantidade * valorUnitario;
}

enum DietaObjetivo { adaptacao, crescimento, terminacao }

extension DietaObjetivoLabel on DietaObjetivo {
  String get label => switch (this) {
    DietaObjetivo.adaptacao => 'Adaptação',
    DietaObjetivo.crescimento => 'Crescimento',
    DietaObjetivo.terminacao => 'Terminação',
  };
}

/// Dieta — fórmula nutricional (spec §4.1). Espelha `diets` (cabeçalho) +
/// `ingredients` (itens); `custoPorKg`/`custoTotalEstimado` já existem como
/// colunas reais (`diets.cost_per_kg`/`diets.estimated_cost`).
class Dieta {
  const Dieta({
    required this.id,
    required this.produto,
    required this.quantidadeReferencia,
    required this.unidade,
    required this.objetivo,
    required this.ingredientes,
  });

  final String id;
  final String produto;
  final double quantidadeReferencia;
  final String unidade;
  final DietaObjetivo objetivo;
  final List<Ingrediente> ingredientes;

  double get pesoTotalMistura =>
      ingredientes.fold(0, (s, i) => s + i.quantidade);

  double get custoTotalEstimado =>
      ingredientes.fold(0, (s, i) => s + i.valorTotal);

  double get custoPorKg =>
      pesoTotalMistura == 0 ? 0 : custoTotalEstimado / pesoTotalMistura;

  /// Média aritmética simples do %MS — deliberadamente **não** ponderada
  /// pela quantidade de cada ingrediente (regra de negócio explícita, spec §4.1).
  double get mediaMsPct => ingredientes.isEmpty
      ? 0
      : ingredientes.fold<double>(0, (s, i) => s + i.percentualMs) /
            ingredientes.length;
}

enum RegraTroca { porDias, porPeso }

/// Etapa de um plano de Fases/Regras de Troca (spec §4.2).
///
/// LACUNA (premissa de protótipo): não existe tabela real para o plano de
/// fases no dump mapeado (`docs/ajustes-banco-real/01-mapa-catalogo-banco.md`
/// não cita nenhuma) — tratado como configuração só de leitura no app mobile,
/// igual às demais entidades de Nutrição/Cadastro (mantida pelo web).
class EtapaFase {
  const EtapaFase({
    required this.ordem,
    required this.dietaId,
    required this.regra,
    required this.inicio,
    required this.fim,
  });

  final int ordem;
  final String dietaId;
  final RegraTroca regra;

  /// Dias (RegraTroca.porDias) ou kg (RegraTroca.porPeso).
  final num inicio;
  final num fim;
}

class PlanoFases {
  const PlanoFases({
    required this.id,
    required this.nome,
    required this.etapas,
  });

  final String id;
  final String nome;
  final List<EtapaFase> etapas;
}

/// Item de uma Batelada — previsto × realizado por ingrediente (spec §4.3).
/// Espelha `item_diet_beats` (`quantity`/`quantity_realized`).
class ItemBatelada {
  const ItemBatelada({
    required this.produto,
    required this.armazem,
    required this.quantidadePrevista,
    this.quantidadeRealizada,
    this.dryMatter,
    this.custoValor,
    this.percentual,
  });

  final String produto;
  final String armazem;
  final double quantidadePrevista;
  final double? quantidadeRealizada;

  /// `item_diet_beats.dry_matter` — %MS do ingrediente, derivado da dieta
  /// (required no contrato `DietBeatRequest`, transportado no payload).
  final double? dryMatter;

  /// `item_diet_beats.cost_value` — custo unitário do ingrediente, derivado da
  /// dieta (required no contrato).
  final double? custoValor;

  /// `item_diet_beats.percentage` — proporção do ingrediente na dieta,
  /// derivada da quantidade de referência (required no contrato).
  final double? percentual;

  /// % de desvio entre realizado e previsto; `null` enquanto não pesado.
  double? get diferencaPct => quantidadeRealizada == null
      ? null
      : quantidadePrevista == 0
      ? 0
      : ((quantidadeRealizada! - quantidadePrevista) / quantidadePrevista) *
            100;
}

/// Batelada — produção física da mistura (spec §4.3). Espelha `diet_beats` +
/// `item_diet_beats`.
class Batelada {
  const Batelada({
    required this.id,
    required this.dietaId,
    required this.vagaoDestino,
    required this.quantidadeProduzida,
    required this.itens,
    this.data,
    this.unidadeMedida,
  });

  final String id;
  final String dietaId;
  final String vagaoDestino;
  final double quantidadeProduzida;
  final List<ItemBatelada> itens;

  /// `diet_beats.date` — data da produção (required no contrato).
  final String? data;

  /// `diet_beats.measurement_uuid` — unidade de medida da produção (required
  /// no contrato).
  final String? unidadeMedida;

  double get pesoPrevisto => itens.fold(0, (s, i) => s + i.quantidadePrevista);

  double get pesoRealizado =>
      itens.fold(0, (s, i) => s + (i.quantidadeRealizada ?? 0));

  /// % do previsto que já foi de fato pesado.
  int get precisaoPct =>
      pesoPrevisto == 0 ? 0 : ((pesoRealizado / pesoPrevisto) * 100).round();
}

/// Fornecimento lançado num curral dentro de um Trato Diário (spec §4.4).
/// Espelha `item_nutritions` (`trough_id`/`feedlot_corral_id` de destino).
class LancamentoCurral {
  const LancamentoCurral({
    required this.curralId,
    required this.quantidadePlanejada,
    this.quantidadeFornecida,
    this.concluido = false,
  });

  final String curralId;
  final double quantidadePlanejada;
  final double? quantidadeFornecida;
  final bool concluido;

  LancamentoCurral copyWith({double? quantidadeFornecida, bool? concluido}) {
    return LancamentoCurral(
      curralId: curralId,
      quantidadePlanejada: quantidadePlanejada,
      quantidadeFornecida: quantidadeFornecida ?? this.quantidadeFornecida,
      concluido: concluido ?? this.concluido,
    );
  }
}

/// Trato Diário — distribuição de uma Batelada entre os currais elegíveis
/// (spec §4.4).
class TratoDiario {
  const TratoDiario({
    required this.id,
    required this.bateladaId,
    required this.lancamentos,
  });

  final String id;
  final String bateladaId;
  final List<LancamentoCurral> lancamentos;

  double get totalFornecido =>
      lancamentos.fold(0, (s, l) => s + (l.quantidadeFornecida ?? 0));

  int get currentConcluidos => lancamentos.where((l) => l.concluido).length;
}

/// Escala de escore de cocho (spec §4.5) — cada valor sugere um % de ajuste
/// automático para o próximo trato, editável pelo avaliador.
enum EscoreCocho {
  vazio,
  sobrasMinimas,
  ideal,
  sobrasModeradas,
  sobrasExcessivas,
  alimentoIntacto,
}

extension EscoreCochoInfo on EscoreCocho {
  double get valor => switch (this) {
    EscoreCocho.vazio => 0,
    EscoreCocho.sobrasMinimas => 0.5,
    EscoreCocho.ideal => 1,
    EscoreCocho.sobrasModeradas => 2,
    EscoreCocho.sobrasExcessivas => 3,
    EscoreCocho.alimentoIntacto => 4,
  };

  String get label => switch (this) {
    EscoreCocho.vazio => '0 — Cocho vazio (animais com fome)',
    EscoreCocho.sobrasMinimas => '0,5 — Sobras mínimas',
    EscoreCocho.ideal => '1 — Ideal',
    EscoreCocho.sobrasModeradas => '2 — Sobras moderadas (5–15%)',
    EscoreCocho.sobrasExcessivas => '3 — Sobras excessivas (>15%)',
    EscoreCocho.alimentoIntacto => '4 — Alimento intacto/deteriorado',
  };

  /// Ajuste sugerido (%) para o próximo trato — premissa funcional do
  /// protótipo, editável pelo avaliador no formulário (spec §4.5, ex.: Escore
  /// 2 sugere -7,5%).
  double get ajusteSugeridoPct => switch (this) {
    EscoreCocho.vazio => 15,
    EscoreCocho.sobrasMinimas => 5,
    EscoreCocho.ideal => 0,
    EscoreCocho.sobrasModeradas => -7.5,
    EscoreCocho.sobrasExcessivas => -15,
    EscoreCocho.alimentoIntacto => -20,
  };
}

enum AspectoSobras {
  fresco,
  umido,
  ressecado,
  mofado,
  selecionado,
  contaminado,
}

enum ComportamentoAnimal {
  calmos,
  agitadosFamintos,
  esperandoNoCocho,
  indiferentes,
  apaticos,
  sinaisDesconforto,
}

enum OcorrenciaTipo { animal, infraestrutura, ambiente, outro }

enum OcorrenciaPrioridade { baixa, media, alta }

extension OcorrenciaPrioridadeLabel on OcorrenciaPrioridade {
  /// Rótulo de tela — o `name` do enum ("media") vazava cru no chip.
  String get label => switch (this) {
    OcorrenciaPrioridade.baixa => 'Baixa',
    OcorrenciaPrioridade.media => 'Média',
    OcorrenciaPrioridade.alta => 'Alta',
  };
}

/// Ocorrência registrada durante a leitura de um curral (spec §4.5).
class Ocorrencia {
  const Ocorrencia({
    required this.tipo,
    required this.prioridade,
    required this.descricao,
    this.fotoPath,
  });

  final OcorrenciaTipo tipo;
  final OcorrenciaPrioridade prioridade;
  final String descricao;
  final String? fotoPath;
}

/// Avaliação de um curral dentro de uma Leitura de Cocho (spec §4.5).
/// Tabela real mais próxima: `feedlot_corral_diet_histories` (curral, dieta,
/// data, consumo) — falta responsável/observação/escore categórico, tratados
/// aqui como premissa de protótipo até alinhamento com o time web.
class AvaliacaoCurral {
  const AvaliacaoCurral({
    required this.curralId,
    required this.escore,
    required this.ajusteProximoTratoPct,
    this.dietaId,
    this.consumoKg,
    this.sobrasKg,
    this.sobrasPct,
    this.aspecto,
    this.comportamento,
    this.observacoes,
    this.ocorrencias = const [],
  });

  final String curralId;
  final EscoreCocho escore;
  final double ajusteProximoTratoPct;

  // fidelidade-esteira (onda 14): `diet_id`/`feed_intake` — o único bloco
  // auditável de `leitura_cocho_flow.dart` (núcleo escore/sobras/aspecto
  // continua sem endpoint real confirmado). Opcionais no model para não
  // quebrar as amostras existentes (`mocks.dart`); a tela de captura exige
  // os dois via validação própria.
  final String? dietaId;
  final double? consumoKg;
  final double? sobrasKg;
  final double? sobrasPct;
  final AspectoSobras? aspecto;
  final ComportamentoAnimal? comportamento;
  final String? observacoes;
  final List<Ocorrencia> ocorrencias;
}

class LeituraCocho {
  const LeituraCocho({
    required this.id,
    required this.dataHora,
    required this.responsavel,
    required this.avaliacoes,
  });

  final String id;
  final DateTime dataHora;
  final String responsavel;
  final List<AvaliacaoCurral> avaliacoes;
}

/// Ordem criada pelo ADM (no app web, que divide o banco com o mobile) para
/// uma ação que a spec marca como compartilhada: o Operacional não decide,
/// só confirma a execução em campo (decisão de perfil confirmada com o time).
enum OrdemTipo { transferenciaLote, trocaDieta }

enum OrdemStatus { pendente, confirmada }

class OrdemPendente {
  const OrdemPendente({
    required this.id,
    required this.tipo,
    required this.curralOrigemId,
    required this.status,
    this.curralDestinoId,
    this.novaDietaId,
    this.observacao,
  });

  final String id;
  final OrdemTipo tipo;
  final String curralOrigemId;

  /// Preenchido só quando `tipo == transferenciaLote`.
  final String? curralDestinoId;

  /// Preenchido só quando `tipo == trocaDieta`.
  final String? novaDietaId;
  final OrdemStatus status;
  final String? observacao;

  OrdemPendente copyWith({OrdemStatus? status}) {
    return OrdemPendente(
      id: id,
      tipo: tipo,
      curralOrigemId: curralOrigemId,
      curralDestinoId: curralDestinoId,
      novaDietaId: novaDietaId,
      status: status ?? this.status,
      observacao: observacao,
    );
  }
}
