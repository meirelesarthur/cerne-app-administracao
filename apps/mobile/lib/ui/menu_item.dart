import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_shadows.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Tom do rótulo/ícone — espelha `MenuItemTone` (`'default' | 'danger'`) de
/// `MenuItem.tsx`. `default` é palavra reservada em Dart, por isso o valor
/// neutro chama-se [AppMenuItemTone.standard].
enum AppMenuItemTone { standard, danger }

/// Espelha `MenuItemVariant` (`'light' | 'onDark'`) de `MenuItem.tsx`.
///
/// `onDark` é a linha plana do menu lateral (fundo `revealMenuBg`): sem
/// cápsula, sem bolha de ícone e sem chevron — só ícone e rótulo, com 48 px
/// de alvo de toque. O menu lista um índice longo (grupos, módulos e conta)
/// e a cápsula de cada linha o transformava numa pilha de cartões.
enum AppMenuItemVariant { light, onDark }

// fidelidade-esteira: padrão de listagens — topo cinza (header), card branco
// (folha) e itens da listagem em cinza. `surface` (padrão) é a linha branca
// com sombra usada em menus/navegação; `subtle` é a linha cinza plana
// (`bgSubtle`, sem sombra) para dentro de uma folha branca.
enum AppMenuItemSurface { surface, subtle }

/// Item de menu/navegação: linha-cápsula com bolha de ícone à esquerda,
/// título + descrição e chevron em círculo à direita.
/// Touch target ≥ 56px (`AppSpacing.space14`), espelhando `min-h-14` do React.
///
/// Geometria do padrão global: raio [AppRadius.tile] (20), sombra
/// `AppShadows.row`, rótulo de 16 px e ícones na escala do sistema — as linhas
/// de `Menu-rapido-admin` do Figma (`54349:2948`).
class AppMenuItem extends StatelessWidget {
  const AppMenuItem({
    super.key,
    this.icon,
    required this.label,
    this.description,
    this.trailing,
    this.active = false,
    this.tone = AppMenuItemTone.standard,
    this.variant = AppMenuItemVariant.light,
    this.surface = AppMenuItemSurface.surface,
    this.showShadow = true,
    this.onTap,
  });

  final AppIconData? icon;
  final String label;
  final String? description;
  final Widget? trailing;
  final bool active;
  final AppMenuItemTone tone;
  final AppMenuItemVariant variant;
  final AppMenuItemSurface surface;

  /// Sombra do card quando `light`/inativo (`shadowCard`). Telas com muitos
  /// itens em sequência (ex.: `GroupFeaturesScreen`) podem desligar para uma
  /// lista mais plana, sem repetir a mesma sombra a cada linha.
  final bool showShadow;
  final VoidCallback? onTap;

  bool get _isDanger => tone == AppMenuItemTone.danger;
  bool get _isOnDark => variant == AppMenuItemVariant.onDark;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final containerColor = active
        ? (_isOnDark
              ? AppColors.neutral0.withValues(alpha: 0.15)
              : semantic.accentSubtle)
        : (_isOnDark
              ? AppColors.transparent
              // `bgSubtle` é branco no tema claro (mesmo valor de
              // `bgSurface` — reservado para outro uso); `bgSheet` é o
              // cinza real (#F0F0F0) já usado como fundo de página, por
              // isso é ele que dá contraste contra a folha branca aqui.
              : (surface == AppMenuItemSurface.subtle
                    ? semantic.bgInset
                    : semantic.bgSurface));

    final labelColor = _isDanger
        ? (_isOnDark ? AppColors.red400 : semantic.toneRedFg)
        : active
        ? (_isOnDark ? semantic.inkFg : semantic.accentDefault)
        : (_isOnDark ? semantic.inkFg : semantic.fgDefault);

    final descriptionColor = _isOnDark ? semantic.inkMuted : semantic.fgMuted;
    final iconBubbleColor = _isDanger
        ? semantic.toneRedBg
        : (_isOnDark
              ? AppColors.transparent
              : (surface == AppMenuItemSurface.subtle
                    ? AppColors.transparent
                    : semantic.bgSubtle));
    final iconColor = _isDanger
        ? semantic.toneRedFg
        : (_isOnDark ? semantic.inkFg : semantic.fgMuted);
    final chevronBubbleColor = _isOnDark
        ? semantic.inkBubble
        : semantic.bgSubtle;
    final chevronColor = _isOnDark ? semantic.inkMuted : semantic.fgMuted;

    return Material(
      color: containerColor,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        child: Container(
          constraints: BoxConstraints(
            minHeight: _isOnDark ? AppSpacing.space12 : AppSpacing.space14,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          ),
          decoration: !active && !_isOnDark && showShadow
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.tile),
                  boxShadow: AppShadows.row,
                )
              : null,
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  height: _isOnDark ? AppSpacing.space6 : AppSpacing.space10,
                  width: _isOnDark ? AppSpacing.space6 : AppSpacing.space10,
                  decoration: BoxDecoration(
                    color: iconBubbleColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(icon, size: AppSize.iconMd, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.space3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.xl,
                        fontWeight: AppTypography.weightMedium,
                        color: labelColor,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: descriptionColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.space2),
                  child: trailing,
                )
              else if (onTap != null && !_isOnDark)
                Container(
                  height: AppSpacing.space8,
                  width: AppSpacing.space8,
                  margin: const EdgeInsets.only(left: AppSpacing.space2),
                  decoration: BoxDecoration(
                    color: chevronBubbleColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: AppIcon(
                    AppIcons.chevronRight,
                    size: AppSize.iconSm,
                    color: chevronColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

WidgetbookComponent buildMenuItemWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'MenuItem',
    useCases: [
      WidgetbookUseCase(
        name: 'Light — padrão',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppMenuItem(
                icon: AppIcons.user,
                label: 'Perfil',
                description: 'Dados pessoais e documentos',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppMenuItem(
                icon: AppIcons.bell,
                label: 'Notificações',
                active: true,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppMenuItem(
                icon: AppIcons.logOut,
                label: 'Sair',
                tone: AppMenuItemTone.danger,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Listagem (subtle, sem sombra)',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppMenuItem(
                icon: AppIcons.fileCheck2,
                label: 'Erosão na curva de nível',
                description: 'Ponto de atenção · Talhão 02',
                surface: AppMenuItemSurface.subtle,
                showShadow: false,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppMenuItem(
                icon: AppIcons.fileCheck2,
                label: 'Erosão na curva de nível',
                description: 'Ponto de atenção · Talhão 02',
                surface: AppMenuItemSurface.subtle,
                showShadow: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'onDark',
        builder: (context) => Container(
          color: Theme.of(context).extension<AppSemanticColors>()!.inkBg,
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppMenuItem(
                icon: AppIcons.settings,
                label: 'Configurações',
                variant: AppMenuItemVariant.onDark,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.space2),
              AppMenuItem(
                icon: AppIcons.shield,
                label: 'Segurança',
                active: true,
                variant: AppMenuItemVariant.onDark,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
