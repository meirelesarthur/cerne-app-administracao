import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/credito/credito_module.dart';

import '../../support/test_viewport.dart';

Widget _wrap(String id) {
  final router = GoRouter(
    initialLocation: '/credito/proposta/$id',
    routes: [buildCreditoModuleRoute()],
  );
  return MaterialApp.router(
    theme: buildAppTheme(AppThemeVariant.light),
    routerConfig: router,
  );
}

void main() {
  group('PropostaDetalheScreen', () {
    testWidgets(
      'proposta em análise mostra timeline, dados, documentos e CTA de aguardando',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(_wrap('prop1'));
        await tester.pumpAndSettle();

        expect(find.text('Custeio Safra 25/26'), findsWidgets);
        expect(find.text('R\$ 250.000,00'), findsWidgets);
        expect(find.text('Em análise'), findsWidgets);
        expect(find.text('Andamento'), findsOneWidget);
        expect(find.text('Dados da proposta'), findsOneWidget);
        expect(find.text('Documentos'), findsOneWidget);
        expect(find.text('Matrícula do imóvel rural'), findsOneWidget);
        expect(find.text('Pendente'), findsOneWidget);
        expect(find.text('Aguardando análise'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('proposta recusada mostra CTA "Simular novamente"', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap('prop4'));
      await tester.pumpAndSettle();

      expect(find.text('Recusada'), findsWidgets);
      expect(find.text('Simular novamente'), findsOneWidget);
    });

    testWidgets('proposta contratada mostra CTA "Ver contratos"', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap('prop3'));
      await tester.pumpAndSettle();

      expect(find.text('Contratada'), findsWidgets);
      expect(find.text('Ver contratos'), findsOneWidget);
    });

    testWidgets(
      'id inexistente mostra o EmptyState de proposta não encontrada',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(_wrap('inexistente'));
        await tester.pumpAndSettle();

        expect(find.text('Proposta não encontrada'), findsOneWidget);
        expect(find.text('Ver todas as propostas'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('botão do EmptyState navega para a listagem de propostas', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap('inexistente'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver todas as propostas'));
      await tester.pumpAndSettle();

      expect(find.text('Minhas propostas'), findsOneWidget);
    });
  });
}
