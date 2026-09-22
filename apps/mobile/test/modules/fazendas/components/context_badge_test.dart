import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/components/context_badge.dart';
import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';

Widget _wrap(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: const Scaffold(body: ContextBadge()),
  ),
);

void main() {
  group('ContextBadge', () {
    testWidgets('mostra a fazenda ativa', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));

      expect(find.textContaining('Lançando em:'), findsOneWidget);
      expect(find.text('Lançando em: Fazenda São Pedro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('atualiza o nome ao trocar a fazenda ativa por fora', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final secondFarm = container.read(fazendasStoreProvider).farms[1];

      await tester.pumpWidget(_wrap(container));

      container
          .read(fazendasStoreProvider.notifier)
          .setActiveFarm(secondFarm.id);
      await tester.pump();

      expect(find.textContaining(secondFarm.name), findsOneWidget);
    });

    testWidgets('tocar abre o seletor e trocar a fazenda muda o contexto', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));

      await tester.tap(find.text('Lançando em: Fazenda São Pedro'));
      await tester.pumpAndSettle();

      expect(find.text('Trocar de fazenda'), findsOneWidget);
      expect(find.text('Fazenda Santa Rita'), findsOneWidget);

      await tester.tap(find.text('Fazenda Santa Rita'));
      await tester.pumpAndSettle();

      // O seletor fecha e a faixa passa a refletir o novo tenant.
      expect(find.text('Trocar de fazenda'), findsNothing);
      expect(find.text('Lançando em: Fazenda Santa Rita'), findsOneWidget);
      expect(container.read(fazendasStoreProvider).activeFarmId, 'f2');
    });

    testWidgets('a fazenda ativa é marcada no seletor', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));

      await tester.tap(find.text('Lançando em: Fazenda São Pedro'));
      await tester.pumpAndSettle();

      expect(find.text('Ativa'), findsOneWidget);
    });

    // fidelidade-esteira: "a troca de fazenda precisa de um search também".
    testWidgets('o seletor filtra a lista pela busca', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));

      await tester.tap(find.text('Lançando em: Fazenda São Pedro'));
      await tester.pumpAndSettle();

      expect(find.text('Fazenda Santa Rita'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'São Pedro');
      await tester.pumpAndSettle();

      expect(find.text('Fazenda São Pedro'), findsOneWidget);
      expect(find.text('Fazenda Santa Rita'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
