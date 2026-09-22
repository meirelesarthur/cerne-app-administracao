import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_uso.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashUso', () {
    testWidgets(
      'renderiza sem exceção e mostra a fazenda expandida por padrão',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(_wrap(const DashUso()));
        await tester.pumpAndSettle();

        expect(find.text('Adoção & Governança'), findsWidgets);
        expect(find.text('Adoção por fazenda'), findsOneWidget);
        expect(find.text('Trilha de auditoria'), findsOneWidget);
        expect(find.text('Acesso restrito'), findsOneWidget);
        // O nome aparece duas vezes: na barra de adoção e no tile expansível.
        expect(find.text('Fazenda São Pedro'), findsWidgets);
        expect(find.text('João Silva'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('mostra estado de erro com retry quando offline', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(shellStoreProvider.notifier).setOnline(false);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: DashUso()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Indisponível offline'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('recorta os indicadores para um usuário específico', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashUso()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('João Silva').last);
      await tester.pumpAndSettle();

      expect(find.text('João Silva'), findsWidgets);
      expect(find.text('Fazenda São Pedro'), findsWidgets);
      expect(find.text('Fazenda Santa Rita'), findsNothing);
      expect(
        find.text('As métricas mostram apenas a atividade deste usuário.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
