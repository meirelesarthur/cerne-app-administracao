import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/components/sync_banner.dart';
import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';
import 'package:cerne_app/modules/fazendas/types.dart';

Widget _wrap(ProviderContainer container, Widget child) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('SyncBanner', () {
    testWidgets('não renderiza nada quando a fila está vazia', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container, const SyncBanner()));

      expect(find.byType(SyncBanner), findsOneWidget);
      expect(find.text('Sincronizar'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mostra a contagem e permite sincronizar quando online', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            const SyncItem(
              id: 's1',
              label: 'Pesagem',
              detail: '120 kg',
              kind: ActivityKind.pesagem,
            ),
          );

      await tester.pumpWidget(_wrap(container, const SyncBanner()));

      expect(
        find.text('1 lançamento aguardando sincronização'),
        findsOneWidget,
      );
      expect(find.text('Sincronizar'), findsOneWidget);

      await tester.tap(find.text('Sincronizar'));
      await tester.pump();

      expect(container.read(fazendasStoreProvider).syncQueue, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });
}
