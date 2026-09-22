/// Contrato de domínio de Ordem de Serviço (OS) — a partir da especificação
/// funcional web (levantamento de 16/09/2026): planejar, autorizar, executar
/// e acompanhar serviços de campo (agrícolas/pecuários), cobrindo o ciclo
/// solicitação → detalhamento técnico/segurança → alocação de recursos (mão
/// de obra, máquinas, insumos, EPIs) → execução com evidências → conclusão →
/// avaliação.
///
/// Decisão de perfil confirmada com o usuário:
/// - Administrativo cria a OS diretamente na aba "OS" (`ordem_servico_painel.dart`,
///   `OrdemServicoStoreNotifier.criar`) — autoassina como solicitante e
///   autorizador, sem uma segunda etapa de aprovação (spec simplificada de
///   protótipo). Também avalia (checkpoint de qualidade, sem mudar o
///   andamento) ou cancela, mas só enquanto a OS ainda não foi encerrada pelo
///   Operacional (aguardando/em execução/pausada) — nunca uma já entregue ou
///   refeita.
/// - Operacional inicia, pausa/retoma e encerra a própria OS (entregue, ou
///   refeita com justificativa quando o serviço não pôde ser concluído como
///   planejado).
library;

enum TipoServicoOs { agricola, pecuario, manutencao, infraestrutura }

extension TipoServicoOsLabel on TipoServicoOs {
  String get label => switch (this) {
    TipoServicoOs.agricola => 'Agrícola',
    TipoServicoOs.pecuario => 'Pecuário',
    TipoServicoOs.manutencao => 'Manutenção',
    TipoServicoOs.infraestrutura => 'Infraestrutura',
  };
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
/// só o Operacional decide; `cancelada` só o Administrativo decide — e só
/// antes de um desses dois encerramentos.
enum OrdemServicoStatus { aguardando, emExecucao, pausada, entregue, refeita, cancelada }

extension OrdemServicoStatusLabel on OrdemServicoStatus {
  String get label => switch (this) {
    OrdemServicoStatus.aguardando => 'Aguardando',
    OrdemServicoStatus.emExecucao => 'Em execução',
    OrdemServicoStatus.pausada => 'Pausada',
    OrdemServicoStatus.entregue => 'Entregue',
    OrdemServicoStatus.refeita => 'Refeita',
    OrdemServicoStatus.cancelada => 'Cancelada',
  };

  /// Só nesses três estados o Operacional ainda pode agir (iniciar, pausar,
  /// retomar, entregar, refazer) e o Administrativo pode avaliar/cancelar.
  bool get emAndamento => this == OrdemServicoStatus.aguardando ||
      this == OrdemServicoStatus.emExecucao ||
      this == OrdemServicoStatus.pausada;

  bool get encerrada => !emAndamento;
}

/// Checkpoint de qualidade que o Administrativo pode registrar enquanto a OS
/// ainda está em andamento — não é a "nota final" de uma OS entregue, é um
/// acompanhamento (regra confirmada com o usuário: nunca incide sobre OS já
/// finalizada).
class AvaliacaoOs {
  const AvaliacaoOs({
    required this.nota,
    required this.comentario,
    required this.avaliador,
    required this.dataHora,
  });

  /// 1 a 5.
  final int nota;
  final String comentario;
  final String avaliador;
  final DateTime dataHora;
}

/// Evidência registrada pelo Operacional durante a execução (spec: "execução
/// em campo com registro de evidências"). Sem upload real no protótipo —
/// `legenda` descreve o que a foto mostraria.
class EvidenciaOs {
  const EvidenciaOs({required this.legenda, required this.dataHora});

  final String legenda;
  final DateTime dataHora;
}

/// Linha do histórico/timeline da OS — cada ação (iniciar, pausar, entregar,
/// refazer, avaliar, cancelar) fica registrada aqui, auditável.
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
    required this.titulo,
    required this.tipo,
    required this.fazenda,
    required this.areaOuTalhao,
    required this.solicitante,
    required this.dataSolicitacao,
    required this.autorizador,
    required this.dataAutorizacao,
    required this.prioridade,
    required this.prazo,
    required this.descricao,
    required this.instrucoesSeguranca,
    required this.maoDeObra,
    required this.maquinas,
    required this.insumos,
    required this.epis,
    required this.status,
    required this.responsavelExecucao,
    required this.historico,
    this.dataInicio,
    this.dataPausa,
    this.motivoPausa,
    this.dataEntrega,
    this.evidencias = const [],
    this.justificativaRefazer,
    this.avaliacao,
    this.motivoCancelamento,
  });

  final String id;
  final String codigo;
  final String titulo;
  final TipoServicoOs tipo;
  final String fazenda;
  final String areaOuTalhao;

  final String solicitante;
  final DateTime dataSolicitacao;
  final String autorizador;
  final DateTime dataAutorizacao;

  final PrioridadeOs prioridade;
  final DateTime prazo;
  final String descricao;
  final String instrucoesSeguranca;

  /// Alocação de recursos definida na autorização (spec: mão de obra,
  /// máquinas, insumos, EPIs).
  final List<String> maoDeObra;
  final List<String> maquinas;
  final List<String> insumos;
  final List<String> epis;

  final OrdemServicoStatus status;
  final String responsavelExecucao;

  final DateTime? dataInicio;
  final DateTime? dataPausa;
  final String? motivoPausa;
  final DateTime? dataEntrega;
  final List<EvidenciaOs> evidencias;
  final String? justificativaRefazer;

  final AvaliacaoOs? avaliacao;
  final String? motivoCancelamento;

  final List<EventoOs> historico;

  OrdemServico copyWith({
    OrdemServicoStatus? status,
    DateTime? dataInicio,
    DateTime? dataPausa,
    String? motivoPausa,
    bool clearMotivoPausa = false,
    DateTime? dataEntrega,
    List<EvidenciaOs>? evidencias,
    String? justificativaRefazer,
    AvaliacaoOs? avaliacao,
    String? motivoCancelamento,
    List<EventoOs>? historico,
  }) {
    return OrdemServico(
      id: id,
      codigo: codigo,
      titulo: titulo,
      tipo: tipo,
      fazenda: fazenda,
      areaOuTalhao: areaOuTalhao,
      solicitante: solicitante,
      dataSolicitacao: dataSolicitacao,
      autorizador: autorizador,
      dataAutorizacao: dataAutorizacao,
      prioridade: prioridade,
      prazo: prazo,
      descricao: descricao,
      instrucoesSeguranca: instrucoesSeguranca,
      maoDeObra: maoDeObra,
      maquinas: maquinas,
      insumos: insumos,
      epis: epis,
      status: status ?? this.status,
      responsavelExecucao: responsavelExecucao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataPausa: clearMotivoPausa ? null : (dataPausa ?? this.dataPausa),
      motivoPausa: clearMotivoPausa ? null : (motivoPausa ?? this.motivoPausa),
      dataEntrega: dataEntrega ?? this.dataEntrega,
      evidencias: evidencias ?? this.evidencias,
      justificativaRefazer: justificativaRefazer ?? this.justificativaRefazer,
      avaliacao: avaliacao ?? this.avaliacao,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      historico: historico ?? this.historico,
    );
  }
}
