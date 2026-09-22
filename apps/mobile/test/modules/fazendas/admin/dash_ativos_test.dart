import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_ativos.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashAtivos', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashAtivos()));
      await tester.pumpAndSettle();

      expect(find.text('Ativos & Manutenção'), findsWidgets);
      expect(find.text('Patrimônio por categoria'), findsOneWidget);
      expect(find.text('Vida útil consumida'), findsOneWidget);
      // "Equipamentos" é tanto o título da seção quanto a categoria do mock
      // `Balança de Curral` — aparece 2x.
      expect(find.text('Equipamentos'), findsWidgets);
      expect(find.text('Trator John Deere 6110'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('abre o detalhe de um ativo ao tocar', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashAtivos()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trator John Deere 6110'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe do ativo'), findsOneWidget);
      // O rótulo do campo de leitura aparece em versalete (`AppReviewList`).
      expect(find.text('VALOR DE AQUISIÇÃO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('aplica o ativo escolhido aos indicadores e à lista', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashAtivos()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trator John Deere 6110').last);
      await tester.pumpAndSettle();

      expect(find.text('Equipamento selecionado'), findsOneWidget);
      expect(find.text('Trator John Deere 6110'), findsWidgets);
      expect(find.text('Colheitadeira CR7'), findsNothing);
      expect(find.text('R\$ 380 mil'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
