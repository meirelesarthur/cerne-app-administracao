import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'app_icon.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';
import 'button.dart';
import 'card.dart';
import 'chip.dart';
import 'heading.dart';
import '../design/generated/app_layout.dart';

/// Card contêiner de um gráfico, com título, período, ação e nota de rodapé.
/// Compõe `AppCard` + `AppHeading` (nível 4), nunca reimplementa estilo de
/// card/título localmente (Lei 2 do CLAUDE.md).
///
/// As variações vivem aqui, em props: a Home usa `compact` + `onExpand` para
/// mostrar o mesmo gráfico do painel numa densidade menor, em vez de manter uma
/// segunda implementação do bloco.
class AppChartCard extends StatelessWidget {
  const AppChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.period,
    this.footnote,
    this.compact = false,
    this.onExpand,
    this.expandLabel = 'Abrir painel',
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  /// Recorte temporal do dado ("Últimos 6 meses"), exibido como chip ao lado
  /// do título — a pergunta que todo gráfico de gestão precisa responder antes
  /// de qualquer outra.
  final String? period;

  /// Origem, premissa ou ressalva do dado, no rodapé do card.
  final String? footnote;

  /// Densidade reduzida: sem subtítulo, para as fileiras da Home — o gráfico
  /// já foi apresentado no painel de origem e aqui só precisa do título.
  final bool compact;

  /// Quando presente, exibe o atalho de rodapé para o painel de origem.
  final VoidCallback? onExpand;

  final String expandLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppHeading(level: AppHeadingLevel.h4, child: Text(title)),
                      if (subtitle != null && !compact)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.space1,
                          ),
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: AppTypography.sm,
                              color: semantic.fgMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (period != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.space2),
                    child: AppChip(child: Text(period!)),
                  ),
                ?action,
              ],
            ),
          ),
          child,
          if (footnote != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space3),
              child: Text(
                footnote!,
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  color: semantic.fgSubtle,
                ),
              ),
            ),
          if (onExpand != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppButton(
                  variant: AppButtonVariant.ghost,
                  size: AppButtonSize.sm,
                  rightIcon: const AppIcon(
                    AppIcons.arrowRight,
                    size: AppSize.iconXs,
                  ),
                  onPressed: onExpand,
                  child: Text(expandLabel),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

WidgetbookComponent buildChartCardWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'ChartCard',
    useCases: [
      WidgetbookUseCase(
        name: 'Padrão',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: AppChartCard(
              title: 'Receitas x Despesas',
              subtitle: 'Últimos 6 meses',
              child: SizedBox(
                height: 120,
                child: Center(child: Text('Gráfico aqui')),
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Com ação',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: AppChartCard(
              title: 'Produção mensal',
              action: AppIcon(AppIcons.ellipsis, size: AppSize.iconSmPlus),
              child: SizedBox(
                height: 120,
                child: Center(child: Text('Gráfico aqui')),
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Período e nota de rodapé',
        builder: (context) => const Center(
          child: SizedBox(
            width: 320,
            child: AppChartCard(
              title: 'Despesa por centro de custo',
              period: '30 dias',
              footnote: 'Dados espelhados do AGRO365 web às 08:00.',
              child: SizedBox(
                height: 120,
                child: Center(child: Text('Gráfico aqui')),
              ),
            ),
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Compacto (Home)',
        builder: (context) => Center(
          child: SizedBox(
            width: 320,
            child: AppChartCard(
              title: 'Resultado',
              period: '6 meses',
              compact: true,
              onExpand: () {},
              child: const SizedBox(
                height: 96,
                child: Center(child: Text('Gráfico aqui')),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
