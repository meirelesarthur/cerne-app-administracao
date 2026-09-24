import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/shell/components/reveal_menu.dart';
import 'package:cerne_app/shell/module_config.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

Widget _wrap(ProviderContainer container, Widget child) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(body: SizedBox.expand(child: child)),
    ),
  );
}

void main() {
  group('AppRevealMenu', () {
    testWidgets('não mostra conteúdo quando o menu está fechado', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          AppRevealMenu(module: getModule('bank')!, onNavigate: (_) {}),
        ),
      );
      await tester.pump();

      expect(find.text('Sair'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'mostra as seções do módulo e dispara onNavigate ao tocar em "Sair"',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(shellStoreProvider.notifier).openMenu();
        // O painel é rolável (ListView) — aumenta a viewport de teste para que
        // todos os itens sejam montados, sem precisar simular scroll.
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        String? navigatedTo;
        await tester.pumpWidget(
          _wrap(
            container,
            AppRevealMenu(
              module: getModule('bank')!,
              onNavigate: (route) => navigatedTo = route,
            ),
          ),
        );
        // assenta as animações de stagger dos itens.
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('Silvio Ventura'), findsOneWidget);
        // O título da seção é exibido em caixa alta (equivalente ao `uppercase`
        // do Tailwind no React — transformação puramente visual).
        expect(find.text('PAGAMENTOS E TRANSFERÊNCIAS'), findsOneWidget);
        expect(find.text('Sair'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Sair'));
        await tester.pump();

        expect(navigatedTo, '/login');
      },
    );

    testWidgets('toca "Modo GB" e alterna o themeVariantProvider', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(shellStoreProvider.notifier).openMenu();
      // O painel é rolável (ListView) — aumenta a viewport de teste para que
      // todos os itens sejam montados, sem precisar simular scroll.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _wrap(
          container,
          AppRevealMenu(module: getModule('bank')!, onNavigate: (_) {}),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Inativo'), findsOneWidget);

      await tester.tap(find.text('Modo GB'));
      await tester.pump();

      expect(find.text('Ativo'), findsOneWidget);
    });

    testWidgets('toca "Conexão" e alterna isOnline no shellStoreProvider', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(shellStoreProvider.notifier).openMenu();
      // O painel é rolável (ListView) — aumenta a viewport de teste para que
      // todos os itens sejam montados, sem precisar simular scroll.
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _wrap(
          container,
          AppRevealMenu(module: getModule('bank')!, onNavigate: (_) {}),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(container.read(shellStoreProvider).isOnline, isTrue);

      await tester.tap(find.text('Conexão'));
      await tester.pump();

      expect(container.read(shellStoreProvider).isOnline, isFalse);
    });
  });
}
