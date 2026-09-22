import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mocks.dart' as mocks;
import '../models.dart';

/// Store do submódulo Confinamento — guarda em memória tudo que o
/// Operacional lança em campo (situação de curral, bateladas, trato diário,
/// leituras de cocho, confirmação de ordens). Sem backend: mesmo padrão de
/// `fazendas_store.dart`/`prototype_records_store.dart` (protótipo frontend).
///
/// O ADM (dashboard único, `admin/dash_confinamento.dart`) só lê este estado —
/// nunca escreve nele.
class ConfinamentoState {
  const ConfinamentoState({
    required this.currais,
    required this.bateladas,
    required this.tratosDiarios,
    required this.leiturasCocho,
    required this.ordensPendentes,
  });

  final List<CurralInfo> currais;
  final List<Batelada> bateladas;
  final List<TratoDiario> tratosDiarios;
  final List<LeituraCocho> leiturasCocho;
  final List<OrdemPendente> ordensPendentes;

  ConfinamentoState copyWith({
    List<CurralInfo>? currais,
    List<Batelada>? bateladas,
    List<TratoDiario>? tratosDiarios,
    List<LeituraCocho>? leiturasCocho,
    List<OrdemPendente>? ordensPendentes,
  }) {
    return ConfinamentoState(
      currais: currais ?? this.currais,
      bateladas: bateladas ?? this.bateladas,
      tratosDiarios: tratosDiarios ?? this.tratosDiarios,
      leiturasCocho: leiturasCocho ?? this.leiturasCocho,
      ordensPendentes: ordensPendentes ?? this.ordensPendentes,
    );
  }
}

final confinamentoStoreProvider =
    NotifierProvider<ConfinamentoStoreNotifier, ConfinamentoState>(
      ConfinamentoStoreNotifier.new,
    );

class ConfinamentoStoreNotifier extends Notifier<ConfinamentoState> {
  @override
  ConfinamentoState build() {
    return ConfinamentoState(
      currais: List.of(mocks.currais),
      bateladas: [mocks.bateladaConcluida],
      tratosDiarios: [mocks.tratoDiarioEmAndamento],
      leiturasCocho: [mocks.leituraCochoRecente],
      ordensPendentes: List.of(mocks.ordensPendentes),
    );
  }

  CurralInfo curralById(String id) =>
      state.currais.firstWhere((c) => c.id == id);

  /// "Alterar Situação" (spec §3.3) — ação rápida disponível ao Operacional
  /// no seu próprio setor, independente do cadastro completo (que é do web).
  void alterarSituacaoCurral(
    String curralId,
    CurralSituacao novaSituacao, {
    DateTime? liberacaoEm,
  }) {
    state = state.copyWith(
      currais: [
        for (final c in state.currais)
          if (c.id == curralId)
            c.copyWith(
              situacao: novaSituacao,
              liberacaoEm: liberacaoEm,
              clearLiberacao: !novaSituacao.temLiberacaoPrevista,
            )
          else
            c,
      ],
    );
  }

  /// Produzir Batelada (spec §4.3) — a escala dos ingredientes já vem
  /// calculada pela tela (regra: quantidade original × produzida ÷
  /// referência); aqui só persiste o registro com o previsto e o realizado
  /// informado pelo operador.
  void registrarBatelada(Batelada batelada) {
    state = state.copyWith(bateladas: [...state.bateladas, batelada]);
  }

  /// Trato Diário — registra o fornecido a um curral elegível e, quando
  /// `concluir` é true, marca o lançamento como concluído (spec §4.4).
  void registrarFornecimento(
    String tratoId,
    String curralId,
    double quantidadeFornecida, {
    bool concluir = false,
  }) {
    state = state.copyWith(
      tratosDiarios: [
        for (final t in state.tratosDiarios)
          if (t.id == tratoId)
            TratoDiario(
              id: t.id,
              bateladaId: t.bateladaId,
              lancamentos: [
                for (final l in t.lancamentos)
                  if (l.curralId == curralId)
                    l.copyWith(
                      quantidadeFornecida: quantidadeFornecida,
                      concluido: concluir,
                    )
                  else
                    l,
              ],
            )
          else
            t,
      ],
    );
  }

  void iniciarTratoDiario(TratoDiario trato) {
    state = state.copyWith(tratosDiarios: [...state.tratosDiarios, trato]);
  }

  /// Leitura de Cocho (spec §4.5) — grava a leitura completa (todos os
  /// currais e ocorrências incluídos na sessão de leitura).
  void registrarLeituraCocho(LeituraCocho leitura) {
    state = state.copyWith(leiturasCocho: [...state.leiturasCocho, leitura]);
  }

  /// Confirma a execução de uma ordem criada pelo ADM (transferência de lote
  /// ou troca de dieta) — o Operacional nunca decide essas duas ações
  /// livremente, só confirma (decisão de perfil, ver `models.dart`).
  void confirmarOrdemPendente(String ordemId) {
    final ordem = state.ordensPendentes.firstWhere((o) => o.id == ordemId);

    var currais = state.currais;
    switch (ordem.tipo) {
      case OrdemTipo.transferenciaLote:
        final origem = currais.firstWhere((c) => c.id == ordem.curralOrigemId);
        final destinoId = ordem.curralDestinoId!;
        currais = [
          for (final c in currais)
            if (c.id == ordem.curralOrigemId)
              c.copyWith(
                situacao: CurralSituacao.vazioSanitario,
                clearIndicadores: true,
              )
            else if (c.id == destinoId)
              c.copyWith(
                situacao: CurralSituacao.ocupado,
                indicadores: origem.indicadores,
                dietaAtualId: origem.dietaAtualId,
              )
            else
              c,
        ];
      case OrdemTipo.trocaDieta:
        currais = [
          for (final c in currais)
            if (c.id == ordem.curralOrigemId)
              c.copyWith(dietaAtualId: ordem.novaDietaId)
            else
              c,
        ];
    }

    state = state.copyWith(
      currais: currais,
      ordensPendentes: [
        for (final o in state.ordensPendentes)
          if (o.id == ordemId)
            o.copyWith(status: OrdemStatus.confirmada)
          else
            o,
      ],
    );
  }
}
