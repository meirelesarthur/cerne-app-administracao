import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/mocks.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/widgets.dart';

void main() {
  final os = ordensServico.firstWhere((o) => o.id == 'os-2198');

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(
        body: SingleChildScrollView(child: OsDetailBody(os: os)),
      ),
    ),
  );

  testWidgets('abre em Detalhes, com os agrupadores e sem o histórico', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Serviço'), findsOneWidget);
    expect(find.text('Solicitação e autorização'), findsOneWidget);
    expect(find.text('Segurança e sustentabilidade'), findsOneWidget);
    expect(find.text('OS solicitada'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a aba Histórico mostra os eventos, o mais recente primeiro', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Histórico (${os.historico.length})'));
    await tester.pumpAndSettle();

    expect(find.text('Solicitação e autorização'), findsNothing);
    final recente = tester.getTopLeft(find.text(os.historico.last.acao));
    final antigo = tester.getTopLeft(find.text(os.historico.first.acao));
    expect(recente.dy, lessThan(antigo.dy));
  });

  testWidgets(
    'evento do histórico com observação abre o texto completo ao tocar',
    (tester) async {
      await pump(tester);
      await tester.tap(find.text('Histórico (${os.historico.length})'));
      await tester.pumpAndSettle();

      final evento = os.historico.firstWhere((e) => e.observacao != null);

      await tester.tap(find.text(evento.acao));
      await tester.pumpAndSettle();

      // O texto completo da observação só existe na folha — a legenda da
      // lista está truncada e não o mostra por inteiro.
      expect(find.text(evento.observacao!), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mostra a avaliação do administrativo quando registrada', (
    tester,
  ) async {
    await pump(tester);

    final avaliacao = os.avaliacao!;
    expect(find.text('Avaliação do administrativo'), findsOneWidget);
    expect(find.text('${avaliacao.nota}/5'), findsOneWidget);
    expect(find.text(avaliacao.comentario), findsOneWidget);
  });
}
