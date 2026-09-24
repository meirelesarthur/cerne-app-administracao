import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
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

/// Lista vertical de alertas no topo de uma home de gestão ("Radar").
///
/// A regra é: só entra aqui o que pede uma decisão hoje. Um indicador que está
/// dentro do esperado não vira alerta — vira gráfico mais abaixo. Alerta que
/// não leva a lugar nenhum é ruído, por isso [AppAlertItem.onTap] é o caminho
/// normal de uso.
///
/// Cada alerta é uma linha branca, um abaixo do outro: a gravidade aparece só
/// no quadrado do ícone, para a pilha não virar um mosaico de cores e o número
/// continuar legível.
class AppAlertStrip extends StatelessWidget {
  const AppAlertStrip({super.key, required this.items, this.maxItems});

  final List<AppAlertItem> items;

  /// Teto de alertas exibidos, na ordem recebida (a lista já vem por
  /// gravidade). Os excedentes não aparecem. `null` mostra todos.
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final visible = maxItems == null ? items : items.take(maxItems!).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.space2),
          _AlertRow(item: visible[i]),
        ],
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.item});

  final AppAlertItem item;

  static const double _tileSize = AppSize.controlSm;

  /// Mesma dupla bg/fg por tom que `AppChip` usa — theme-aware (gbMode).
  ({Color fg, Color bg}) _tone(AppSemanticColors s) => switch (item.tone) {
    AppAlertTone.critical => (fg: s.toneRedFg, bg: s.toneRedBg),
    AppAlertTone.warning => (fg: s.toneAmberFg, bg: s.toneAmberBg),
    AppAlertTone.info => (fg: s.toneBlueFg, bg: s.toneBlueBg),
    AppAlertTone.neutral => (fg: s.toneNeutralFg, bg: s.toneNeutralBg),
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final tone = _tone(semantic);
    final radius = BorderRadius.circular(AppRadius.lgPlus);

    final row = Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: semantic.bgSurface,
        borderRadius: radius,
        border: Border.all(color: semantic.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: _tileSize,
            height: _tileSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: AppIcon(item.icon, size: AppSize.iconSmPlus, color: tone.fg),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: AppTypography.lg,
                    fontWeight: AppTypography.weightBold,
                    height: AppTypography.lineHeightTight,
                    color: semantic.fgDefault,
                  ),
                ),
                const SizedBox(height: AppSpacing.half),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    height: AppTypography.lineHeightTight,
                    color: semantic.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          if (item.onTap != null) ...[
            const SizedBox(width: AppSpacing.space2),
            AppIcon(
              AppIcons.chevronRight,
              size: AppSize.iconSm,
              color: semantic.fgQuiet,
            ),
          ],
        ],
      ),
    );

    if (item.onTap == null) return row;

    return AppPressable(
      semanticLabel: '${item.value} ${item.label}',
      onPressed: item.onTap,
      borderRadius: radius,
      child: row,
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
        name: 'Máximo de 2',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppAlertStrip(items: sample, maxItems: 2),
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
