import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'addable_group_list.dart';
import 'app_icon.dart';
import 'icon_button.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Rótulo de contagem de uma coleção, sempre por extenso e no plural certo
/// ("1 item incluído", "3 itens incluídos"). Um número solto num canto é lido
/// como notificação; o rótulo diz o que é contado.
String appItemCountLabel(int count) =>
    count == 1 ? '1 item incluído' : '$count itens incluídos';

/// Uma linha já adicionada a uma coleção, do ponto de vista da tela: um título
/// e um resumo. Quem monta os dois textos é quem conhece o domínio.
class AppCollectionItemView {
  const AppCollectionItemView({required this.title, this.subtitle});

  final String title;
  final String? subtitle;
}

/// Uma coleção de itens de um cadastro — a faixa "Adicionar" seguida das
/// linhas já lançadas, cada uma em sua própria caixa, editável e removível.
///
/// Compõe [AppAddableGroupList] em vez de redesenhar a faixa: o cabeçalho
/// (nome, "N item(ns) adicionado(s)", contador e botão) é o mesmo pixel, e
/// esta classe acrescenta só o que faltava — **as linhas do que foi
/// adicionado**. Era o pedaço que cada tela reimplementava por conta
/// (`_ItemRow` em `apontamento_flow.dart`) e que o motor genérico de cadastros
/// não tinha, o que obrigava toda coleção a viver como um contador cego.
///
/// Sem [onAdd] (`null`) a faixa de ação também some — sobra só o nome da
/// coleção como rótulo simples e as linhas, ambos apenas de leitura. É o modo
/// usado na revisão do cadastro (confirmação antes de salvar) e em fichas de
/// registro já gravado: mesma caixa por item, sem "Adicionar" nem editar
/// nem remover.
///
/// Com [onEdit], a linha inteira é clicável e abre a edição — o lápis fica
/// como atalho visível. Remover usa a lixeira (o "×" é lido como "fechar").
class AppCollectionList extends StatelessWidget {
  const AppCollectionList({
    super.key,
    required this.name,
    required this.items,
    this.onAdd,
    this.onEdit,
    this.onRemove,
    this.editLabel = 'Editar item',
    this.removeLabel = 'Remover item',
    this.showHeader = true,
    this.highlightIndex,
  });

  /// Nome da coleção, como aparece no contrato e na faixa ("Insumos").
  final String name;

  final List<AppCollectionItemView> items;

  /// `null` (padrão da revisão/ficha) esconde a faixa "Adicionar" — a lista
  /// vira somente leitura de ponta a ponta (ver [onEdit]/[onRemove]).
  final VoidCallback? onAdd;

  /// Recebe o índice da linha a editar. Nulo deixa as linhas sem o ícone de
  /// editar — é o caso das consultas somente leitura.
  final void Function(int index)? onEdit;

  /// Recebe o índice da linha a remover. Nulo deixa as linhas sem o ícone de
  /// remover — é o caso das consultas somente leitura.
  final void Function(int index)? onRemove;

  final String editLabel;
  final String removeLabel;

  /// `false` esconde a faixa/rótulo do topo — usado quando quem envolve a
  /// lista já mostra nome e contagem (ex.: [showAppCollectionManager]).
  final bool showHeader;

  /// Linha em destaque (borda e fundo de acento) — aponta onde o item recém
  /// incluído ou editado foi parar. `null` não destaca nenhuma.
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!showHeader)
          const SizedBox.shrink()
        else if (onAdd case final add?)
          AppAddableGroupList(
            groups: [name],
            counts: {name: items.length},
            onAdd: (_) => add(),
          )
        else
          Text(
            name,
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgMuted,
            ),
          ),
        for (var index = 0; index < items.length; index++)
          Padding(
            // Sem cabeçalho, a primeira linha encosta no topo.
            padding: index == 0 && !showHeader
                ? EdgeInsets.zero
                : const EdgeInsets.only(top: AppSpacing.space2),
            child: _CollectionRow(
              item: items[index],
              highlighted: index == highlightIndex,
              editLabel: editLabel,
              removeLabel: removeLabel,
              onEdit: onEdit == null ? null : () => onEdit!(index),
              onRemove: onRemove == null ? null : () => onRemove!(index),
            ),
          ),
      ],
    );
  }
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({
    required this.item,
    required this.editLabel,
    required this.removeLabel,
    this.onEdit,
    this.onRemove,
    this.highlighted = false,
  });

  final AppCollectionItemView item;
  final bool highlighted;
  final String editLabel;
  final String removeLabel;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final row = Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space3,
        AppSpacing.space3,
        AppSpacing.space1,
        AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: highlighted ? semantic.accentSubtle : semantic.bgSubtle,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(
          color: highlighted ? semantic.accentDefault : semantic.borderDefault,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ExcludeSemantics(
              excluding: onEdit != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                  if (item.subtitle case final subtitle?)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (onEdit case final edit?)
            AppIconButton(
              icon: const AppIcon(AppIcons.pencil, size: AppSize.iconSm),
              label: editLabel,
              onPressed: edit,
            ),
          // Respiro entre editar e excluir: lado a lado sem folga, o toque de
          // luva acertava a lixeira querendo o lápis.
          if (onEdit != null && onRemove != null)
            const SizedBox(width: AppSpacing.space2),
          if (onRemove case final remove?)
            AppIconButton(
              icon: AppIcon(
                AppIcons.trash2,
                size: AppSize.iconSm,
                color: semantic.toneRedFg,
              ),
              label: removeLabel,
              onPressed: remove,
            ),
        ],
      ),
    );

    final edit = onEdit;
    if (edit == null) return row;
    return AppPressable(
      semanticLabel: [item.title, ?item.subtitle, editLabel].join(', '),
      onPressed: edit,
      minTouchTarget: false,
      excludeSemantics: false,
      child: row,
    );
  }
}

WidgetbookComponent buildCollectionListWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'CollectionList',
    useCases: [
      WidgetbookUseCase(
        name: 'Coleção com itens',
        builder: (context) => const _CollectionListUseCase(),
      ),
      WidgetbookUseCase(
        name: 'Somente leitura (revisão/ficha)',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppCollectionList(
            name: 'Etapas do protocolo',
            items: [
              AppCollectionItemView(
                title: 'Implante de progesterona',
                subtitle: '2026-09-01 · 1 dose · Farmácia',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _CollectionListUseCase extends StatefulWidget {
  const _CollectionListUseCase();

  @override
  State<_CollectionListUseCase> createState() => _CollectionListUseCaseState();
}

class _CollectionListUseCaseState extends State<_CollectionListUseCase> {
  final _items = <AppCollectionItemView>[
    const AppCollectionItemView(
      title: 'Ração Engorda 18%',
      subtitle: '20 kg · Armazém A',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: AppCollectionList(
        name: 'Insumos',
        items: _items,
        onAdd: () => setState(
          () => _items.add(
            const AppCollectionItemView(
              title: 'Sal Mineral Proteinado',
              subtitle: '50 kg · Depósito B',
            ),
          ),
        ),
        onEdit: (index) => setState(
          () => _items[index] = AppCollectionItemView(
            title: _items[index].title,
            subtitle: '${_items[index].subtitle} (editado)',
          ),
        ),
        onRemove: (index) => setState(() => _items.removeAt(index)),
      ),
    );
  }
}
