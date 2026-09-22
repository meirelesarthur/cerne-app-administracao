import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'app_icon.dart';
import 'icon_button.dart';

/// Paginação compacta para listas de registros em telas móveis.
///
/// Os índices recebidos e emitidos por [onPageChanged] começam em zero, mas a
/// pessoa vê páginas começando em um. O componente reserva o alvo de toque dos
/// botões e deixa a quantidade visível para orientar a navegação.
class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.page,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  }) : assert(page >= 0),
       assert(totalItems >= 0),
       assert(pageSize > 0);

  final int page;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  int get pageCount => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final currentPage = page.clamp(0, pageCount - 1);
    final firstItem = totalItems == 0 ? 0 : currentPage * pageSize + 1;
    final lastItem = (currentPage * pageSize + pageSize).clamp(0, totalItems);

    return Semantics(
      container: true,
      label: 'Paginação de registros',
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Exibindo $firstItem–$lastItem de $totalItems',
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
          ),
          Text(
            'Página ${currentPage + 1} de $pageCount',
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
            ),
          ),
          const SizedBox(width: AppSpacing.space1),
          AppIconButton(
            label: 'Página anterior',
            icon: const AppIcon(AppIcons.chevronLeft),
            onPressed: currentPage > 0
                ? () => onPageChanged(currentPage - 1)
                : null,
          ),
          AppIconButton(
            label: 'Próxima página',
            icon: const AppIcon(AppIcons.chevronRight),
            onPressed: currentPage + 1 < pageCount
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildPaginationWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Pagination',
    useCases: [
      WidgetbookUseCase(
        name: 'Interativa',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: _PaginationDemo(),
        ),
      ),
    ],
  );
}

class _PaginationDemo extends StatefulWidget {
  const _PaginationDemo();

  @override
  State<_PaginationDemo> createState() => _PaginationDemoState();
}

class _PaginationDemoState extends State<_PaginationDemo> {
  var _page = 0;

  @override
  Widget build(BuildContext context) => AppPagination(
    page: _page,
    totalItems: 12,
    pageSize: 5,
    onPageChanged: (page) => setState(() => _page = page),
  );
}
