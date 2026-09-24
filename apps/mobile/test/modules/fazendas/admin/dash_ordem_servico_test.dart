import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_ordem_servico.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/screens/os_create_page.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/screens/os_detail_page.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../helpers/cta_finder.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

Finder _selectField(String label) => find.byWidgetPredicate(
  (widget) => widget is AppSearchSelect && widget.label == label,
);

Future<void> _chooseSearch(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = _selectField(label);
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

Future<void> _chooseDropdown(WidgetTester tester, String value) async {
  await tester.tap(find.byType(AppFormSelect).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value, {
  Type control = AppTextInput,
}) async {
  final formField = find.ancestor(
    of: find.text(label),
    matching: find.byType(AppFormField),
  ).first;
  final input = find.descendant(
    of: formField,
    matching: find.byType(control),
  ).first;
  await tester.ensureVisible(input);
  await tester.enterText(input, value);
  await tester.pumpAndSettle();
}

Future<void> _continue(WidgetTester tester) async {
  await tester.tap(find.text('CONTINUAR'));
  await tester.pumpAndSettle();
}

Future<void> _fillIdentity(WidgetTester tester) async {
  await _chooseSearch(
    tester,
    'Responsável pela execução',
    'João Oliveira',
  );
  await tester.enterText(find.byType(AppDateInput).last, '30/12/2026');
  await _continue(tester);
}

Future<void> _openNewOs(WidgetTester tester) async {
  await tester.pumpWidget(_wrap(const DashOrdemServico()));
  await tester.pumpAndSettle();
  await tester.tap(findCta('+ Nova O.S'));
  await tester.pumpAndSettle();
}

Future<void> _fillEarlierOsSteps(WidgetTester tester) async {
  await _fillIdentity(tester);

  await _chooseDropdown(tester, 'Agricultura');
  await _chooseSearch(tester, 'Operação', 'Preparo do Solo');
  await _chooseSearch(tester, 'Atividade', 'Aração');
  await _continue(tester);

  await _chooseSearch(tester, 'Área / talhão', 'Talhão 01 — Sede');
  await _chooseSearch(
    tester,
    'Cultura / variedade',
    'Soja — TMG 2383',
  );
  await _continue(tester);

  await _enterField(
    tester,
    'Requisitos climáticos',
    'Não aplicar com vento forte.',
    control: AppTextarea,
  );
  await _enterField(tester, 'Temperatura mínima (°C)', '18');
  await _enterField(tester, 'Temperatura máxima (°C)', '30');
  await _enterField(tester, 'Horário permitido — início', '06:00');
  await _enterField(tester, 'Horário permitido — fim', '18:00');
  await _continue(tester);

  await _enterField(
    tester,
    'Descrição do serviço',
    'Aplicar fertilizante no talhão.',
    control: AppTextarea,
  );
  await _enterField(
    tester,
    'Resultados esperados',
    'Adubação uniforme.',
    control: AppTextarea,
  );
  await _enterField(
    tester,
    'Critérios de sucesso',
    'Toda a área coberta.',
    control: AppTextarea,
  );
  await _enterField(
    tester,
    'Roteiro / planejamento',
    'Calibrar e percorrer as linhas.',
    control: AppTextarea,
  );
  await _continue(tester);

  await _enterField(
    tester,
    'Restrições ambientais',
    'Não operar próximo a cursos d’água.',
    control: AppTextarea,
  );
  await _enterField(
    tester,
    'Conformidade legal',
    'Usar produto registrado e seguir a bula.',
    control: AppTextarea,
  );
  await _continue(tester);
}

Future<void> _addResource(WidgetTester tester, String group) async {
  final card = find.text(group).last;
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();

  switch (group) {
    case 'MO / Serviços':
      await _chooseDropdown(tester, 'Funcionário');
      await _chooseSearch(tester, 'Executor', 'João Oliveira');
      break;
    case 'Máq. / Implementos':
      await _chooseSearch(
        tester,
        'Máquina / implemento / veículo',
        'Trator John Deere 6110',
      );
      break;
    case 'Insumos':
      await _chooseSearch(tester, 'Armazém', 'Depósito B');
      await _chooseSearch(
        tester,
        'Produto com saldo',
        'Fertilizante NPK 20-05-20',
      );
      await _enterField(tester, 'Quantidade por hectare', '2');
      await _enterField(tester, 'Quantidade total', '84');
      break;
    case 'Produção':
      await _chooseSearch(
        tester,
        'Armazém de produção',
        'Armazém de Grãos',
      );
      await _chooseSearch(tester, 'Produto gerado', 'Soja em grão');
      await _enterField(tester, 'Quantidade', '120');
      break;
    case 'EPI':
      await _chooseSearch(tester, 'Produto de proteção', 'Óculos de proteção');
      break;
  }
  await tester.tap(find.text('Salvar item'));
  await tester.pumpAndSettle();
}

Future<void> _editRemoveAndUndoResource(
  WidgetTester tester,
  String group,
  String itemTitle,
) async {
  final card = find.text(group).last;
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();

  await tester.tap(find.byTooltip('Editar item').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Salvar item'));
  await tester.pumpAndSettle();

  await tester.tap(find.byTooltip('Remover item').last);
  await tester.pumpAndSettle();
  expect(find.text('"$itemTitle" removido'), findsOneWidget);
  await tester.tap(find.text('Desfazer'));
  await tester.pumpAndSettle();
  expect(find.text(itemTitle), findsOneWidget);

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  group('DashOrdemServico', () {
    testWidgets('lista as OS da fazenda e oferece a criação de uma nova', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      expect(findCta('+ Nova O.S'), findsOneWidget);
      expect(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
        findsOneWidget,
      );
      expect(
        find.text('Manutenções de Currais — Curral de manejo 1'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtra por status via as abas segmentadas', (tester) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      // Nenhuma OS da fazenda ativa está encerrada — o filtro esvazia a lista.
      await tester.tap(find.byType(AppInlineSelect));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Encerradas'));
      await tester.pumpAndSettle();

      expect(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
        findsNothing,
      );
      expect(find.text('Nenhuma OS encontrada'), findsOneWidget);
    });

    testWidgets('filtra por data de prazo e permite limpar o filtro', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      // Só a OS #2207 tem prazo hoje — e como o card mostra o prazo por
      // extenso ("Hoje"), o texto sozinho já é ambíguo com o botão do
      // filtro antes mesmo de tocar nele.
      await tester.tap(find.widgetWithText(AppButton, 'Hoje'));
      await tester.pumpAndSettle();

      expect(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
        findsNothing,
      );
      expect(
        find.text('Manutenções de Construções — Curral 12'),
        findsOneWidget,
      );

      await tester.tap(find.text('Todas as datas'));
      await tester.pumpAndSettle();

      expect(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
        findsOneWidget,
      );
    });

    testWidgets('cria uma nova OS pelo formulário em tela cheia', (
      tester,
    ) async {
      await _openNewOs(tester);

      expect(find.byType(OsCreatePage), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.textContaining('Etapa 1 de 7'), findsOneWidget);

      await _fillEarlierOsSteps(tester);
      for (final group in [
        'MO / Serviços',
        'Máq. / Implementos',
        'Insumos',
        'Produção',
        'EPI',
      ]) {
        await _addResource(tester, group);
      }

      await tester.tap(find.text('CRIAR OS'));
      await tester.pumpAndSettle();

      // Criar troca a tela pelo detalhe da OS nova — a confirmação visível.
      expect(find.byType(OsCreatePage), findsNothing);
      expect(find.byType(OsDetailPage), findsOneWidget);
      expect(find.textContaining('Aração'), findsWidgets);
      expect(find.textContaining('Aplicar fertilizante no talhão.'), findsWidgets);

      await tester.tap(find.byTooltip('Voltar').last);
      await tester.pumpAndSettle();
      const tituloNovaOs = 'Aração — Soja — TMG 2383';
      expect(find.text(tituloNovaOs), findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text(tituloNovaOs),
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

      await tester.ensureVisible(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
      );
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

      await tester.ensureVisible(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
      );
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

    testWidgets('continuar a etapa de identificação vazia mostra os erros', (
      tester,
    ) async {
      await _openNewOs(tester);

      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();

      expect(find.byType(OsCreatePage), findsOneWidget);
      expect(
        find.text('Revise os 2 campos destacados para continuar.'),
        findsOneWidget,
      );
      expect(find.text('Preencha o campo "Responsável".'), findsOneWidget);
      expect(find.text('Informe a data em "Prazo".'), findsOneWidget);
    });

    testWidgets('prazo no passado ou impossível não é aceito', (tester) async {
      await _openNewOs(tester);
      await _chooseSearch(
        tester,
        'Responsável pela execução',
        'João Oliveira',
      );

      await tester.enterText(find.byType(AppDateInput).last, '01/01/2020');
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();
      expect(
        find.text('O prazo não pode ser anterior a hoje.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(AppDateInput).last, '31/02/2030');
      await tester.pumpAndSettle();
      expect(
        find.text('Data inválida. Use o formato DD/MM/AAAA.'),
        findsOneWidget,
      );
    });

    testWidgets('voltar com dados preenchidos pergunta antes de descartar', (
      tester,
    ) async {
      await _openNewOs(tester);
      await _chooseSearch(
        tester,
        'Responsável pela execução',
        'João Oliveira',
      );
      await tester.tap(find.byTooltip('Voltar').last);
      await tester.pumpAndSettle();

      expect(find.text('Sair sem salvar?'), findsOneWidget);
    });

    testWidgets('Uso filtra operações e operação limpa a atividade filha', (
      tester,
    ) async {
      await _openNewOs(tester);
      await _fillIdentity(tester);
      await _chooseDropdown(tester, 'Agricultura');

      await tester.tap(_selectField('Operação'));
      await tester.pumpAndSettle();
      expect(find.text('Manejo Sanitário'), findsNothing);
      await tester.tap(find.text('Preparo do Solo').last);
      await tester.pumpAndSettle();
      await _chooseSearch(tester, 'Atividade', 'Aração');

      await _chooseDropdown(tester, 'Pecuária');
      expect(find.text('Selecionar operação'), findsOneWidget);
      expect(find.text('Escolha a operação primeiro'), findsOneWidget);
      await _chooseSearch(tester, 'Operação', 'Manejo Sanitário');
      await tester.tap(_selectField('Atividade'));
      await tester.pumpAndSettle();
      expect(find.text('Aração'), findsNothing);
      await tester.tap(find.text('Vacinação').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Uso habilita cultura ou lote e categoria zootécnica', (
      tester,
    ) async {
      await _openNewOs(tester);
      await _fillIdentity(tester);
      await _chooseDropdown(tester, 'Agricultura');
      await _chooseSearch(tester, 'Operação', 'Preparo do Solo');
      await _chooseSearch(tester, 'Atividade', 'Aração');
      await _continue(tester);

      expect(
        tester.widget<AppSearchSelect>(_selectField('Cultura / variedade')).enabled,
        isTrue,
      );
      expect(tester.widget<AppSearchSelect>(_selectField('Lote')).enabled, isFalse);
      expect(
        tester.widget<AppSearchSelect>(_selectField('Categoria zootécnica')).enabled,
        isFalse,
      );

      await tester.tap(find.text('ETAPA ANTERIOR'));
      await tester.pumpAndSettle();
      await _chooseDropdown(tester, 'Pecuária');
      await _chooseSearch(tester, 'Operação', 'Manejo Sanitário');
      await _chooseSearch(tester, 'Atividade', 'Vacinação');
      await _continue(tester);
      await _chooseSearch(tester, 'Lote', 'Lote 12 — Recria');

      expect(
        tester.widget<AppSearchSelect>(_selectField('Cultura / variedade')).enabled,
        isFalse,
      );
      expect(tester.widget<AppSearchSelect>(_selectField('Lote')).enabled, isTrue);
      expect(
        tester.widget<AppSearchSelect>(_selectField('Categoria zootécnica')).enabled,
        isTrue,
      );
    });

    testWidgets('as cinco coleções permitem adicionar, editar, remover e desfazer', (
      tester,
    ) async {
      await _openNewOs(tester);
      await _fillEarlierOsSteps(tester);

      for (final (group, title) in [
        ('MO / Serviços', 'João Oliveira'),
        ('Máq. / Implementos', 'Trator John Deere 6110'),
        ('Insumos', 'Fertilizante NPK 20-05-20'),
        ('Produção', 'Soja em grão'),
        ('EPI', 'Óculos de proteção'),
      ]) {
        await _addResource(tester, group);
        await _editRemoveAndUndoResource(tester, group, title);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('lista só as OS da fazenda ativa', (tester) async {
      await tester.pumpWidget(_wrap(const DashOrdemServico()));
      await tester.pumpAndSettle();

      // Fazenda padrão (São Pedro): a vacinação é da Santa Rita.
      expect(find.text('Vacinação — Lote 12 - Recria'), findsNothing);
      expect(
        find.text('Construção de Cercas — Lote 04 - Novilhas Recria'),
        findsOneWidget,
      );
    });
  });
}
