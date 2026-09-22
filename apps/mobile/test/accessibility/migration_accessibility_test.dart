import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/screens/mapped_feature_screen.dart';
import 'package:cerne_app/modules/fazendas/screens/responsibility_workspace.dart';
import 'package:cerne_app/ui/ui.dart';

import '../support/router_test_harness.dart';

Future<void> _setViewport(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.devicePixelRatio = 1;
  addTearDown(() async {
    tester.view.resetDevicePixelRatio();
    await tester.binding.setSurfaceSize(null);
  });
}

Widget _app(Widget child) => MaterialApp(
  theme: buildAppTheme(AppThemeVariant.light),
  home: Scaffold(body: child),
);

void main() {
  group('M9 — acessibilidade compartilhada', () {
    testWidgets('controles interativos atendem alvo mínimo e rótulos', (
      tester,
    ) async {
      await _setViewport(tester, const Size(390, 844));
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        _app(
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  size: AppButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Pequeno'),
                ),
                AppButton(
                  variant: AppButtonVariant.link,
                  onPressed: () {},
                  child: const Text('Link acessível'),
                ),
                AppIconButton(
                  icon: const AppIcon(AppIcons.plus),
                  label: 'Adicionar item',
                  size: AppIconButtonSize.sm,
                  onPressed: () {},
                ),
                AppCheckbox(
                  checked: false,
                  label: 'Selecionar registro',
                  onChanged: (_) {},
                ),
                AppToggleSwitch(
                  checked: false,
                  label: 'Ativar alertas',
                  onChanged: (_) {},
                ),
                AppPageDots(count: 3, active: 0, onSelect: (_) {}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
    });

    testWidgets('formulário expõe rótulo contextual obrigatório', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const AppFormField(
            label: 'Nome da área',
            required: true,
            child: AppTextInput(placeholder: 'Ex.: Talhão 01'),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Nome da área, obrigatório')),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('link, campo e botão são operáveis em ordem por teclado', (
      tester,
    ) async {
      var linkActivated = false;
      var buttonActivated = false;
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              AppButton(
                variant: AppButtonVariant.link,
                onPressed: () => linkActivated = true,
                child: const Text('Ajuda'),
              ),
              const AppTextInput(placeholder: 'Nome'),
              AppButton(
                onPressed: () => buttonActivated = true,
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(linkActivated, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focusedWidget = FocusManager.instance.primaryFocus?.context?.widget;
      expect(focusedWidget, isA<Focus>());
      expect((focusedWidget! as Focus).debugLabel, 'EditableText');

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(buttonActivated, isTrue);
    });
  });

  group('M9 — viewports críticos', () {
    testWidgets('login cabe em 390×844 e mantém alvos acessíveis', (
      tester,
    ) async {
      await _setViewport(tester, const Size(390, 844));
      final semantics = tester.ensureSemantics();
      final harness = RouterTestHarness();
      addTearDown(harness.dispose);
      harness.router.go('/login');

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Login Administração'), findsNothing);
      expect(find.text('Login Operacional'), findsNothing);
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
    });

    testWidgets('jornadas críticas não causam overflow em 390×844', (
      tester,
    ) async {
      await _setViewport(tester, const Size(390, 844));
      final container = ProviderContainer();
      addTearDown(container.dispose);

      for (final feature in [
        ('saldo-estoque', FeatureProfile.administration),
        ('exportar-log-estoque', FeatureProfile.administration),
      ]) {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _app(
              MappedFeatureScreen(featureId: feature.$1, profile: feature.$2),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: feature.$1);
      }
    });

    testWidgets('centrais usam layout largo sem overflow', (tester) async {
      await _setViewport(tester, const Size(1024, 844));
      // A central lê a fazenda ativa para o seletor de contexto do padrão
      // global (E7), então precisa do escopo do Riverpod.
      await tester.pumpWidget(
        ProviderScope(
          child: _app(
            const ResponsibilityWorkspace(
              profile: FeatureProfile.administration,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Central de gestão'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
