import 'package:flutter_test/flutter_test.dart';

import '../../support/router_test_harness.dart';

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness();
    addTearDown(harness.dispose);
    harness.router.go('/desktop');
  });

  group('AndroidHomePage', () {
    testWidgets('renderiza a área de trabalho com o ícone CERNE App', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('CERNE App'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'tocar em "CERNE App" abre a pasta com o único app, Administrativo',
      (tester) async {
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('CERNE App'));
        await tester.pumpAndSettle();

        expect(find.text('Administrativo'), findsOneWidget);
        expect(find.text('Operacional'), findsNothing);
      },
    );
  });

  group('CerneAppFolderPage', () {
    testWidgets(
      'tocar em "Administrativo" empilha um único login administrativo',
      (tester) async {
        harness.router.go('/desktop/cerne-app');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Administrativo'));
        await tester.pumpAndSettle();

        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('Acesso administrativo'), findsOneWidget);
        expect(find.text('Login Administração'), findsNothing);
        expect(find.text('Acesso operacional'), findsNothing);

        // `push`, não `go` — a pasta continua na pilha do Navigator.
        expect(harness.router.canPop(), isTrue);
      },
    );

  });
}
