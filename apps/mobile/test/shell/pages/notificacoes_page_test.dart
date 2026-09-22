import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

import '../../support/router_test_harness.dart';

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness(profile: UserAccessProfile.administration);
    addTearDown(harness.dispose);
    harness.router.go('/notificacoes');
  });

  group('NotificacoesPage', () {
    testWidgets('lista as notificações mock e mostra "Marcar lidas"', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Pesagem registrada'), findsOneWidget);
      expect(find.text('Crédito pré-aprovado'), findsOneWidget);
      expect(find.text('Marcar lidas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Marcar lidas" zera as não lidas e some da tela', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(
        harness.container.read(shellStoreProvider).unreadCount,
        greaterThan(0),
      );

      await tester.tap(find.text('Marcar lidas'));
      await tester.pumpAndSettle();

      expect(harness.container.read(shellStoreProvider).unreadCount, 0);
      expect(find.text('Marcar lidas'), findsNothing);
    });

    testWidgets('tocar numa notificação navega para o módulo correspondente', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pesagem registrada'));
      await tester.pumpAndSettle();

      expect(find.text('Central de gestão'), findsNothing);
    });
  });
}
