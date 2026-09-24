import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import '../design/generated/app_layout.dart';

/// Espelha `QuickAction.tsx` (New-UI hub): círculo de 56px (`AppSpacing.space14`)
/// com rótulo abaixo — usado nas ações rápidas do hub. Ícone fixo em 21px; o
/// traço é o do sistema, aplicado por `AppIcon`.
///
/// Ajuste de usabilidade (ver plano de melhorias de UX): o círculo era um
/// verde bem claro (`accentSubtle`) quase da mesma família de cor do ícone —
/// pouco contraste. Virou `bgSurface` (branco) + sombra de cartão, com o
/// ícone verde como único acento colorido — o círculo se destaca do canvas
/// em vez de se misturar com o próprio ícone.
class AppQuickAction extends StatelessWidget {
  const AppQuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  /// Ícone fixo — equivalente ao `icon: LucideIcon` do React (ex.: `AppIcons.scale`).
  final AppIconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.space14,
              height: AppSpacing.space14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl2),
                color: semantic.bgSurface,
                boxShadow: semantic.shadowCard,
              ),
              alignment: Alignment.center,
              child: AppIcon(
                icon,
                size: AppSize.iconMd,
                color: semantic.accentDefault,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.sm,
                fontWeight: AppTypography.weightSemibold,
                height: AppTypography.lineHeightTight,
                color: semantic.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildQuickActionWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'QuickAction',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => Center(
          child: Wrap(
            spacing: 20,
            children: [
              AppQuickAction(
                icon: AppIcons.scale,
                label: 'Pesagem',
                onPressed: () {},
              ),
              AppQuickAction(
                icon: AppIcons.fileText,
                label: 'Minhas OS',
                onPressed: () {},
              ),
              AppQuickAction(
                icon: AppIcons.qrCode,
                label: 'Ler brinco',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
