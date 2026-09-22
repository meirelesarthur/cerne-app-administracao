import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/farm_list_screen.dart';
import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';

void main() {
  group('FarmListScreen', () {
    testWidgets('lista as fazendas e marca a ativa', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: FarmListScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fazenda São Pedro'), findsOneWidget);
      expect(find.text('Fazenda Santa Rita'), findsOneWidget);
      expect(find.text('Ativa'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('troca a fazenda ativa ao tocar em outra', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: FarmListScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fazenda Santa Rita'));
      await tester.pump();

      expect(
        container.read(fazendasStoreProvider).activeFarm.name,
        'Fazenda Santa Rita',
      );
    });
  });
}
