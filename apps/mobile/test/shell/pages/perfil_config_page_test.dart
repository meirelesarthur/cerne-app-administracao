import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

import '../../support/router_test_harness.dart';
import '../../support/test_viewport.dart';

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness(profile: UserAccessProfile.administration);
    addTearDown(harness.dispose);
    harness.router.go('/perfil');
  });

  group('PerfilConfigPage', () {
    testWidgets('mostra o usuário do shellStore sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Silvio Ventura'), findsOneWidget);
      expect(find.text('Informações pessoais'), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('não mostra "Ver perfil" nem a completude do perfil', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('Ver perfil'), findsNothing);
      expect(find.text('Perfil completo'), findsNothing);
      expect(find.text('75%'), findsNothing);
    });

    testWidgets(
      '"Informações pessoais" abre os dados pessoais e salva o nome',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Informações pessoais'));
        await tester.pumpAndSettle();

        expect(find.text('Dados pessoais'), findsOneWidget);
        expect(find.text('Alterar foto'), findsOneWidget);
        expect(find.text('JPG, PNG, WebP ou GIF — até 5 MB.'), findsOneWidget);
        expect(find.text('silvio.ventura@gbcerne.app'), findsOneWidget);
        expect(
          find.text('O e-mail de acesso não pode ser alterado nesta tela.'),
          findsOneWidget,
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Silvio Ventura'),
          'Ana Paula Souza',
        );
        await tester.pump();
        await tester.tap(find.text('SALVAR ALTERAÇÕES'));
        await tester.pumpAndSettle();

        expect(find.text('Alterações salvas.'), findsOneWidget);
        expect(
          harness.container.read(shellStoreProvider).user.name,
          'Ana Paula Souza',
        );
        expect(harness.container.read(shellStoreProvider).user.initials, 'AS');
      },
    );

    testWidgets('"Segurança" abre a troca de senha e valida o formulário', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Em breve'), findsOneWidget);
      await tester.tap(find.text('Segurança'));
      await tester.pumpAndSettle();

      expect(find.text('Senha atual'), findsOneWidget);
      expect(find.text('Nova senha'), findsOneWidget);
      expect(find.text('Confirmar nova senha'), findsOneWidget);
      expect(
        find.text('Mínimo 6 caracteres, diferente da senha atual.'),
        findsOneWidget,
      );

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'senha123');
      await tester.enterText(campos.at(1), 'senha123');
      await tester.enterText(campos.at(2), 'outra123');
      await tester.tap(find.text('ALTERAR SENHA'));
      await tester.pumpAndSettle();

      expect(
        find.text('A nova senha deve ser diferente da atual.'),
        findsOneWidget,
      );
      expect(find.text('As senhas não coincidem.'), findsOneWidget);

      await tester.enterText(campos.at(1), 'novaSenha1');
      await tester.enterText(campos.at(2), 'novaSenha1');
      await tester.tap(find.text('ALTERAR SENHA'));
      await tester.pumpAndSettle();

      expect(find.text('Senha alterada com sucesso.'), findsOneWidget);
    });

    testWidgets('tocar em "Tema" alterna o themeVariantProvider', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(
        harness.container.read(themeVariantProvider),
        AppThemeVariant.light,
      );

      await tester.tap(find.text('Tema'));
      await tester.pump();

      expect(
        harness.container.read(themeVariantProvider),
        AppThemeVariant.gbMode,
      );
    });

    testWidgets('tocar em "Sair" navega para o login', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(find.text('ENTRAR'), findsOneWidget);
      expect(find.text('Acesso administrativo'), findsOneWidget);
      expect(
        harness.container.read(prototypeSessionProvider).isAuthenticated,
        isFalse,
      );
    });

    testWidgets('tocar em "Notificações" navega para a tela de notificações', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notificações'));
      await tester.pumpAndSettle();

      expect(find.text('Pesagem registrada'), findsOneWidget);
    });
  });
}
