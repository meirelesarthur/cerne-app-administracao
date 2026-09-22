import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'pressable.dart';
import 'tag.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Linha de entidade do padrão global — a `Offer Banner` do frame
/// `administrativo-home` do Figma (`54300:16139`).
///
/// Anatomia medida: 78 px de altura, superfície elevada com raio
/// [AppRadius.tile] (20) e sombra `AppShadows.row`, `px 12 / py 16`, gap 8.
/// À esquerda, uma caixa de 48 px (raio [AppRadius.surface], fundo abafado)
/// com o ícone de 24 px. À direita, duas linhas: título abafado + [tag] nas
/// extremidades, e abaixo valor em destaque + metadado.
///
/// Diferente do `AppMenuItem`, que é uma linha de **navegação** (ícone, rótulo,
/// chevron) e do `AppTransactionListItem`, que é o extrato com direção de
/// dinheiro e divisor. Esta linha carrega quatro campos independentes e um
/// status — é o cartão de uma entidade de negócio (parceiro, proposta, pedido).
class AppEntityRow extends StatelessWidget {
  const AppEntityRow({
    super.key,
    required this.icon,
    required this.title,
    this.tag,
    this.value,
    this.meta,
    this.onTap,
  });

  final AppIconData icon;

  /// Nome da entidade — no Figma, o parceiro de crédito.
  final String title;

  /// Status à direita do título.
  final AppTag? tag;

  /// Valor em destaque, na cor da marca.
  final String? value;

  /// Metadado à direita do valor ("a partir de 1,05% a.m.").
  final String? meta;

  final VoidCallback? onTap;

  /// Altura do Figma. Fixa para que fileiras consecutivas alinhem.
  static const double height = 78;

  /// Aresta da caixa de ícone à esquerda.
  static const double _iconBoxSize = AppSpacing.space12;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final row = Container(
      height: height,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: semantic.bgRaised,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        boxShadow: AppShadows.row,
      ),
      child: Row(
        children: [
          Container(
            width: _iconBoxSize,
            height: _iconBoxSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: semantic.bgSubtle,
              borderRadius: BorderRadius.circular(AppRadius.surface),
            ),
            child: AppIcon(
              icon,
              size: AppSize.iconLg,
              color: semantic.accentDefault,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.md,
                          fontWeight: AppTypography.weightMedium,
                          color: semantic.fgQuiet,
                        ),
                      ),
                    ),
                    if (tag != null) ...[
                      const SizedBox(width: AppSpacing.space2),
                      tag!,
                    ],
                  ],
                ),
                if (value != null || meta != null) ...[
                  const SizedBox(height: AppSpacing.half),
                  Row(
                    children: [
                      if (value != null)
                        Expanded(
                          child: Text(
                            value!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppTypography.xl,
                              fontWeight: AppTypography.weightSemibold,
                              color: semantic.accentDefault,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (meta != null) ...[
                        const SizedBox(width: AppSpacing.space2),
                        Text(
                          meta!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            color: semantic.fgSubtle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;

    return AppPressable(
      semanticLabel: [title, value, meta].whereType<String>().join(', '),
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: row,
    );
  }
}

WidgetbookComponent buildEntityRowWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'EntityRow',
    useCases: [
      WidgetbookUseCase(
        name: 'Parceiros de crédito',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppEntityRow(
                icon: AppIcons.cash,
                title: 'Casa do adubo',
                tag: const AppTag(
                  tone: AppTagTone.success,
                  child: Text('Pré-aprovado'),
                ),
                value: r'R$ 720.000,00',
                meta: 'a partir de 1,05% a.m.',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppEntityRow(
                icon: AppIcons.cash,
                title: 'Venagro',
                tag: const AppTag(
                  tone: AppTagTone.warning,
                  child: Text('Em análise'),
                ),
                value: r'R$ 720.000,00',
                meta: 'a partir de 1,05% a.m.',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppEntityRow(
                icon: AppIcons.cash,
                title: 'NPK',
                tag: const AppTag(
                  tone: AppTagTone.success,
                  icon: AppIcons.partyPopper,
                  child: Text('Aprovado'),
                ),
                value: r'R$ 720.000,00',
                meta: 'a partir de 1,05% a.m.',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Só título e valor',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppEntityRow(
            icon: AppIcons.package,
            title: 'Pedido #4821',
            value: r'R$ 12.400,00',
            onTap: () {},
          ),
        ),
      ),
    ],
  );
}
