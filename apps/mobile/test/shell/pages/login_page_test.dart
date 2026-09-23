import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/prototype_session_store.dart';

import '../../support/router_test_harness.dart';
import '../../support/test_viewport.dart';

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness();
    addTearDown(harness.dispose);
    harness.router.go('/login');
  });

  group('LoginPage', () {
    testWidgets('renderiza marca e formulário sem exceção', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('GB CERNE'), findsOneWidget);
      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(find.text('ENTRAR'), findsOneWidget);
      expect(find.text('Login Administração'), findsNothing);
      expect(find.text('Login Operacional'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Tour pelo app" navega para o onboarding', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      final tour = find.text('Tour pelo app');
      await tester.ensureVisible(tour);
      await tester.pumpAndSettle();
      await tester.tap(tour);
      await tester.pumpAndSettle();

      expect(find.text('Sua fazenda na palma da mão'), findsOneWidget);
    });

    testWidgets('alterna "Manter conectado" ao tocar', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      final keepConnected = find.text('Manter conectado');
      await tester.ensureVisible(keepConnected);
      await tester.pumpAndSettle();
      await tester.tap(keepConnected);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('login padrão inicia sessão administrativa no Banking', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('ENTRAR'));
      await tester.pumpAndSettle();

      expect(find.text('Conta GB Banking'), findsOneWidget);
      expect(
        harness.container.read(prototypeSessionProvider).profile,
        UserAccessProfile.administration,
      );
    });

    testWidgets('a tela anuncia o acesso administrativo único', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Acesso administrativo'), findsOneWidget);
      expect(find.text('Acesso operacional'), findsNothing);
    });
  });
}
