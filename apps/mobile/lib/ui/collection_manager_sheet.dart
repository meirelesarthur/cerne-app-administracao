import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'bottom_sheet.dart';
import 'button.dart';
import 'collection_list.dart';
import 'empty_state.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Remove o item em `index` e devolve como desfazer a remoção — quem remove
/// é quem guarda o item, então é quem sabe reinseri-lo.
typedef AppCollectionRemove = VoidCallback Function(int index);

/// Abre o gerenciador de uma coleção: o "dentro" de um card de
/// [AppSquareGroupGrid]. Lista os itens incluídos (linha inteira clicável para
/// editar, lixeira para remover com "Desfazer") e deixa "Adicionar" fixo no
/// rodapé, ao alcance do polegar mesmo com 10+ itens.
///
/// [items] e [summary] são funções porque o sheet vive numa rota própria: a
/// cada remoção/desfazer ele relê o estado atual de quem é dono dos itens.
///
/// [onAdd] e [onEdit] devolvem `Future`: o gerenciador fecha, aguarda o
/// formulário e **reabre sozinho** com o item incluído/editado em destaque —
/// a pessoa sempre volta para a lista de onde saiu.
Future<void> showAppCollectionManager(
  BuildContext context, {
  required String title,
  required List<AppCollectionItemView> Function() items,
  String? Function()? summary,
  Future<void> Function()? onAdd,
  Future<void> Function(int index)? onEdit,
  AppCollectionRemove? onRemove,
  String addLabel = 'Adicionar',
}) async {
  int? highlight;
  while (true) {
    if (!context.mounted) return;
    final controller = _ManagerController(onRemove: onRemove);
    final action = await showAppBottomSheet<_ManagerAction>(
      context,
      title: title,
      footer: _ManagerFooter(
        controller: controller,
        addLabel: addLabel,
        canAdd: onAdd != null,
      ),
      child: _ManagerBody(
        controller: controller,
        items: items,
        summary: summary,
        highlightIndex: highlight,
        canEdit: onEdit != null,
      ),
    );
    controller.dispose();
    if (action == null || !context.mounted) return;

    final before = items().length;
    if (action.editIndex case final index?) {
      await onEdit!(index);
      highlight = index;
    } else {
      await onAdd!();
      final after = items().length;
      highlight = after > before ? after - 1 : null;
    }
  }
}

/// Ação escolhida dentro do sheet — fecha o sheet e é executada por
/// [showAppCollectionManager] (adicionar quando [editIndex] é `null`).
class _ManagerAction {
  const _ManagerAction.add() : editIndex = null;
  const _ManagerAction.edit(int this.editIndex);

  final int? editIndex;
}

class _PendingUndo {
  const _PendingUndo({required this.label, required this.undo});

  final String label;
  final VoidCallback undo;
}

/// Estado compartilhado entre o corpo rolável e o rodapé fixo do sheet — a
/// remoção pendente de "Desfazer" aparece no rodapé, junto do "Adicionar".
class _ManagerController extends ChangeNotifier {
  _ManagerController({this.onRemove});

  final AppCollectionRemove? onRemove;
  _PendingUndo? pending;

  void remove(int index, String label) {
    final undo = onRemove!(index);
    pending = _PendingUndo(label: label, undo: undo);
    notifyListeners();
  }

  void undo() {
    pending?.undo();
    pending = null;
    notifyListeners();
  }
}

/// Corpo do gerenciador: contagem por extenso + resumo agregado e a lista.
class _ManagerBody extends StatelessWidget {
  const _ManagerBody({
    required this.controller,
    required this.items,
    required this.canEdit,
    this.summary,
    this.highlightIndex,
  });

  final _ManagerController controller;
  final List<AppCollectionItemView> Function() items;
  final String? Function()? summary;
  final int? highlightIndex;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final current = items();
        final resumo = current.isEmpty ? null : summary?.call();
        // Um desfazer pendente invalida o destaque: os índices mudaram.
        final highlight = controller.pending == null ? highlightIndex : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              [appItemCountLabel(current.length), ?resumo].join(' · '),
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            if (current.isEmpty)
              _EmptyHint(semantic: semantic)
            else
              AppCollectionList(
                name: '',
                showHeader: false,
                items: current,
                highlightIndex: highlight,
                onEdit: canEdit
                    ? (index) =>
                          Navigator.of(context).pop(_ManagerAction.edit(index))
                    : null,
                onRemove: controller.onRemove == null
                    ? null
                    : (index) => controller.remove(index, current[index].title),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.semantic});

  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: semantic.bgCanvas,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: const AppEmptyState(
        size: AppEmptyStateSize.compact,
        icon: AppIcons.layers,
        badgeIcon: AppIcons.plus,
        tone: AppEmptyStateTone.brand,
        title: 'Nenhum item incluído',
        description: 'Use "Adicionar" para incluir o primeiro.',
      ),
    );
  }
}

class _ManagerFooter extends StatelessWidget {
  const _ManagerFooter({
    required this.controller,
    required this.addLabel,
    required this.canAdd,
  });

  final _ManagerController controller;
  final String addLabel;
  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.pending case final pending?) ...[
            Container(
              padding: const EdgeInsets.only(left: AppSpacing.space3),
              decoration: BoxDecoration(
                color: semantic.bgCanvas,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '"${pending.label}" removido',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgDefault,
                      ),
                    ),
                  ),
                  AppButton(
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.link,
                    onPressed: controller.undo,
                    child: const Text('Desfazer'),
                  ),
                ],
              ),
            ),
            if (canAdd) const SizedBox(height: AppSpacing.space3),
          ],
          if (canAdd)
            AppButton(
              leftIcon: const AppIcon(AppIcons.plus, size: AppSize.iconSm),
              onPressed: () =>
                  Navigator.of(context).pop(const _ManagerAction.add()),
              child: Text(addLabel),
            ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildCollectionManagerWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'CollectionManager',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativo (editar, remover, desfazer)',
        builder: (context) => const _ManagerUseCase(initialCount: 2),
      ),
      WidgetbookUseCase(
        name: 'Lista longa (10 itens)',
        builder: (context) => const _ManagerUseCase(initialCount: 10),
      ),
      WidgetbookUseCase(
        name: 'Vazio (após remover tudo)',
        builder: (context) => const _ManagerUseCase(initialCount: 0),
      ),
    ],
  );
}

class _ManagerUseCase extends StatefulWidget {
  const _ManagerUseCase({required this.initialCount});

  final int initialCount;

  @override
  State<_ManagerUseCase> createState() => _ManagerUseCaseState();
}

class _ManagerUseCaseState extends State<_ManagerUseCase> {
  static const _nomes = [
    'José da Silva',
    'Maria Souza',
    'Pedro Almeida',
    'Ana Costa',
    'Carlos Lima',
    'Juliana Rocha',
    'Rafael Dias',
    'Fernanda Melo',
    'Bruno Teixeira',
    'Luana Freitas',
  ];

  late final _items = <(String, int)>[
    for (var i = 0; i < widget.initialCount; i++)
      (_nomes[i % _nomes.length], i + 1),
  ];

  Future<void> _open(BuildContext context) => showAppCollectionManager(
    context,
    title: 'Mão de obra / Serviços',
    items: () => [
      for (final (nome, dias) in _items)
        AppCollectionItemView(
          title: nome,
          subtitle: 'Funcionário · $dias dia(s) · R\$ ${dias * 10},00',
        ),
    ],
    summary: () =>
        'R\$ ${_items.fold<int>(0, (sum, item) => sum + item.$2 * 10)},00',
    onAdd: () async =>
        setState(() => _items.add((_nomes[_items.length % _nomes.length], 1))),
    onEdit: (index) async => setState(
      () => _items[index] = (_items[index].$1, _items[index].$2 + 1),
    ),
    onRemove: (index) {
      final removed = _items.removeAt(index);
      setState(() {});
      return () => setState(() => _items.insert(index, removed));
    },
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(
        builder: (context) => AppButton(
          onPressed: () => _open(context),
          child: Text('Abrir gerenciador (${_items.length} itens)'),
        ),
      ),
    );
  }
}
