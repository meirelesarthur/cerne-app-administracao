import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_colors.dart';
import '../design/generated/app_radius.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'pressable.dart';
import '../design/generated/app_layout.dart';

/// Gravidade do alerta — define a cor da cápsula.
enum AppAlertTone { critical, warning, info, neutral }

/// Um alerta acionável: o número, o que ele significa e para onde ele leva.
class AppAlertItem {
  const AppAlertItem({
    required this.label,
    required this.value,
    required this.icon,
    this.tone = AppAlertTone.warning,
    this.onTap,
  });

  /// O que o número significa ("vencidos", "currais acima de 90%").
  final String label;

  /// O número em si, já formatado.
  final String value;

  final AppIconData icon;
  final AppAlertTone tone;

  /// Painel de origem, idealmente já no recorte que explica o alerta.
  final VoidCallback? onTap;
}

/// Faixa horizontal de alertas no topo de uma home de gestão.
///
/// A regra é: só entra aqui o que pede uma decisão hoje. Um indicador que está
/// dentro do esperado não vira cápsula — vira gráfico mais abaixo. Alerta que
/// não leva a lugar nenhum é ruído, por isso [AppAlertItem.onTap] é o caminho
/// normal de uso.
class AppAlertStrip extends StatelessWidget {
  const AppAlertStrip({super.key, required this.items});

  final List<AppAlertItem> items;

  static const double _height = AppSpacing.space16;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.space2),
        itemBuilder: (context, index) => _AlertPill(item: items[index]),
      ),
    );
  }
}

class _AlertPill extends StatelessWidget {
  const _AlertPill({required this.item});

  final AppAlertItem item;

  ({Color fg, Color bg, Color border}) _palette(AppSemanticColors s) =>
      switch (item.tone) {
        // Mesma tríade bg/fg/border que `AppChip` já usa por tom — a cápsula
        // de alerta é a irmã maior do chip, não uma paleta nova.
        AppAlertTone.critical => (
          fg: AppColors.red600,
          bg: AppColors.red50,
          border: AppColors.red200,
        ),
        AppAlertTone.warning => (
          fg: AppColors.amber600,
          bg: AppColors.amber50,
          border: AppColors.amber200,
        ),
        AppAlertTone.info => (
          fg: AppColors.blue600,
          bg: AppColors.blue50,
          border: AppColors.blue200,
        ),
        AppAlertTone.neutral => (
          fg: s.fgMuted,
          bg: s.bgSubtle,
          border: s.borderDefault,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final palette = _palette(semantic);

    final pill = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: palette.bg,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(item.icon, size: AppSize.iconSm, color: palette.fg),
          const SizedBox(width: AppSpacing.space2),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: AppTypography.weightBold,
                  height: AppTypography.lineHeightTight,
                  color: palette.fg,
                ),
              ),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  height: AppTypography.lineHeightTight,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (item.onTap == null) return pill;

    return AppPressable(
      semanticLabel: '${item.value} ${item.label}',
      onPressed: item.onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl2),
      minTouchTarget: false,
      child: pill,
    );
  }
}

WidgetbookComponent buildAlertStripWidgetbookComponent() {
  final sample = [
    AppAlertItem(
      label: 'vencidos',
      value: 'R\$ 128 mil',
      icon: AppIcons.circleAlert,
      tone: AppAlertTone.critical,
      onTap: () {},
    ),
    AppAlertItem(
      label: 'ocorrências abertas',
      value: '3',
      icon: AppIcons.triangleAlert,
      onTap: () {},
    ),
    AppAlertItem(
      label: 'currais acima de 90%',
      value: '2',
      icon: AppIcons.warehouse,
      onTap: () {},
    ),
    AppAlertItem(
      label: 'ativos em manutenção',
      value: '2',
      icon: AppIcons.wrench,
      tone: AppAlertTone.info,
      onTap: () {},
    ),
  ];

  return WidgetbookComponent(
    name: 'AlertStrip',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppAlertStrip(items: sample),
        ),
      ),
      WidgetbookUseCase(
        name: 'Um alerta só',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppAlertStrip(items: [sample.first]),
        ),
      ),
      WidgetbookUseCase(
        name: 'Sem alertas',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppAlertStrip(items: []),
        ),
      ),
    ],
  );
}
