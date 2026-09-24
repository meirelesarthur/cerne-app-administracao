import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Card de descoberta usado nos trilhos de acesso rápido e busca otimizada.
/// A mesma anatomia aparece nas seções de produtos da busca: ícone de 32 px no topo, nome na base e rolagem horizontal.
///
/// [selected] tinge ícone e rótulo com a cor de destaque e troca o fundo para
/// [AppSemanticColors.accentSubtle] — usado quando o trilho também funciona
/// como seletor de seção (ex.: as abas de Consultas Gerenciais), sem duplicar
/// a anatomia do cartão em um widget próprio (Lei 2).
class AppDiscoveryTile extends StatelessWidget {
  const AppDiscoveryTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.width = 105,
    this.height = 88,
    this.selected = false,
  });

  final AppIconData icon;
  final String label;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final iconColor = selected ? semantic.accentDefault : semantic.fgSecondary;
    final labelColor = selected ? semantic.accentDefault : semantic.fgDefault;

    return AppPressable(
      semanticLabel: label,
      selected: selected,
      onPressed: onTap,
      minTouchTarget: false,
      borderRadius: BorderRadius.circular(AppRadius.tile),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(AppSpacing.space2),
        decoration: BoxDecoration(
          color: selected ? semantic.accentSubtle : semantic.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(icon, size: AppSize.iconXxl, color: iconColor),
            const Spacer(),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.sm,
                fontWeight: AppTypography.weightMedium,
                height: AppTypography.lineHeightTight,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

WidgetbookComponent buildDiscoveryTileWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'DiscoveryTile',
    useCases: [
      WidgetbookUseCase(
        name: 'Trilho de produtos',
        builder: (context) => SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.space2),
            itemBuilder: (context, index) => AppDiscoveryTile(
              icon: [
                AppIcons.confinamento,
                AppIcons.pecuaria,
                AppIcons.agricultura,
                AppIcons.sincronizar,
              ][index],
              label: [
                'Confinamento',
                'Pecuária',
                'Agricultura',
                'Sincronizar',
              ][index],
              onTap: () {},
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Trilho seletor (uma seção ativa)',
        builder: (context) => SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.space2),
            itemBuilder: (context, index) => AppDiscoveryTile(
              icon: [
                AppIcons.layers,
                AppIcons.boxes,
                AppIcons.scale,
                AppIcons.mapPin,
              ][index],
              label: [
                'Lotes',
                'Estoque',
                'Pesagens do dia',
                'Localização',
              ][index],
              selected: index == 0,
              onTap: () {},
            ),
          ),
        ),
      ),
    ],
  );
}
