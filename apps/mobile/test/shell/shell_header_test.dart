import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/shell/components/shell_header.dart';
import 'package:cerne_app/shell/state/shell_store.dart';
import 'package:cerne_app/ui/app_icon.dart';

import '../helpers/app_icon_finder.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AppShellHeader', () {
    testWidgets('mostra saudação determinística e nome do usuário', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppShellHeader()));

      expect(find.text('Boa tarde,'), findsOneWidget);
      expect(find.text('Silvio Ventura'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sem onConsultMode não mostra o botão de modo consulta', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppShellHeader()));

      expect(findAppIcon(AppIcons.eye), findsNothing);
    });

    testWidgets('com onConsultMode mostra e dispara o callback ao tocar', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppShellHeader(onConsultMode: () => tapped = true)),
      );

      expect(findAppIcon(AppIcons.eye), findsOneWidget);
      await tester.tap(findAppIcon(AppIcons.eye));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('dispara onOpenProfile ao tocar no bloco de avatar/nome', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppShellHeader(onOpenProfile: () => tapped = true)),
      );

      await tester.tap(find.text('Silvio Ventura'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('dispara onOpenNotifications ao tocar no sino', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppShellHeader(onOpenNotifications: () => tapped = true)),
      );

      await tester.tap(findAppIcon(AppIcons.bell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('alterna o tema pelo ícone à esquerda do sino', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: AppShellHeader()),
          ),
        ),
      );

      final themeButton = findAppIcon(AppIcons.moon);
      final notificationsButton = findAppIcon(AppIcons.bell);
      expect(themeButton, findsOneWidget);
      expect(notificationsButton, findsOneWidget);
      expect(
        tester.getCenter(themeButton).dx,
        lessThan(tester.getCenter(notificationsButton).dx),
      );

      await tester.tap(themeButton);
      await tester.pump();

      expect(container.read(themeVariantProvider), AppThemeVariant.gbMode);
      expect(findAppIcon(AppIcons.sun), findsOneWidget);
    });

    testWidgets('toca "Mais" e abre o menu global via shellStoreProvider', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: AppShellHeader()),
          ),
        ),
      );

      expect(container.read(shellStoreProvider).menuOpen, isFalse);

      await tester.tap(findAppIcon(AppIcons.menu));
      await tester.pump();

      expect(container.read(shellStoreProvider).menuOpen, isTrue);
    });

    testWidgets('renderiza o slot de contexto (child) quando informado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppShellHeader(child: Text('slot-de-contexto'))),
      );

      expect(find.text('slot-de-contexto'), findsOneWidget);
    });
  });
}
