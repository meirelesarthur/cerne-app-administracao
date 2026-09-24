/// Contrato de domínio de Ordem de Serviço (OS) — espelha o formulário do
/// WEB (`/admin/service-orders/create`, mapa de campos de 24/09/2026):
/// identificação → tipo de serviço (Uso → Operação → Atividade) → execução
/// (área, cultura, lote, categoria) → condições e restrições → instruções
/// detalhadas → segurança e sustentabilidade → recursos e insumos (5 abas).
///
/// Contrato compartilhado com o app Operação para representar o formulário
/// WEB completo e o ciclo de execução em campo. O ADM também mantém seu fluxo
/// administrativo de criação simplificada, avaliação e cancelamento.
///
/// O Operacional inicia, pausa/retoma e encerra a própria OS (entregue, ou
/// refeita com justificativa). No ADM, a Administração cria a versão
/// simplificada, avalia e pode cancelar enquanto a OS ainda está em andamento.
library;

/// Classificação legada do formulário administrativo simplificado.
/// Os registros completos do WEB usam [UsoOs], [operacao] e [atividade].
enum TipoServicoOs { agricola, pecuario, manutencao, infraestrutura }

extension TipoServicoOsLabel on TipoServicoOs {
  String get label => switch (this) {
    TipoServicoOs.agricola => 'Agrícola',
    TipoServicoOs.pecuario => 'Pecuário',
    TipoServicoOs.manutencao => 'Manutenção',
    TipoServicoOs.infraestrutura => 'Infraestrutura',
  };
}

/// Uso da OS (WEB `category`): define o escopo e quais campos de execução
/// valem — Agricultura usa cultura/variedade; Pecuária usa lote e
/// categoria; Ambos usa os quatro.
enum UsoOs { agricultura, pecuaria, ambos }

extension UsoOsLabel on UsoOs {
  String get label => switch (this) {
    UsoOs.agricultura => 'Agricultura',
    UsoOs.pecuaria => 'Pecuária',
    UsoOs.ambos => 'Ambos',
  };

  bool get usaCultura => this != UsoOs.pecuaria;
  bool get usaLote => this != UsoOs.agricultura;
}

enum PrioridadeOs { baixa, media, alta, urgente }

extension PrioridadeOsLabel on PrioridadeOs {
  String get label => switch (this) {
    PrioridadeOs.baixa => 'Baixa',
    PrioridadeOs.media => 'Média',
    PrioridadeOs.alta => 'Alta',
    PrioridadeOs.urgente => 'Urgente',
  };
}

/// Ciclo de vida da OS. `entregue` e `refeita` são os dois encerramentos que
/// só o Operacional decide; `cancelada` só o escritório decide — e só
/// antes de um desses dois encerramentos.
enum OrdemServicoStatus {
  aguardando,
  emExecucao,
  pausada,
  entregue,
  refeita,
  cancelada,
}

extension OrdemServicoStatusLabel on OrdemServicoStatus {
  String get label => switch (this) {
    OrdemServicoStatus.aguardando => 'Aguardando',
    OrdemServicoStatus.emExecucao => 'Em execução',
    OrdemServicoStatus.pausada => 'Pausada',
    OrdemServicoStatus.entregue => 'Entregue',
    // "Refeita" soava como "já refiz" — é o contrário: o serviço volta.
    OrdemServicoStatus.refeita => 'Precisa refazer',
    OrdemServicoStatus.cancelada => 'Cancelada',
  };

  /// Só nesses três estados o Operacional ainda pode agir (iniciar, pausar,
  /// retomar, entregar, refazer) e o escritório pode cancelar.
  bool get emAndamento =>
      this == OrdemServicoStatus.aguardando ||
      this == OrdemServicoStatus.emExecucao ||
      this == OrdemServicoStatus.pausada;

  bool get encerrada => !emAndamento;
}

/// Checkpoint de qualidade registrado pela Administração enquanto a OS ainda
/// está em andamento. Não altera o ciclo de execução.
class AvaliacaoOs {
  const AvaliacaoOs({
    required this.nota,
    required this.comentario,
    required this.avaliador,
    required this.dataHora,
  });

  final int nota;
  final String comentario;
  final String avaliador;
  final DateTime dataHora;
}

/// Bloco "Condições e Restrições" do WEB — todos obrigatórios lá.
class CondicoesOs {
  const CondicoesOs({
    required this.requisitosClimaticos,
    required this.temperaturaMinima,
    required this.temperaturaMaxima,
    required this.horarioInicio,
    required this.horarioFim,
  });

  final String requisitosClimaticos;

  /// °C.
  final num temperaturaMinima;
  final num temperaturaMaxima;

  /// Horário de execução permitido, "HH:mm".
  final String horarioInicio;
  final String horarioFim;
}

/// Bloco "Instruções Detalhadas" do WEB (a descrição do serviço fica em
/// [OrdemServico.descricao]).
class InstrucoesOs {
  const InstrucoesOs({
    required this.resultadosEsperados,
    required this.criteriosSucesso,
    required this.roteiro,
  });

  final String resultadosEsperados;
  final String criteriosSucesso;

  /// Roteiro/Planejamento — passo a passo do serviço.
  final String roteiro;
}

/// Bloco "Segurança e Sustentabilidade" do WEB.
class SegurancaOs {
  const SegurancaOs({
    required this.restricoesAmbientais,
    required this.conformidadeLegal,
  });

  final String restricoesAmbientais;
  final String conformidadeLegal;
}

// --- Recursos e Insumos ----------------------------------------------------
// As cinco abas do WEB (MO/Serviços, Máq/Implementos, Insumos, Produção,
// Proteções/EPI), com exatamente os campos de cada linha de lá. A tela
// mostra um resumo por linha e o toque abre o item inteiro numa dock.

/// Tipo da linha de MO/Serviços — define de qual cadastro vem o executor.
enum TipoMaoDeObraOs { funcionario, funcao, fornecedor }

extension TipoMaoDeObraOsLabel on TipoMaoDeObraOs {
  String get label => switch (this) {
    TipoMaoDeObraOs.funcionario => 'Funcionário',
    TipoMaoDeObraOs.funcao => 'Função',
    TipoMaoDeObraOs.fornecedor => 'Fornecedor',
  };
}

/// Linha da aba MO/Serviços: Tipo + Executador.
class MaoDeObraOs {
  const MaoDeObraOs({required this.tipo, required this.executor, this.funcao});

  final TipoMaoDeObraOs tipo;

  /// Funcionário, função/cargo ou fornecedor, conforme [tipo].
  final String executor;

  /// Função do funcionário no cadastro (só leitura, não é campo da OS).
  final String? funcao;
}

/// Linha da aba Máq/Implementos: Máq/Equipamento/Veículo + Observação.
class MaquinaOs {
  const MaquinaOs({required this.equipamento, this.observacao});

  final String equipamento;
  final String? observacao;
}

/// Linha da aba Insumos — o armazém é da aba inteira
/// ([OrdemServico.armazemInsumos]) e só lista produtos com saldo nele;
/// `estoque` é o saldo na unidade escolhida (só leitura no WEB).
class InsumoOs {
  const InsumoOs({
    required this.produto,
    required this.unidadeMedida,
    required this.estoque,
    required this.quantidadePorHa,
    required this.quantidadeTotal,
  });

  final String produto;
  final String unidadeMedida;
  final num estoque;
  final num quantidadePorHa;
  final num quantidadeTotal;
}

/// Linha da aba Produção — o que o serviço gera e entra no armazém de
/// produção ([OrdemServico.armazemProducao]). Nada é obrigatório no WEB.
class ProducaoOs {
  const ProducaoOs({
    required this.produto,
    required this.unidadeMedida,
    required this.quantidade,
    this.observacao,
  });

  final String produto;
  final String unidadeMedida;
  final num quantidade;
  final String? observacao;
}

/// Linha da aba Proteções (EPI): Produto + Observação. Não depende de
/// armazém.
class EpiOs {
  const EpiOs({required this.produto, this.observacao});

  final String produto;
  final String? observacao;
}

/// Evidência registrada pelo Operacional durante a execução (spec: "execução
/// em campo com registro de evidências"). Sem upload real no protótipo —
/// `legenda` descreve o que a foto mostraria.
class EvidenciaOs {
  const EvidenciaOs({
    required this.legenda,
    required this.dataHora,
    this.autor,
    this.observacao,
  });

  final String legenda;
  final DateTime dataHora;
  final String? autor;
  final String? observacao;
}

/// Linha do histórico/timeline da OS — cada ação (solicitar, autorizar,
/// iniciar, pausar, avaliar, entregar, refazer, cancelar) fica auditável.
class EventoOs {
  const EventoOs({
    required this.dataHora,
    required this.autor,
    required this.acao,
    this.observacao,
  });

  final DateTime dataHora;
  final String autor;
  final String acao;
  final String? observacao;
}

class OrdemServico {
  const OrdemServico({
    required this.id,
    required this.codigo,
    required this.fazenda,
    required this.solicitante,
    required this.dataEmissao,
    required this.dataExecucao,
    required this.prazo,
    required this.responsavelExecucao,
    required this.uso,
    required this.operacao,
    required this.atividade,
    required this.area,
    this.culturaVariedade,
    this.lote,
    this.categoria,
    required this.condicoes,
    required this.descricao,
    required this.instrucoes,
    required this.seguranca,
    required this.maoDeObra,
    required this.maquinas,
    required this.armazemInsumos,
    required this.insumos,
    this.armazemProducao,
    this.producao = const [],
    required this.epis,
    required this.autorizador,
    required this.dataAutorizacao,
    required this.prioridade,
    required this.status,
    required this.historico,
    this.dataInicio,
    this.dataPausa,
    this.motivoPausa,
    this.dataEntrega,
    this.evidencias = const [],
    this.justificativaRefazer,
    this.motivoCancelamento,
    this.avaliacao,
  });

  final String id;

  // --- Identificação (WEB) ---
  /// Sequencial por fazenda, gerado pelo sistema.
  final String codigo;
  final String fazenda;

  /// Usuário que abriu a OS no WEB.
  final String solicitante;
  final DateTime dataEmissao;
  final DateTime dataExecucao;

  /// Prazo final.
  final DateTime prazo;

  /// Responsável (usuário do sistema) pela execução/acompanhamento.
  final String responsavelExecucao;

  // --- Tipo de serviço (WEB): Uso → Operação → Atividade ---
  final UsoOs uso;
  final String operacao;
  final String atividade;

  // --- Execução (WEB) ---
  final String area;

  /// Só com [UsoOs.usaCultura].
  final String? culturaVariedade;

  /// Só com [UsoOs.usaLote].
  final String? lote;
  final String? categoria;

  final CondicoesOs condicoes;

  /// Descrição do Serviço (Instruções Detalhadas).
  final String descricao;
  final InstrucoesOs instrucoes;
  final SegurancaOs seguranca;

  // --- Recursos e Insumos (WEB) ---
  final List<MaoDeObraOs> maoDeObra;
  final List<MaquinaOs> maquinas;

  /// Um armazém por aba, como no WEB.
  final String armazemInsumos;
  final List<InsumoOs> insumos;
  final String? armazemProducao;
  final List<ProducaoOs> producao;
  final List<EpiOs> epis;

  // --- Ciclo de campo (fora do formulário do WEB) ---
  final String autorizador;
  final DateTime dataAutorizacao;
  final PrioridadeOs prioridade;
  final OrdemServicoStatus status;

  final DateTime? dataInicio;
  final DateTime? dataPausa;
  final String? motivoPausa;
  final DateTime? dataEntrega;
  final List<EvidenciaOs> evidencias;
  final String? justificativaRefazer;

  final String? motivoCancelamento;
  final AvaliacaoOs? avaliacao;

  final List<EventoOs> historico;

  /// O WEB não tem título: a OS é lida pela atividade e por onde (ou em
  /// quem) ela acontece — "Vacinação — Lote 12 Recria".
  String get titulo => '$atividade — ${lote ?? culturaVariedade ?? area}';

  OrdemServico copyWith({
    OrdemServicoStatus? status,
    DateTime? dataInicio,
    DateTime? dataPausa,
    String? motivoPausa,
    bool clearMotivoPausa = false,
    DateTime? dataEntrega,
    List<EvidenciaOs>? evidencias,
    String? justificativaRefazer,
    String? motivoCancelamento,
    AvaliacaoOs? avaliacao,
    List<EventoOs>? historico,
  }) {
    return OrdemServico(
      id: id,
      codigo: codigo,
      fazenda: fazenda,
      solicitante: solicitante,
      dataEmissao: dataEmissao,
      dataExecucao: dataExecucao,
      prazo: prazo,
      responsavelExecucao: responsavelExecucao,
      uso: uso,
      operacao: operacao,
      atividade: atividade,
      area: area,
      culturaVariedade: culturaVariedade,
      lote: lote,
      categoria: categoria,
      condicoes: condicoes,
      descricao: descricao,
      instrucoes: instrucoes,
      seguranca: seguranca,
      maoDeObra: maoDeObra,
      maquinas: maquinas,
      armazemInsumos: armazemInsumos,
      insumos: insumos,
      armazemProducao: armazemProducao,
      producao: producao,
      epis: epis,
      autorizador: autorizador,
      dataAutorizacao: dataAutorizacao,
      prioridade: prioridade,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataPausa: clearMotivoPausa ? null : (dataPausa ?? this.dataPausa),
      motivoPausa: clearMotivoPausa ? null : (motivoPausa ?? this.motivoPausa),
      dataEntrega: dataEntrega ?? this.dataEntrega,
      evidencias: evidencias ?? this.evidencias,
      justificativaRefazer: justificativaRefazer ?? this.justificativaRefazer,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      avaliacao: avaliacao ?? this.avaliacao,
      historico: historico ?? this.historico,
    );
  }
}
