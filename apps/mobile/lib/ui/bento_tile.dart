import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Espelha a prop `variant` (`'surface' | 'accent'`) de `BentoTile.tsx`.
enum AppBentoTileVariant { surface, accent }

/// Espelha a prop `iconSize` (`'md' | 'lg'`) de `BentoTile.tsx`.
enum AppBentoTileIconSize { md, lg }

/// Tile de bento grid reutilizável (home de super app): tamanhos mistos,
/// variante clara ([AppBentoTileVariant.surface]) ou escura de destaque com
/// seta ([AppBentoTileVariant.accent]). Nova UI: bolha de ícone monotom
/// (acento da marca) — sem cor por item.
class AppBentoTile extends StatelessWidget {
  const AppBentoTile({
    super.key,
    required this.icon,
    required this.label,
    this.caption,
    this.variant = AppBentoTileVariant.surface,
    this.iconSize = AppBentoTileIconSize.md,
    this.onTap,
  });

  final AppIconData icon;
  final String label;
  final String? caption;
  final AppBentoTileVariant variant;
  final AppBentoTileIconSize iconSize;
  final VoidCallback? onTap;

  // h-11 w-11 (44px) e h-12 w-12 (48px) do React — reaproveitando tokens já
  // existentes com o mesmo valor numérico (AppSize.control e AppSpacing.space12).
  double get _iconBox => iconSize == AppBentoTileIconSize.lg
      ? AppSpacing.space12
      : AppSize.control;
  double get _iconGlyph => iconSize == AppBentoTileIconSize.lg ? 26 : 22;

  bool get _isAccent => variant == AppBentoTileVariant.accent;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final content = Container(
      constraints: const BoxConstraints(
        minHeight: 104,
      ), // min-h-[104px] — arbitrário também no React
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        gradient: _isAccent
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppComponentColors.hubBankCardFrom,
                  AppComponentColors.hubBankCardTo,
                ],
              )
            : null,
        color: _isAccent ? null : semantic.bgSurface,
        border: _isAccent ? null : Border.all(color: semantic.borderSubtle),
        boxShadow: _isAccent ? null : semantic.shadowCard,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: _iconBox,
                width: _iconBox,
                decoration: BoxDecoration(
                  color: _isAccent
                      ? AppColors.neutral0.withValues(alpha: 0.15)
                      : semantic.accentSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: _isAccent
                      ? null
                      : Border.all(color: semantic.borderTint),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  icon,
                  size: _iconGlyph,
                  color: _isAccent
                      ? AppColors.neutral0
                      : semantic.accentDefault,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: _isAccent ? AppSpacing.space8 : AppSpacing.space0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: AppTypography.md,
                        fontWeight: AppTypography.weightSemibold,
                        color: _isAccent
                            ? AppColors.neutral0
                            : semantic.fgDefault,
                      ),
                    ),
                    if (caption != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.half),
                        child: Text(
                          caption!,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            height: AppTypography.lineHeightSnug,
                            color: _isAccent
                                ? AppColors.neutral0.withValues(alpha: 0.7)
                                : semantic.fgMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_isAccent)
            Positioned(
              bottom: AppSpacing.space4,
              right: AppSpacing.space4,
              child: Container(
                height: AppSpacing.space8,
                width: AppSpacing.space8,
                decoration: BoxDecoration(
                  color: AppColors.neutral0.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  AppIcons.arrowRight,
                  size: AppSize.iconSm,
                  color: AppColors.neutral0,
                ),
              ),
            ),
        ],
      ),
    );

    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl3),
        child: content,
      ),
    );
  }
}

WidgetbookComponent buildBentoTileWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'BentoTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Surface',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: SizedBox(
            width: 160,
            child: AppBentoTile(
              icon: AppIcons.landmark,
              label: 'Fazendas',
              caption: 'Gestão de talhões',
              onTap: () {},
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Accent (destaque)',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: SizedBox(
            width: 160,
            child: AppBentoTile(
              icon: AppIcons.wallet,
              label: 'Banking',
              caption: 'Conta digital CERNE',
              variant: AppBentoTileVariant.accent,
              iconSize: AppBentoTileIconSize.lg,
              onTap: () {},
            ),
          ),
        ),
      ),
    ],
  );
}
