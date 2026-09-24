import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'app_icon.dart';
import 'hexagon.dart';
import 'pressable.dart';

class AppQuickAccessItem {
  const AppQuickAccessItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String id;
  final String label;
  final AppIconData icon;
  final VoidCallback onPressed;
}

class AppQuickAccessRail extends StatelessWidget {
  const AppQuickAccessRail({super.key, required this.items});

  final List<AppQuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: AppSpacing.space14 + AppSpacing.space12,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.space2),
              itemBuilder: (context, index) =>
                  _QuickAccessTile(item: items[index], semantic: semantic),
            ),
          ),
      ],
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({required this.item, required this.semantic});

  final AppQuickAccessItem item;
  final AppSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      semanticLabel: 'Abrir ${item.label}',
      onPressed: item.onPressed,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: AppSpacing.space14 + AppSpacing.space8,
        height: AppSpacing.space14 + AppSpacing.space12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppHexagon(
              size: AppSpacing.space14,
              color: AppColors.neutral0,
              borderColor: semantic.borderDefault,
              shadows: semantic.shadowCard,
              child: AppIcon(
                item.icon,
                size: AppSize.iconMd,
                color: semantic.accentDefault,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            SizedBox(
              height: AppTypography.sm * AppTypography.lineHeightTight * 2,
              child: ExcludeSemantics(
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightMedium,
                    height: AppTypography.lineHeightTight,
                    color: semantic.fgMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildQuickAccessRailWidgetbookComponent() {
  const items = [
    AppQuickAccessItem(
      id: 'resultado',
      label: 'Resultado',
      icon: AppIcons.wallet,
      onPressed: _noopQuickAccess,
    ),
    AppQuickAccessItem(
      id: 'confinamento',
      label: 'Rebanho e confinamento',
      icon: AppIcons.confinamento,
      onPressed: _noopQuickAccess,
    ),
    AppQuickAccessItem(
      id: 'suprimentos',
      label: 'Suprimentos',
      icon: AppIcons.shoppingCart,
      onPressed: _noopQuickAccess,
    ),
    AppQuickAccessItem(
      id: 'ativos',
      label: 'Ativos e depreciação',
      icon: AppIcons.tractor,
      onPressed: _noopQuickAccess,
    ),
    AppQuickAccessItem(
      id: 'uso',
      label: 'Adoção e governança',
      icon: AppIcons.users,
      onPressed: _noopQuickAccess,
    ),
    AppQuickAccessItem(
      id: 'consultas',
      label: 'Consultas gerenciais',
      icon: AppIcons.fileBarChart,
      onPressed: _noopQuickAccess,
    ),
  ];

  return WidgetbookComponent(
    name: 'QuickAccessRail',
    useCases: [
      WidgetbookUseCase(
        name: 'Últimas funções',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppQuickAccessRail(items: items),
        ),
      ),
      WidgetbookUseCase(
        name: 'Sem histórico',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppQuickAccessRail(items: []),
        ),
      ),
    ],
  );
}

void _noopQuickAccess() {}
