import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import '../mocks/produtos.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Favoritos do Marketplace — lista mockada de produtos marcados como
/// favoritos. Espelha `MarketplaceFavoritos.tsx`.
class MarketplaceFavoritosScreen extends StatelessWidget {
  const MarketplaceFavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritos = [
      for (final id in favoritosIds)
        for (final p in produtos)
          if (p.id == id) p,
    ];

    return Column(
      children: [
        const SubPageHeader(title: 'Favoritos'),
        Expanded(
          child: favoritos.isEmpty
              ? const AppEmptyState(
                  icon: AppIcons.heart,
                  title: 'Nenhum favorito ainda',
                  description:
                      'Toque no coração de um produto para guardá-lo aqui e encontrar mais rápido na próxima vez.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  itemCount: favoritos.length,
                  separatorBuilder: (context, _) =>
                      const SizedBox(height: AppSpacing.space3),
                  itemBuilder: (context, index) {
                    final produto = favoritos[index];
                    Categoria? categoria;
                    for (final c in categorias) {
                      if (c.id == produto.categoriaId) {
                        categoria = c;
                        break;
                      }
                    }
                    final semantic = Theme.of(
                      context,
                    ).extension<AppSemanticColors>()!;

                    return AppCard(
                      interactive: true,
                      onTap: () =>
                          context.go('/marketplace/produto/${produto.id}'),
                      child: Row(
                        children: [
                          Container(
                            height: AppSpacing.space14,
                            width: AppSpacing.space14,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: semantic.accentSubtle,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: categoria != null
                                ? AppIcon(
                                    categoria.icon,
                                    size: AppSize.iconLg,
                                    color: semantic.accentDefault,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  produto.nome,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: AppTypography.weightSemibold,
                                    color: semantic.fgDefault,
                                  ),
                                ),
                                Text(
                                  produto.vendedor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppTypography.sm,
                                    color: semantic.fgMuted,
                                  ),
                                ),
                                Text(
                                  produto.preco,
                                  style: TextStyle(
                                    fontWeight: AppTypography.weightBold,
                                    color: semantic.fgDefault,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppIcon(
                            AppIcons.heart,
                            size: AppSize.iconSmPlus,
                            color: semantic.accentDefault,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
