import 'package:flutter/material.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Item de atalho ícone + rótulo — espelha `Shortcut` (interface) de `ShortcutGrid.tsx`.
class Shortcut {
  const Shortcut({
    required this.id,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String id;
  final String label;
  final AppIconData icon;
  final VoidCallback? onTap;
}

/// Grid de atalhos ícone + label (spec §6.5) — espelha `ShortcutGrid.tsx`.
/// Reutilizável entre hubs do módulo. Nova UI: bolhas monotom (acento da
/// marca) — consistência visual em vez de cores por item.
class ShortcutGrid extends StatelessWidget {
  const ShortcutGrid({super.key, required this.items, this.columns = 4});

  final List<Shortcut> items;

  /// 4 ou 5 colunas — espelha `columns` de `ShortcutGrid.tsx`.
  final int columns;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.space3,
      crossAxisSpacing: columns == 5 ? AppSpacing.space2 : AppSpacing.space3,
      childAspectRatio: 0.82,
      children: [
        for (final it in items)
          AppPressable(
            semanticLabel: it.label,
            onPressed: it.onTap,
            borderRadius: BorderRadius.circular(AppRadius.xl2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSpacing.space14,
                  height: AppSpacing.space14,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xl2),
                    color: semantic.accentSubtle,
                    border: Border.all(color: semantic.borderTint),
                  ),
                  child: AppIcon(
                    it.icon,
                    size: AppSize.iconMd,
                    color: semantic.accentDefault,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  it.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightMedium,
                    height: 1.1,
                    color: semantic.fgMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
