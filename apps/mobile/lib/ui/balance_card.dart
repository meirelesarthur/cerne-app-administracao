import 'dart:math' as math;

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

/// Cartão-herói do padrão global — o `Dashboard Hero` do frame
/// `administrativo-home` do Figma (`54300:16089`).
///
/// Anatomia medida: gradiente diagonal `hero.from → hero.to` no ângulo
/// [AppComponentMetrics.heroAngle], raio [AppRadius.surface] (24), `p 20`,
/// `gap 20` e sombra `AppShadows.hero`. No topo, uma caixa de 40 px (raio
/// [AppRadius.tile], fundo `hero.overlay`) com o ícone de 24 px, o nome da
/// conta em 14 px Bold e a linha de agência em 11 px; abaixo, a legenda de
/// 14 px Medium e o saldo em 32 px Bold; ao pé, uma divisória e o [footer].
///
/// Substitui o herói "ink" anterior (superfície chapada + glow radial): a
/// referência resolve a profundidade com o próprio gradiente, e manter as duas
/// técnicas empilhadas deixava o cartão mais escuro do que o Figma nas bordas.
class AppBalanceCard extends StatelessWidget {
  const AppBalanceCard({
    super.key,
    this.label = 'Saldo disponível',
    required this.value,
    this.title,
    this.accountLabel,
    this.icon = AppIcons.banking,
    this.hidden = false,
    this.onToggleHidden,
    this.loading = false,
    this.note,
    this.noteIcon,
    this.footer,
  });

  /// Legenda do saldo — "Conta corrente" no Figma.
  final String label;
  final String value;

  /// Nome da conta, na linha de cima. Ausente encolhe o cabeçalho para só a
  /// legenda e o saldo.
  final String? title;

  /// Agência e número, abaixo de [title].
  final String? accountLabel;

  final AppIconData icon;
  final bool hidden;
  final VoidCallback? onToggleHidden;
  final bool loading;

  /// Linha de apoio sob o saldo ("R$ 128.450,32 pré-aprovado").
  final String? note;
  final AppIconData? noteIcon;

  final Widget? footer;

  /// Aresta da caixa de ícone do cabeçalho.
  static const double _iconBoxSize = AppSpacing.space10;

  /// Altura reservada ao saldo — mantém o layout estável entre carregando e
  /// carregado.
  static const double _valueSlot = 40;

  /// Altura da barra do esqueleto dentro de [_valueSlot].
  static const double _skeletonHeight = 36;

  /// O gradiente do Figma é declarado em graus CSS (0° aponta para cima, o
  /// sentido cresce em horário). O Flutter quer duas âncoras no quadrado de
  /// alinhamento; converter aqui mantém `component.hero.angle` como o único
  /// lugar onde o ângulo existe.
  static ({Alignment begin, Alignment end}) get _gradientAxis {
    final radians = AppComponentMetrics.heroAngle * math.pi / 180;
    final dx = math.sin(radians);
    final dy = math.cos(radians);
    return (begin: Alignment(-dx, dy), end: Alignment(dx, -dy));
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final axis = _gradientAxis;

    return Semantics(
      label: label,
      container: true,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: axis.begin,
            end: axis.end,
            colors: [semantic.heroFrom, semantic.heroTo],
          ),
          borderRadius: BorderRadius.circular(AppRadius.surface),
          boxShadow: AppShadows.hero,
        ),
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(
              icon: icon,
              title: title,
              accountLabel: accountLabel,
              hidden: hidden,
              onToggleHidden: onToggleHidden,
              semantic: semantic,
              iconBoxSize: _iconBoxSize,
            ),
            const SizedBox(height: AppSpacing.space5),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.md,
                fontWeight: AppTypography.weightMedium,
                color: semantic.heroFgSubtle,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            SizedBox(
              height: _valueSlot,
              child: Align(
                alignment: Alignment.centerLeft,
                child: loading
                    ? FractionallySizedBox(
                        widthFactor: 2 / 3,
                        child: Container(
                          height: _skeletonHeight,
                          decoration: BoxDecoration(
                            color: semantic.heroOverlay,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      )
                    : Text(
                        hidden ? '••••••' : value,
                        style: TextStyle(
                          fontSize: AppTypography.xl4,
                          fontWeight: AppTypography.weightBold,
                          height: AppTypography.lineHeightTight,
                          color: semantic.heroFg,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
              ),
            ),
            if (note != null) ...[
              const SizedBox(height: AppSpacing.space1),
              Row(
                children: [
                  if (noteIcon != null) ...[
                    AppIcon(
                      noteIcon!,
                      size: AppSize.iconSmPlus,
                      color: semantic.heroFgSubtle,
                    ),
                    const SizedBox(width: AppSpacing.space1),
                  ],
                  Flexible(
                    child: Text(
                      note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppTypography.md,
                        fontWeight: AppTypography.weightMedium,
                        color: semantic.heroFgSubtle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (footer != null)
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.space5),
                padding: const EdgeInsets.only(top: AppSpacing.space5),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: semantic.heroLine)),
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.title,
    required this.accountLabel,
    required this.hidden,
    required this.onToggleHidden,
    required this.semantic,
    required this.iconBoxSize,
  });

  final AppIconData icon;
  final String? title;
  final String? accountLabel;
  final bool hidden;
  final VoidCallback? onToggleHidden;
  final AppSemanticColors semantic;
  final double iconBoxSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: semantic.heroOverlay,
            borderRadius: BorderRadius.circular(AppRadius.tile),
          ),
          child: AppIcon(icon, size: AppSize.iconLg, color: semantic.heroFg),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    fontWeight: AppTypography.weightBold,
                    color: semantic.heroFg,
                  ),
                ),
              if (accountLabel != null)
                Text(
                  accountLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    color: semantic.heroFgMuted,
                  ),
                ),
            ],
          ),
        ),
        if (onToggleHidden != null)
          Semantics(
            button: true,
            toggled: hidden,
            label: hidden ? 'Mostrar saldo' : 'Ocultar saldo',
            child: Material(
              color: AppColors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onToggleHidden,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: AppSize.control,
                  height: AppSize.control,
                  child: AppIcon(
                    hidden ? AppIcons.eyeOff : AppIcons.eye,
                    size: AppSize.iconLg,
                    color: semantic.heroFg,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Coluna de resumo para o footer do [AppBalanceCard] — as `Monthly Stats` do
/// Figma (`54300:16104`): caixa de 32 px com raio [AppRadius.lgPlus], legenda
/// de 11 px e valor de 14 px Bold.
class AppBalanceSummaryItem extends StatelessWidget {
  const AppBalanceSummaryItem({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.hidden = false,
  });

  final Widget? icon;
  final String label;
  final String value;
  final bool hidden;

  /// Aresta da caixa de ícone do resumo.
  static const double _boxSize = AppSpacing.space8;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Container(
            width: _boxSize,
            height: _boxSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lgPlus),
              color: semantic.heroOverlay,
            ),
            alignment: Alignment.center,
            child: IconTheme.merge(
              data: IconThemeData(color: semantic.heroFg, size: AppSize.iconXs),
              child: icon!,
            ),
          ),
          const SizedBox(width: AppSpacing.oneHalf),
        ],
        // `Flexible` + reticências: os dois resumos dividem a largura do herói,
        // e um valor longo ("-R$ 214.349,68") estoura a coluna se ela puder
        // crescer pelo conteúdo.
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  color: semantic.heroFgSubtle,
                ),
              ),
              Text(
                hidden ? '•••••' : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  fontWeight: AppTypography.weightBold,
                  color: semantic.heroFg,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

WidgetbookComponent buildBalanceCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'BalanceCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Herói do Banking',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppBalanceCard(
            title: 'Conta GB Banking',
            accountLabel: 'Conta 48213-7 • Ag. 0001',
            label: 'Conta corrente',
            value: r'R$ 128.450,32',
            note: r'R$ 128.450,32 pré-aprovado',
            noteIcon: AppIcons.creditCardAccept,
            onToggleHidden: () {},
            footer: const Row(
              children: [
                Expanded(
                  child: AppBalanceSummaryItem(
                    icon: AppIcon(AppIcons.arrowDownLeft),
                    label: 'Entradas no mês',
                    value: r'+R$ 342.800,00',
                  ),
                ),
                SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: AppBalanceSummaryItem(
                    icon: AppIcon(AppIcons.arrowUpRight),
                    label: 'Saídas no mês',
                    value: r'-R$ 214.349,68',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Saldo oculto',
        builder: (context) => Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: AppBalanceCard(
            title: 'Conta GB Banking',
            accountLabel: 'Conta 48213-7 • Ag. 0001',
            value: r'R$ 128.450,32',
            hidden: true,
            onToggleHidden: () {},
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Carregando',
        builder: (context) => const Padding(
          padding: EdgeInsets.all(AppSpacing.space4),
          child: AppBalanceCard(value: '', loading: true),
        ),
      ),
    ],
  );
}
