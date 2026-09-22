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

/// Categorias do Marketplace — grade derivada das categorias com produtos no
/// catálogo mockado. Tocar numa categoria leva à Home já filtrada por ela.
/// Espelha `MarketplaceCategorias.tsx`.
class MarketplaceCategoriasScreen extends StatelessWidget {
  const MarketplaceCategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoriasComContagem = [
      for (final categoria in categorias)
        (
          categoria: categoria,
          total: produtos.where((p) => p.categoriaId == categoria.id).length,
        ),
    ].where((c) => c.total > 0).toList();

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      children: [
        const SubPageHeader(title: 'Categorias'),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.all(AppSpacing.space4),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.space3,
            crossAxisSpacing: AppSpacing.space3,
            childAspectRatio: 1.15,
            children: [
              for (final entry in categoriasComContagem)
                AppCard(
                  interactive: true,
                  onTap: () => context.go(
                    '/marketplace',
                    extra: {'categoriaId': entry.categoria.id},
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: AppSpacing.space14,
                        width: AppSpacing.space14,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: semantic.accentSubtle,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: AppIcon(
                          entry.categoria.icon,
                          size: AppSize.iconLg,
                          color: semantic.accentDefault,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Text(
                        entry.categoria.label,
                        style: TextStyle(
                          fontSize: AppTypography.md,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.oneHalf),
                      AppTag(
                        child: Text(
                          entry.total == 1
                              ? '1 produto'
                              : '${entry.total} produtos',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
