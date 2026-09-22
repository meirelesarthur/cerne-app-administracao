import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../../design/generated/app_layout.dart';

/// Padrão de tela "CRUD" (Widgetbook → Padrões) — referência nova: nenhuma
/// tela real do app tem hoje um fluxo completo de criar/editar/excluir um
/// registro. Serve de esqueleto de composição para o primeiro módulo que
/// precisar disso (ex.: estoque do armazém).
///
/// Composição: lista em memória + `AppModal` com formulário (`AppFormField` +
/// `AppTextInput`/`AppFormSelect`) para criar/editar, e confirmação via
/// `AppModal` para excluir. Tudo local (`setState`), sem persistência real.
const _categorias = [
  AppFormSelectOption(value: 'racao', label: 'Ração'),
  AppFormSelectOption(value: 'sementes', label: 'Sementes'),
  AppFormSelectOption(value: 'defensivos', label: 'Defensivos'),
];

class _StockItem {
  const _StockItem({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.quantidade,
  });

  final int id;
  final String nome;
  final String categoria;
  final String quantidade;

  String get categoriaLabel =>
      _categorias.firstWhere((c) => c.value == categoria).label;
}

class _CrudPatternExample extends StatefulWidget {
  const _CrudPatternExample();

  @override
  State<_CrudPatternExample> createState() => _CrudPatternExampleState();
}

class _CrudPatternExampleState extends State<_CrudPatternExample> {
  int _nextId = 3;
  final List<_StockItem> _items = const [
    _StockItem(
      id: 1,
      nome: 'Ração bovina 40kg',
      categoria: 'racao',
      quantidade: '120',
    ),
    _StockItem(
      id: 2,
      nome: 'Semente de soja',
      categoria: 'sementes',
      quantidade: '48',
    ),
  ];

  Future<void> _openForm({_StockItem? editing}) async {
    final result = await showAppModal<_StockItem>(
      context,
      title: editing == null ? 'Novo item' : 'Editar item',
      child: _CrudFormBody(editing: editing),
    );
    if (result == null) return;
    setState(() {
      if (editing == null) {
        _items.add(
          _StockItem(
            id: _nextId++,
            nome: result.nome,
            categoria: result.categoria,
            quantidade: result.quantidade,
          ),
        );
      } else {
        final index = _items.indexWhere((i) => i.id == editing.id);
        _items[index] = _StockItem(
          id: editing.id,
          nome: result.nome,
          categoria: result.categoria,
          quantidade: result.quantidade,
        );
      }
    });
  }

  Future<void> _confirmDelete(_StockItem item) async {
    final confirmed = await showAppModal<bool>(
      context,
      title: 'Excluir item',
      child: Text('Tem certeza de que deseja excluir "${item.nome}"?'),
      footer: AppButton(
        variant: AppButtonVariant.danger,
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Excluir'),
      ),
    );
    if (confirmed == true) {
      setState(() => _items.removeWhere((i) => i.id == item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      color: semantic.bgCanvas,
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppHeading(child: Text('Estoque')),
              AppButton(
                size: AppButtonSize.sm,
                leftIcon: const AppIcon(AppIcons.plus, size: AppSize.iconSm),
                onPressed: () => _openForm(),
                child: const Text('Novo item'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          if (_items.isEmpty)
            AppEmptyState(
              icon: AppIcons.boxes,
              title: 'Nenhum item cadastrado',
              description: 'Adicione o primeiro item ao estoque.',
              action: AppButton(
                onPressed: () => _openForm(),
                child: const Text('Novo item'),
              ),
            )
          else
            for (final item in _items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: semantic.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.xl3),
                    border: Border.all(color: semantic.borderDefault),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.nome,
                              style: TextStyle(
                                fontWeight: AppTypography.weightSemibold,
                                color: semantic.fgDefault,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space1),
                            Wrap(
                              spacing: AppSpacing.space2,
                              children: [
                                AppTag(child: Text(item.categoriaLabel)),
                                Text(
                                  'Qtd.: ${item.quantidade}',
                                  style: TextStyle(color: semantic.fgMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppIconButton(
                        icon: const AppIcon(
                          AppIcons.pencil,
                          size: AppSize.iconSm,
                        ),
                        label: 'Editar ${item.nome}',
                        onPressed: () => _openForm(editing: item),
                      ),
                      AppIconButton(
                        icon: const AppIcon(
                          AppIcons.trash2,
                          size: AppSize.iconSm,
                        ),
                        label: 'Excluir ${item.nome}',
                        onPressed: () => _confirmDelete(item),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Corpo do formulário de criar/editar — devolve um [_StockItem] via
/// `Navigator.pop` (id/categoria default irrelevantes para o `create`;
/// a tela chamadora decide se é inserção ou atualização).
class _CrudFormBody extends StatefulWidget {
  const _CrudFormBody({this.editing});

  final _StockItem? editing;

  @override
  State<_CrudFormBody> createState() => _CrudFormBodyState();
}

class _CrudFormBodyState extends State<_CrudFormBody> {
  late final _nomeController = TextEditingController(
    text: widget.editing?.nome,
  );
  late final _quantidadeController = TextEditingController(
    text: widget.editing?.quantidade,
  );
  String? _categoria;

  @override
  void initState() {
    super.initState();
    _categoria = widget.editing?.categoria;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nomeController.text.trim().isEmpty || _categoria == null) return;
    Navigator.of(context).pop(
      _StockItem(
        id: 0,
        nome: _nomeController.text.trim(),
        categoria: _categoria!,
        quantidade: _quantidadeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
          label: 'Nome',
          required: true,
          child: AppTextInput(
            controller: _nomeController,
            placeholder: 'Ex.: Ração bovina 40kg',
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        AppFormField(
          label: 'Categoria',
          required: true,
          child: AppFormSelect(
            options: _categorias,
            value: _categoria,
            placeholder: 'Selecione',
            onChanged: (v) => setState(() => _categoria = v),
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        AppFormField(
          label: 'Quantidade',
          child: AppTextInput(
            controller: _quantidadeController,
            keyboardType: TextInputType.number,
            placeholder: 'Ex.: 120',
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          fullWidth: true,
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

WidgetbookComponent buildCrudPatternWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'CRUD',
    useCases: [
      WidgetbookUseCase(
        name: 'Exemplo',
        builder: (context) => const _CrudPatternExample(),
      ),
    ],
  );
}
