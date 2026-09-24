import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_ordem_servico.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/screens/os_create_page.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/screens/os_detail_page.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashOrdemServico', () {
    testWidgets('lista as OS da fazenda e oferece a criação de uma nova', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      expect(find.byType(OsCriarButton), findsOneWidget);
      expect(find.byTooltip('Criar OS'), findsOneWidget);
      expect(find.text('Reparo de cerca do Talhão 04'), findsOneWidget);
      expect(
        find.text('Construção de bebedouro no Piquete 07'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtra por status via as abas segmentadas', (tester) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AppSegmentedTabs),
          matching: find.text('Aguardando'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reparo de cerca do Talhão 04'), findsOneWidget);
      expect(find.text('Construção de bebedouro no Piquete 07'), findsNothing);
    });

    testWidgets('filtra por data de prazo e permite limpar o filtro', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      // Nenhum mock tem prazo hoje — o filtro "Hoje" deve esvaziar a lista.
      await tester.tap(find.text('Hoje'));
      await tester.pumpAndSettle();

      expect(find.text('Reparo de cerca do Talhão 04'), findsNothing);
      expect(find.text('Nenhuma OS encontrada'), findsOneWidget);

      await tester.tap(find.text('Todas as datas'));
      await tester.pumpAndSettle();

      expect(find.text('Reparo de cerca do Talhão 04'), findsOneWidget);
    });

    testWidgets('cria uma nova OS pelo formulário em tela cheia', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OsCriarButton));
      await tester.pumpAndSettle();

      expect(find.byType(OsCreatePage), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);

      await tester.enterText(
        find.byType(AppTextInput).at(0),
        'Reparo do moinho de vento',
      );
      await tester.enterText(find.byType(AppTextInput).at(1), 'Pasto 12');
      await tester.enterText(find.byType(AppDateInput).last, '30/12/2026');
      await tester.enterText(
        find.byType(AppTextarea),
        'Substituir a hélice do moinho danificada pelo vento forte.',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CRIAR OS'));
      await tester.pumpAndSettle();

      // Criar troca a tela pelo detalhe da OS nova — a confirmação visível.
      expect(find.byType(OsCreatePage), findsNothing);
      expect(find.byType(OsDetailPage), findsOneWidget);
      expect(find.textContaining('Reparo do moinho de vento'), findsWidgets);

      await tester.tap(find.byTooltip('Voltar').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Reparo do moinho de vento'), findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.textContaining('Reparo do moinho de vento'),
            matching: find.byType(AppStatusCard),
          ),
          matching: find.text('Aguardando'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('abre o detalhe em tela cheia com avaliar e cancelar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Reparo de cerca do Talhão 04'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reparo de cerca do Talhão 04'));
      await tester.pumpAndSettle();

      expect(find.byType(OsDetailPage), findsOneWidget);
      expect(find.text('Serviço'), findsOneWidget);
      expect(find.text('AVALIAR'), findsOneWidget);
      expect(find.text('CANCELAR OS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancelar mantém o detalhe aberto e tira as ações do rodapé', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Reparo de cerca do Talhão 04'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reparo de cerca do Talhão 04'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CANCELAR OS'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(AppTextarea), 'Serviço terceirizado');
      await tester.tap(find.text('Confirmar cancelamento'));
      await tester.pumpAndSettle();

      // Ação sem volta: pede a confirmação final antes de cancelar.
      expect(find.text('Cancelar a OS #2201 de vez?'), findsOneWidget);
      await tester.tap(find.text('Cancelar OS'));
      await tester.pumpAndSettle();

      expect(find.byType(OsDetailPage), findsOneWidget);
      expect(find.text('Motivo do cancelamento'), findsOneWidget);
      expect(find.text('CANCELAR OS'), findsNothing);
      expect(find.text('AVALIAR'), findsNothing);
    });

    testWidgets('enviar a OS vazia mostra o erro em cada campo', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OsCriarButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CRIAR OS'));
      await tester.pumpAndSettle();

      expect(find.byType(OsCreatePage), findsOneWidget);
      expect(
        find.text('Revise os 4 campos destacados para criar a OS.'),
        findsOneWidget,
      );
      expect(find.text('Preencha o campo "Título".'), findsOneWidget);
      expect(find.text('Informe a data em "Prazo".'), findsOneWidget);
    });

    testWidgets('prazo no passado ou impossível não é aceito', (tester) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OsCriarButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(AppDateInput), '01/01/2020');
      await tester.tap(find.text('CRIAR OS'));
      await tester.pumpAndSettle();
      expect(
        find.text('O prazo não pode ser anterior a hoje.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(AppDateInput), '31/02/2030');
      await tester.pumpAndSettle();
      expect(
        find.text('Data inválida. Use o formato DD/MM/AAAA.'),
        findsOneWidget,
      );
    });

    testWidgets('voltar com dados preenchidos pergunta antes de descartar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OsCriarButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(AppTextInput).first, 'Rascunho');
      await tester.pump();
      await tester.tap(find.byTooltip('Voltar').last);
      await tester.pumpAndSettle();

      expect(find.text('Sair sem salvar?'), findsOneWidget);
    });

    testWidgets('lista só as OS da fazenda ativa', (tester) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      // Fazenda padrão (São Pedro): a vacinação é da Santa Rita.
      expect(find.text('Vacinação contra aftosa — Lote 12'), findsNothing);
      expect(find.text('Reparo de cerca do Talhão 04'), findsOneWidget);
    });
  });
}
