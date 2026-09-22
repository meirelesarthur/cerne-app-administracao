import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mocks/fazendas.dart';
import '../types.dart';

/// Store do módulo Fazendas (spec §7.3) — espelha `fazendasStore.ts`. Isolada
/// do Shell. Guarda a fazenda ativa (tenant) e a fila de sync mockada. A
/// responsabilidade administrativa/operacional pertence à sessão do Shell.
///
/// NOTA (F4 core): este arquivo substitui uma versão mínima temporária que
/// havia sido criada em paralelo pelos fluxos operacionais (F5) com uma API
/// parcialmente diferente (`enqueueSync` com parâmetros nomeados, `activeFarm()`
/// como método). Os nomes públicos abaixo são a versão definitiva combinada com
/// o React (`fazendasStore.ts`): `enqueueSync(SyncItem)`, `activeFarm` como
/// getter. Quem consumir esta store deve seguir esta API.
class FazendasState {
  const FazendasState({
    required this.farms,
    required this.activeFarmId,
    required this.syncQueue,
    required this.pesagemDoDiaFeita,
  });

  final List<Farm> farms;
  final String activeFarmId;
  final List<SyncItem> syncQueue;

  /// pesagem do dia registrada? Pré-requisito da transferência de lote
  /// (spec §5.1/§5.2/DUV-179).
  final bool pesagemDoDiaFeita;

  Farm get activeFarm =>
      farms.firstWhere((f) => f.id == activeFarmId, orElse: () => farms.first);

  FazendasState copyWith({
    List<Farm>? farms,
    String? activeFarmId,
    List<SyncItem>? syncQueue,
    bool? pesagemDoDiaFeita,
  }) {
    return FazendasState(
      farms: farms ?? this.farms,
      activeFarmId: activeFarmId ?? this.activeFarmId,
      syncQueue: syncQueue ?? this.syncQueue,
      pesagemDoDiaFeita: pesagemDoDiaFeita ?? this.pesagemDoDiaFeita,
    );
  }
}

final fazendasStoreProvider =
    NotifierProvider<FazendasStoreNotifier, FazendasState>(
      FazendasStoreNotifier.new,
    );

class FazendasStoreNotifier extends Notifier<FazendasState> {
  @override
  FazendasState build() {
    return FazendasState(
      farms: fazendas,
      activeFarmId: fazendas.first.id,
      syncQueue: const [],
      pesagemDoDiaFeita: false,
    );
  }

  void setActiveFarm(String id) => state = state.copyWith(activeFarmId: id);

  void enqueueSync(SyncItem item) =>
      state = state.copyWith(syncQueue: [...state.syncQueue, item]);

  void clearSync() => state = state.copyWith(syncQueue: const []);

  void registrarPesagemDoDia() =>
      state = state.copyWith(pesagemDoDiaFeita: true);
}
