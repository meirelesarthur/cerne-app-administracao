import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../shared/simulated_load.dart';
import '../../../ui/ui.dart';
import '../mocks/produtos.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Home do Marketplace (New-UI): busca de insumos, categorias em pílula,
/// banner de oferta em destaque e grid de produtos do catálogo. Espelha
/// `MarketplaceHome.tsx`.
class MarketplaceHomeScreen extends StatefulWidget {
  const MarketplaceHomeScreen({super.key, this.initialCategoriaId});

  /// Categoria pré-selecionada ao chegar via deep-link (equivalente ao
  /// `location.state.categoriaId` do React), ex.: vindo de `MarketplaceCategorias`.
  final String? initialCategoriaId;

  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> {
  final _buscaController = TextEditingController();
  String _busca = '';
  String? _categoriaAtiva;

  @override
  void initState() {
    super.initState();
    _categoriaAtiva = widget.initialCategoriaId;
  }

  @override
  void didUpdateWidget(MarketplaceHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // go_router reaproveita a Page/Element de `/marketplace` ao voltar de
    // `/marketplace/categorias` (mesma location) — sem isto, um novo
    // `initialCategoriaId` (deep-link de categoria) não atualizaria o filtro.
    if (widget.initialCategoriaId != oldWidget.initialCategoriaId) {
      _categoriaAtiva = widget.initialCategoriaId;
    }
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Produto> get _produtosFiltrados {
    final termo = _busca.trim().toLowerCase();
    return produtos.where((produto) {
      final combinaCategoria =
          _categoriaAtiva == null || produto.categoriaId == _categoriaAtiva;
      final combinaBusca =
          termo.isEmpty || produto.nome.toLowerCase().contains(termo);
      return combinaCategoria && combinaBusca;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _produtosFiltrados;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        RiseIn(
          child: AppTextInput(
            controller: _buscaController,
            placeholder: 'Buscar insumos, máquinas, peças…',
            prefixIcon: const AppIcon(
              AppIcons.search,
              size: AppSize.iconSmPlus,
            ),
            onChanged: (value) => setState(() => _busca = value),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        RiseIn(
          index: 1,
          child: SizedBox(
            height: AppSpacing.space10,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              separatorBuilder: (context, _) =>
                  const SizedBox(width: AppSpacing.space2),
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                final ativa = _categoriaAtiva == categoria.id;
                return AppButton(
                  size: AppButtonSize.sm,
                  variant: ativa
                      ? AppButtonVariant.primary
                      : AppButtonVariant.secondary,
                  leftIcon: AppIcon(categoria.icon, size: AppSize.iconXs),
                  onPressed: () => setState(
                    () => _categoriaAtiva = ativa ? null : categoria.id,
                  ),
                  child: Text(categoria.label),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        RiseIn(
          index: 2,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.space5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl3),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppComponentColors.hubBankCardFrom,
                  AppComponentColors.hubBankCardTo,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppChip(tone: AppChipTone.brand, child: Text('Oferta')),
                const SizedBox(height: AppSpacing.space3),
                const Text(
                  OfertaDestaque.titulo,
                  style: TextStyle(
                    color: AppColors.neutral0,
                    fontSize: AppTypography.xlPlus,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Text(
                    OfertaDestaque.subtitulo,
                    style: TextStyle(
                      color: AppColors.neutral0.withValues(alpha: 0.8),
                      fontSize: AppTypography.md,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm,
                  onPressed: () => context.go('/marketplace/categorias'),
                  child: const Text(OfertaDestaque.cta),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        RiseIn(
          index: 3,
          child: SimulatedLoad(
            builder: (context, loading) {
              if (loading) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.space3,
                  crossAxisSpacing: AppSpacing.space3,
                  childAspectRatio: 0.78,
                  children: List.generate(4, (_) => const AppCardSkeleton()),
                );
              }

              if (filtrados.isEmpty) {
                return AppEmptyState(
                  icon: AppIcons.searchX,
                  title: 'Nada encontrado',
                  description:
                      'Tente outro termo de busca ou limpe os filtros de categoria selecionados.',
                  action: AppButton(
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.sm,
                    onPressed: () => setState(() {
                      _busca = '';
                      _buscaController.clear();
                      _categoriaAtiva = null;
                    }),
                    child: const Text('Limpar filtros'),
                  ),
                );
              }

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.space3,
                crossAxisSpacing: AppSpacing.space3,
                childAspectRatio: 0.78,
                children: [
                  for (final produto in filtrados)
                    _ProdutoCard(produto: produto),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  const _ProdutoCard({required this.produto});

  final Produto produto;

  @override
  Widget build(BuildContext context) {
    Categoria? categoria;
    for (final c in categorias) {
      if (c.id == produto.categoriaId) {
        categoria = c;
        break;
      }
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      interactive: true,
      onTap: () => context.go('/marketplace/produto/${produto.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: semantic.accentSubtle,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: categoria != null
                ? AppIcon(
                    categoria.icon,
                    size: AppSize.iconXl,
                    color: semantic.accentDefault,
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            produto.nome,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppTypography.md,
              fontWeight: AppTypography.weightSemibold,
            ),
          ),
          const SizedBox(height: AppSpacing.half),
          Text(
            produto.vendedor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: AppTypography.sm),
          ),
          const SizedBox(height: AppSpacing.space2),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: AppTypography.xlPlus,
                fontWeight: AppTypography.weightBold,
              ),
              children: [
                TextSpan(text: produto.preco),
                TextSpan(
                  text: ' /${produto.unidade}',
                  style: const TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightNormal,
                  ),
                ),
              ],
            ),
          ),
          if (produto.freteGratis || produto.desconto != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space2),
              child: Wrap(
                spacing: AppSpacing.space1,
                runSpacing: AppSpacing.space1,
                children: [
                  if (produto.freteGratis)
                    const AppTag(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(AppIcons.truck, size: AppSize.iconXs),
                          SizedBox(width: AppSpacing.space1),
                          Text('Frete grátis'),
                        ],
                      ),
                    ),
                  if (produto.desconto != null)
                    AppChip(
                      tone: AppChipTone.brand,
                      child: Text(produto.desconto!),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
