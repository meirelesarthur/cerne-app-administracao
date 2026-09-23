import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/ui/app_icon.dart';
import 'package:cerne_app/ui/detail_section.dart';

Widget _wrap(Widget child, {AppThemeVariant variant = AppThemeVariant.light}) =>
    MaterialApp(
      theme: buildAppTheme(variant),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('AppDetailSection', () {
    testWidgets('mostra título, contagem e itens da lista', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppDetailSection(
            icon: AppIcons.tractor,
            title: 'Máquinas',
            count: 2,
            child: AppDetailList(items: ['Trator', 'Pulverizador']),
          ),
        ),
      );

      expect(find.text('Máquinas'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Trator'), findsOneWidget);
      expect(find.text('Pulverizador'), findsOneWidget);
      expect(find.byType(AppIcon), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('lista vazia mostra o texto de ausência', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppDetailSection(
            icon: AppIcons.users,
            title: 'Mão de obra',
            child: AppDetailList(items: []),
          ),
        ),
      );

      expect(find.text('Nada informado.'), findsOneWidget);
    });

    testWidgets('campos em duas colunas com contagem ímpar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppDetailSection(
            icon: AppIcons.ordemServico,
            title: 'Serviço',
            tone: AppDetailSectionTone.warning,
            child: AppDetailFields(
              columns: 2,
              fields: [
                AppDetailField(label: 'Prazo', value: '25/09/2026'),
                AppDetailField(label: 'Prioridade', value: 'Alta'),
                AppDetailField(
                  label: 'Tipo',
                  value: 'Pulverização',
                  caption: 'Apoio',
                ),
              ],
            ),
          ),
          variant: AppThemeVariant.gbMode,
        ),
      );

      final prazo = tester.getTopLeft(find.text('Prazo'));
      final prioridade = tester.getTopLeft(find.text('Prioridade'));
      expect(prazo.dy, prioridade.dy);
      expect(prioridade.dx, greaterThan(prazo.dx));
      expect(find.text('Apoio'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
