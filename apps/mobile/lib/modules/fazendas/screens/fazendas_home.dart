import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../components/activity_detail_sheet.dart';
import '../components/activity_list_item.dart';
import '../components/credito_banner.dart';
import '../components/shortcut_grid.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../mocks/atividades.dart';
import '../mocks/dashboards_mocks.dart';
import '../types.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Home do módulo Fazendas (aba Dashboard) — espelha `FazendasHome.tsx`.
/// O CERNE ADM tem um perfil único, então a home é sempre a gerencial.
class FazendasHome extends StatelessWidget {
  const FazendasHome({super.key});

  @override
  Widget build(BuildContext context) => const _HomeGerencial();
}

/// Home do perfil administrativo — torre de controle.
///
/// Era: título, cinco atalhos, banner de crédito, três cartões (receita, custo
/// e margem com **os mesmos valores** do painel de Pecuária) e uma lista de
/// atividades. Passou a ser a leitura de decisão do dia, na ordem em que ela é
/// feita: primeiro o que está fora do lugar (faixa de alertas), depois o mapa
/// dos painéis, depois o melhor gráfico de cada um.
///
/// Regra desta tela: cada bloco reusa o **mesmo widget** do painel de origem —
/// `AppChartCard(compact: true)` sobre o mesmo gráfico. Nenhum gráfico é
/// reimplementado aqui (Lei 2). Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 3.
class _HomeGerencial extends StatelessWidget {
  const _HomeGerencial();

  static const _resultado = '/fazendas/dashboards/resultado';
  static const _confinamento = '/fazendas/dashboards/confinamento';
  static const _suprimentos = '/fazendas/dashboards/suprimentos';
  static const _ativos = '/fazendas/dashboards/ativos';
  static const _uso = '/fazendas/dashboards/uso';

  /// Só entra na faixa o que pede decisão hoje — e cada cápsula leva ao painel
  /// que explica o número. Indicador dentro do esperado não vira alerta: vira
  /// gráfico mais abaixo.
  List<AppAlertItem> _alertas(BuildContext context) {
    final currais = confinamento_mocks.currais;
    final lotados = currais
        .where(
          (c) =>
              c.ocupado &&
              c.capacidade > 0 &&
              c.ocupacaoAtual / c.capacidade >= 0.9,
        )
        .length;
    final ocorrencias = confinamento_mocks.leituraCochoRecente.avaliacoes
        .expand((a) => a.ocorrencias)
        .length;
    final emManutencao = ativos
        .where((a) => a.estado == AtivoEstado.manutencao)
        .length;
    final aguardando = cotacoes
        .where((c) => c.status == CotacaoStatus.cotacao)
        .length;

    return [
      AppAlertItem(
        label: 'vencidos',
        value: FinanceiroKpis.atrasados,
        icon: AppIcons.circleAlert,
        tone: AppAlertTone.critical,
        onTap: () => context.go(_resultado),
      ),
      if (ocorrencias > 0)
        AppAlertItem(
          label: 'ocorrências no cocho',
          value: '$ocorrencias',
          icon: AppIcons.triangleAlert,
          onTap: () => context.go(_confinamento),
        ),
      if (lotados > 0)
        AppAlertItem(
          label: 'currais acima de 90%',
          value: '$lotados',
          icon: AppIcons.warehouse,
          onTap: () => context.go(_confinamento),
        ),
      if (aguardando > 0)
        AppAlertItem(
          label: 'cotações a decidir',
          value: '$aguardando',
          icon: AppIcons.receipt,
          tone: AppAlertTone.info,
          onTap: () => context.go(_suprimentos),
        ),
      if (emManutencao > 0)
        AppAlertItem(
          label: 'ativos em manutenção',
          value: '$emManutencao',
          icon: AppIcons.wrench,
          tone: AppAlertTone.info,
          onTap: () => context.go(_ativos),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final adminShortcuts = [
      Shortcut(
        id: 'resultado',
        label: 'Resultado',
        icon: AppIcons.wallet,
        onTap: () => context.go(_resultado),
      ),
      Shortcut(
        id: 'confinamento',
        label: 'Rebanho',
        icon: AppIcons.warehouse,
        onTap: () => context.go(_confinamento),
      ),
      Shortcut(
        id: 'suprimentos',
        label: 'Compras',
        icon: AppIcons.boxes,
        onTap: () => context.go(_suprimentos),
      ),
      Shortcut(
        id: 'ativos',
        label: 'Ativos',
        icon: AppIcons.package,
        onTap: () => context.go(_ativos),
      ),
      Shortcut(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        onTap: () => context.go('/fazendas/mais'),
      ),
    ];

    final currais = confinamento_mocks.currais;
    final ocupados = currais.where((c) => c.ocupado).toList();
    final capacidade = currais.fold<int>(0, (s, c) => s + c.capacidade);
    final alojados = ocupados.fold<int>(0, (s, c) => s + c.ocupacaoAtual);
    final ocupacaoPct = capacidade == 0 ? 0.0 : (alojados / capacidade) * 100;
    final indicadores = ocupados
        .map((c) => c.indicadores)
        .whereType<IndicadoresLote>()
        .toList();
    final gmd = indicadores.isEmpty
        ? 0.0
        : indicadores.map((i) => i.gmdKg).reduce((a, b) => a + b) /
              indicadores.length;
    final gmdPrevisto = indicadores.isEmpty
        ? 0.0
        : indicadores.map((i) => i.gmdPrevistoKg).reduce((a, b) => a + b) /
              indicadores.length;

    final patrimonio = <String, double>{};
    for (final a in ativos) {
      patrimonio[a.categoria] = (patrimonio[a.categoria] ?? 0) + a.aquisicaoMil;
    }

    return _ActivityAwareList(
      builder: (context, onActivityTap) => ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          const RiseIn(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppHeading(
                  level: AppHeadingLevel.h3,
                  child: Text('Resumo da safra'),
                ),
                _SafraPill(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(index: 1, child: AppAlertStrip(items: _alertas(context))),
          const SizedBox(height: AppSpacing.space4),
          RiseIn(
            index: 2,
            child: ShortcutGrid(items: adminShortcuts, columns: 5),
          ),
          const SizedBox(height: AppSpacing.space4),
          const RiseIn(index: 3, child: CreditoBanner()),
          const SizedBox(height: AppSpacing.space4),
          RiseIn(
            index: 4,
            child: AppChartCard(
              title: 'Resultado',
              period: '6 meses',
              compact: true,
              onExpand: () => context.go(_resultado),
              footnote:
                  'Margem do mês: ${formatMilhares(resultadoMeses.last.margem)}.',
              child: AppLineChart(
                compact: true,
                labels: [for (final m in resultadoMeses) m.label],
                series: [
                  AppLineSeries(
                    label: 'Receita',
                    points: [for (final m in resultadoMeses) m.receita],
                    filled: true,
                  ),
                  AppLineSeries(
                    label: 'Custo',
                    points: [for (final m in resultadoMeses) m.custo],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(
            index: 5,
            child: AppChartCard(
              title: 'Ocupação e GMD',
              compact: true,
              onExpand: () => context.go(_confinamento),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppGauge(value: ocupacaoPct, label: 'ocupação'),
                  AppGauge(
                    value: gmd,
                    max: gmdPrevisto == 0 ? 1 : gmdPrevisto * 1.2,
                    target: gmdPrevisto,
                    valueLabel: gmd.toStringAsFixed(2),
                    label: 'GMD kg/dia',
                    tone: gmd >= gmdPrevisto
                        ? AppGaugeTone.positive
                        : AppGaugeTone.warning,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(
            index: 6,
            child: AppChartCard(
              title: 'Despesa por centro de custo',
              compact: true,
              onExpand: () => context.go(_resultado),
              child: AppBarChart(
                showGrid: false,
                data: [
                  for (final c in centrosCusto.take(4))
                    AppBarDatum(label: c.label, value: c.value),
                ],
                formatValue: (v) => '${v.toStringAsFixed(0)}k',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(
            index: 7,
            child: AppChartCard(
              title: 'Patrimônio por categoria',
              compact: true,
              onExpand: () => context.go(_ativos),
              child: Center(
                child: AppDonutChart(
                  centerValue: AtivosResumo.total,
                  centerLabel: 'aquisição',
                  data: [
                    for (final entry in patrimonio.entries)
                      AppDonutSlice(label: entry.key, value: entry.value),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(
            index: 8,
            child: AppChartCard(
              title: 'Adoção por fazenda',
              compact: true,
              onExpand: () => context.go(_uso),
              child: AppBulletChart(
                targetLabel: 'cadastrados',
                data: [
                  for (final f in usoFazendas)
                    AppBulletDatum(
                      label: f.nome,
                      value: f.online.toDouble(),
                      target: f.usuarios.length.toDouble(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          RiseIn(
            index: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppSectionTitle(child: Text('Atividades recentes')),
                    AppButton(
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      rightIcon: const AppIcon(
                        AppIcons.arrowRight,
                        size: AppSize.iconXs,
                      ),
                      onPressed: () => context.go('/fazendas/atividades'),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Builder(
                  builder: (context) {
                    final semantic = Theme.of(
                      context,
                    ).extension<AppSemanticColors>()!;
                    final recentes = atividades.take(4).toList();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                      ),
                      decoration: BoxDecoration(
                        color: semantic.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.xl3),
                        border: Border.all(color: semantic.borderDefault),
                      ),
                      child: Column(
                        children: [
                          for (final a in recentes)
                            ActivityListItem(
                              activity: a,
                              showDivider: a != recentes.last,
                              onTap: () => onActivityTap(a),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Encapsula o acionamento do `ActivityDetailSheet` — equivalente ao
/// `useState<Activity | null>` do React, sem precisar de `StatefulWidget` na
/// tela inteira (o bottom sheet já é a fonte de estado "aberto/fechado").
class _ActivityAwareList extends StatelessWidget {
  const _ActivityAwareList({required this.builder});

  final Widget Function(
    BuildContext context,
    void Function(Activity activity) onActivityTap,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      (activity) => showActivityDetailSheet(context, activity: activity),
    );
  }
}

class _SafraPill extends StatelessWidget {
  const _SafraPill();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: semantic.borderDefault),
        color: semantic.bgSurface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Safra 24/25',
            style: TextStyle(
              fontWeight: AppTypography.weightSemibold,
              fontSize: AppTypography.base,
              color: semantic.fgDefault,
            ),
          ),
          const SizedBox(width: AppSpacing.space1),
          AppIcon(
            AppIcons.chevronDown,
            size: AppSize.iconXs,
            color: semantic.fgDefault,
          ),
        ],
      ),
    );
  }
}
