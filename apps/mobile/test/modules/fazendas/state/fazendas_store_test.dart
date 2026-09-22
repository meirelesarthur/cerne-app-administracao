import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';
import 'package:cerne_app/modules/fazendas/types.dart';

void main() {
  group('FazendasStoreNotifier', () {
    test(
      'estado inicial: visão gerencial, primeira fazenda ativa, fila vazia',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final state = container.read(fazendasStoreProvider);

        expect(state.activeFarmId, state.farms.first.id);
        expect(state.activeFarm.id, state.farms.first.id);
        expect(state.syncQueue, isEmpty);
        expect(state.pesagemDoDiaFeita, isFalse);
      },
    );

    test('setActiveFarm troca a fazenda ativa', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(fazendasStoreProvider.notifier);

      final secondFarmId = container.read(fazendasStoreProvider).farms[1].id;
      notifier.setActiveFarm(secondFarmId);

      expect(container.read(fazendasStoreProvider).activeFarmId, secondFarmId);
      expect(container.read(fazendasStoreProvider).activeFarm.id, secondFarmId);
    });

    test('enqueueSync adiciona item e clearSync esvazia a fila', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(fazendasStoreProvider.notifier);

      notifier.enqueueSync(
        const SyncItem(
          id: 's1',
          label: 'Pesagem',
          detail: '120 kg',
          kind: ActivityKind.pesagem,
        ),
      );

      expect(container.read(fazendasStoreProvider).syncQueue, hasLength(1));

      notifier.clearSync();

      expect(container.read(fazendasStoreProvider).syncQueue, isEmpty);
    });

    test('registrarPesagemDoDia marca a flag como verdadeira', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(fazendasStoreProvider.notifier);

      notifier.registrarPesagemDoDia();

      expect(container.read(fazendasStoreProvider).pesagemDoDiaFeita, isTrue);
    });
  });
}
