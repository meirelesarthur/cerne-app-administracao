import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/armazem/components/unidade_detail_sheet.dart';
import 'package:cerne_app/modules/armazem/mocks/estoque_mocks.dart';

const _unidade = Unidade(
  id: 'un-3',
  nome: 'Galpão de insumos',
  produto: 'Fertilizantes e defensivos',
  capacidade: '3.500 t',
  ocupacaoPct: 58,
  status: UnidadeStatus.ok,
  endereco: 'Av. dos Agricultores, 1200 — Rio Verde/GO',
);

GoRouter _buildRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showUnidadeDetailSheet(context, unidade: _unidade),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/armazem/estoque',
      builder: (context, state) =>
          const Scaffold(body: Text('Estoque filtrado')),
    ),
  ],
);

void main() {
  group('showUnidadeDetailSheet', () {
    testWidgets('abre com nome, chip de status, ocupação e endereço', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: _buildRouter(),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Detalhe da unidade'), findsOneWidget);
      expect(find.text('Galpão de insumos'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('58% de 3.500 t'), findsOneWidget);
      expect(
        find.text('Av. dos Agricultores, 1200 — Rio Verde/GO'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('lista os produtos armazenados na unidade', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: _buildRouter(),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('PRODUTOS ARMAZENADOS'), findsOneWidget);
      expect(find.text('Fertilizante NPK'), findsOneWidget);
      expect(find.text('Defensivos agrícolas'), findsOneWidget);
      expect(find.text('Ração bovina'), findsOneWidget);
    });

    testWidgets('"Ver estoque da unidade" navega para /armazem/estoque', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildAppTheme(AppThemeVariant.light),
          routerConfig: _buildRouter(),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver estoque da unidade'));
      await tester.pumpAndSettle();

      expect(find.text('Estoque filtrado'), findsOneWidget);
    });
  });
}
