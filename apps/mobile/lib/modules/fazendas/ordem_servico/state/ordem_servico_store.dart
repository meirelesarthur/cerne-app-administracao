import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mocks.dart' as mocks;
import '../models.dart';

/// Store de Ordem de Serviço — guarda em memória o que o Operacional lança
/// (iniciar/pausar/retomar/entregar/refazer) e o que o Administrativo lança
/// (avaliar/cancelar), sem backend: mesmo padrão de
/// `confinamento/state/confinamento_store.dart` (protótipo frontend).
class OrdemServicoState {
  const OrdemServicoState({required this.ordens});

  final List<OrdemServico> ordens;

  OrdemServicoState copyWith({List<OrdemServico>? ordens}) {
    return OrdemServicoState(ordens: ordens ?? this.ordens);
  }
}

final ordemServicoStoreProvider =
    NotifierProvider<OrdemServicoStoreNotifier, OrdemServicoState>(
      OrdemServicoStoreNotifier.new,
    );

class OrdemServicoStoreNotifier extends Notifier<OrdemServicoState> {
  @override
  OrdemServicoState build() {
    return OrdemServicoState(ordens: List.of(mocks.ordensServico));
  }

  OrdemServico byId(String id) => state.ordens.firstWhere((o) => o.id == id);

  void _update(String id, OrdemServico Function(OrdemServico atual) update) {
    state = state.copyWith(
      ordens: [
        for (final o in state.ordens)
          if (o.id == id) update(o) else o,
      ],
    );
  }

  /// Ação do Operacional: aguardando → em execução.
  void iniciar(String id, {required String autor}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.emExecucao,
        dataInicio: agora,
        historico: [
          ...o.historico,
          EventoOs(dataHora: agora, autor: autor, acao: 'Execução iniciada'),
        ],
      ),
    );
  }

  /// Ação do Operacional: em execução → pausada, com motivo.
  void pausar(String id, {required String autor, required String motivo}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.pausada,
        dataPausa: agora,
        motivoPausa: motivo,
        historico: [
          ...o.historico,
          EventoOs(
            dataHora: agora,
            autor: autor,
            acao: 'Execução pausada',
            observacao: motivo,
          ),
        ],
      ),
    );
  }

  /// Ação do Operacional: pausada → em execução novamente.
  void retomar(String id, {required String autor}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.emExecucao,
        clearMotivoPausa: true,
        historico: [
          ...o.historico,
          EventoOs(dataHora: agora, autor: autor, acao: 'Execução retomada'),
        ],
      ),
    );
  }

  /// Ação do Operacional: encerra a OS com sucesso.
  void marcarEntregue(String id, {required String autor}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.entregue,
        dataEntrega: agora,
        historico: [
          ...o.historico,
          EventoOs(dataHora: agora, autor: autor, acao: 'OS marcada como entregue'),
        ],
      ),
    );
  }

  /// Ação do Operacional: encerra a OS sinalizando retrabalho, com justificativa.
  void marcarRefeita(String id, {required String autor, required String justificativa}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.refeita,
        justificativaRefazer: justificativa,
        historico: [
          ...o.historico,
          EventoOs(
            dataHora: agora,
            autor: autor,
            acao: 'OS marcada como refeita',
            observacao: justificativa,
          ),
        ],
      ),
    );
  }

  /// Ação do Administrativo: checkpoint de qualidade — só enquanto a OS
  /// ainda está em andamento (regra de negócio: nunca sobre OS finalizada).
  void avaliar(
    String id, {
    required String avaliador,
    required int nota,
    required String comentario,
  }) {
    final atual = byId(id);
    if (atual.status.encerrada) return;
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        avaliacao: AvaliacaoOs(
          nota: nota,
          comentario: comentario,
          avaliador: avaliador,
          dataHora: agora,
        ),
        historico: [
          ...o.historico,
          EventoOs(
            dataHora: agora,
            autor: avaliador,
            acao: 'Avaliação registrada — nota $nota',
            observacao: comentario,
          ),
        ],
      ),
    );
  }

  /// Ação do Administrativo: cancela a OS — só enquanto ainda não foi
  /// encerrada pelo Operacional (aguardando/em execução/pausada).
  void cancelar(String id, {required String autor, required String motivo}) {
    final atual = byId(id);
    if (atual.status.encerrada) return;
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.cancelada,
        motivoCancelamento: motivo,
        historico: [
          ...o.historico,
          EventoOs(
            dataHora: agora,
            autor: autor,
            acao: 'OS cancelada',
            observacao: motivo,
          ),
        ],
      ),
    );
  }
}
