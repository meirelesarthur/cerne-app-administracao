import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_confinamento.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashConfinamento', () {
    testWidgets('renderiza sem exceção e abre a aba Mapa', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashConfinamento()));
      await tester.pumpAndSettle();

      expect(find.text('Rebanho & Confinamento'), findsOneWidget);
      expect(find.text('Visão geral'), findsOneWidget);

      await tester.tap(find.text('Mapa'));
      await tester.pumpAndSettle();

      expect(find.text('Curral 01'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a visão geral traz o desempenho que a Pecuária não tinha', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashConfinamento()));
      await tester.pumpAndSettle();

      // O painel de Pecuária mostrava "—" em produtivo/reprodutivo; aqui o GMD
      // observado × previsto vem de IndicadoresLote.
      expect(find.text('GMD médio'), findsOneWidget);
      expect(find.text('Ocupação e desempenho'), findsOneWidget);
      expect(find.text('GMD por curral'), findsOneWidget);
      expect(find.text('Situação dos currais'), findsOneWidget);
      expect(find.text('—'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('permite detalhar a visão geral por curral', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashConfinamento()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Curral 01').last);
      await tester.pumpAndSettle();

      expect(
        find.text('Indicadores e gráficos filtrados por este curral.'),
        findsOneWidget,
      );
      expect(find.text('Curral 01'), findsWidgets);
      expect(find.text('Curral 02'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('abre o detalhe de um curral ao tocar', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const DashConfinamento()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mapa'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Curral 01'));
      await tester.pumpAndSettle();

      // O rótulo do campo de leitura aparece em versalete (`AppReviewList`).
      expect(find.text('SITUAÇÃO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
