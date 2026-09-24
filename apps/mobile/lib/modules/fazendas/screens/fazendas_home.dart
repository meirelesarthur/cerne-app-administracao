import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../ui/ui.dart';
import '../components/activity_list_item.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../mocks/atividades.dart';
import '../mocks/dashboards_mocks.dart';
import '../ordem_servico/models.dart';
import '../ordem_servico/state/ordem_servico_store.dart';
import '../recent_access_catalog.dart';
import '../state/fazendas_store.dart';
import '../state/recent_access_store.dart';

/// Aba **Visão geral** do módulo Fazendas — a primeira tela depois do login.
///
/// É a leitura que o gestor faz no desktop: primeiro os atalhos mais usados,
/// depois um bloco por painel de decisão, na mesma ordem
/// da aba Painéis, cada um com os um ou dois números que resumem o painel e
/// um "Ver painel" (no título do grupo, único atalho — os cards não repetem
/// "Abrir painel") que abre o painel completo.
///
/// Regra desta tela: cada bloco reusa o **mesmo widget e o mesmo dado** do
/// painel de origem — `AppKpiStatCard`/`AppChartCard(compact: true)` sobre os
/// mocks de `dashboards_mocks.dart`. Nenhum número é recalculado de outro
/// jeito aqui (Lei 2). Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 3.
class FazendasHome extends ConsumerWidget {
  const FazendasHome({super.key});

  static const _resultado = '/fazendas/dashboards/resultado';
  static const _confinamento = '/fazendas/dashboards/confinamento';
  static const _suprimentos = '/fazendas/dashboards/suprimentos';
  static const _ativos = '/fazendas/dashboards/ativos';
  static const _uso = '/fazendas/dashboards/uso';
  static const _os = '/fazendas/dashboards/ordem-servico';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmContext = ref.watch(
      fazendasStoreProvider.select(
        (s) => (id: s.activeFarmId, name: s.activeFarm.name),
      ),
    );
    final fazenda = farmContext.name;
    final recentFunctions = ref.watch(
      farmRecentAccessProvider.select((s) => s.forFarm(farmContext.id)),
    );
    final recentItems = [
      for (final recent in recentFunctions)
        if (farmQuickAccessDefinitionForId(recent.functionId)
            case final function?)
          AppQuickAccessItem(
            id: function.id,
            label: function.label,
            icon: function.icon,
            onPressed: () => context.push(recent.route),
          ),
    ];
    final recentIds = recentItems.map((item) => item.id).toSet();
    final quickAccessItems = [
      ...recentItems,
      for (final id in farmQuickAccessDefaultIds)
        if (!recentIds.contains(id))
          if (farmQuickAccessDefinitionForId(id) case final function?)
            AppQuickAccessItem(
              id: function.id,
              label: function.label,
              icon: function.icon,
              onPressed: () => context.push(function.route),
            ),
    ].take(farmRecentAccessLimit).toList(growable: false);
    final ordens = ref
        .watch(ordemServicoStoreProvider.select((s) => s.ordens))
        .where((o) => o.fazenda == fazenda)
        .toList();
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final osAbertas = ordens.where((o) => o.status.emAndamento).toList();
    final osAtrasadas = osAbertas.where((o) => o.prazo.isBefore(hoje)).length;
    final osAguardando = osAbertas
        .where((o) => o.status == OrdemServicoStatus.aguardando)
        .length;

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

    final emCotacao = cotacoes.where((c) => c.status == CotacaoStatus.cotacao);
    final aprovadas = cotacoes.where((c) => c.status == CotacaoStatus.aprovada);
    final totalAberto = emCotacao.fold<double>(0, (s, c) => s + c.totalValor);
    final totalAprovado = aprovadas.fold<double>(0, (s, c) => s + c.totalValor);

    final patrimonio = <String, double>{};
    for (final a in ativos) {
      patrimonio[a.categoria] = (patrimonio[a.categoria] ?? 0) + a.aquisicaoMil;
    }
    final emManutencao = ativos
        .where((a) => a.estado == AtivoEstado.manutencao)
        .length;

    var ordem = 0;
    Widget rise(Widget child) => RiseIn(index: ordem++, child: child);
    final scrollEndPadding =
        AppSpacing.space4 +
        AppLayout.tabBarClearance +
        MediaQuery.paddingOf(context).bottom;

    return Builder(
      builder: (context) => ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space4,
          AppSpacing.space4,
          scrollEndPadding,
        ),
        children: [
          rise(AppQuickAccessRail(items: quickAccessItems)),
          const SizedBox(height: AppSpacing.space5),

          // --- Resultado -------------------------------------------------
          rise(const _Grupo(titulo: 'Resultado', rota: _resultado)),
          rise(
            const AppMetricGrid(
              equalRowHeight: true,
              children: [
                AppKpiStatCard(
                  label: 'A receber',
                  value: FinanceiroKpis.aReceber,
                  tone: AppKpiStatTone.positive,
                ),
                AppKpiStatCard(
                  label: 'Contas vencidas',
                  value: FinanceiroKpis.atrasados,
                  tone: AppKpiStatTone.negative,
                  caption: 'Cobrar ou renegociar',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          rise(
            AppChartCard(
              title: 'Receita × custo',
              period: '6 meses',
              compact: true,
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
          const SizedBox(height: AppSpacing.space5),

          // --- Rebanho e confinamento -----------------------------------
          rise(
            const _Grupo(titulo: 'Rebanho e confinamento', rota: _confinamento),
          ),
          rise(
            AppChartCard(
              title: 'Ocupação dos currais e ganho de peso',
              compact: true,
              footnote:
                  'GMD = ganho médio diário por cabeça. A marca no medidor é o '
                  'previsto (${gmdPrevisto.toStringAsFixed(2)} kg/dia).',
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
          const SizedBox(height: AppSpacing.space5),

          // --- Ordens de serviço ----------------------------------------
          rise(
            const _Grupo(
              titulo: 'Ordens de serviço',
              rota: _os,
              acao: 'Ver OS',
            ),
          ),
          rise(
            AppMetricGrid(
              equalRowHeight: true,
              children: [
                AppKpiStatCard(
                  label: 'Em andamento',
                  value: '${osAbertas.length}',
                  caption: '$osAguardando aguardando início',
                ),
                AppKpiStatCard(
                  label: 'Prazo vencido',
                  value: '$osAtrasadas',
                  tone: osAtrasadas > 0
                      ? AppKpiStatTone.negative
                      : AppKpiStatTone.positive,
                  caption: osAtrasadas > 0
                      ? 'Cobrar a operação'
                      : 'Tudo dentro do prazo',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),

          // --- Suprimentos ----------------------------------------------
          rise(const _Grupo(titulo: 'Suprimentos', rota: _suprimentos)),
          rise(
            AppMetricGrid(
              equalRowHeight: true,
              children: [
                AppKpiStatCard(
                  label: 'Aguardando decisão',
                  value: formatMilhares(totalAberto / 1000),
                  caption: '${emCotacao.length} cotações para aprovar',
                  tone: AppKpiStatTone.warning,
                ),
                AppKpiStatCard(
                  label: 'Aprovado',
                  value: formatMilhares(totalAprovado / 1000),
                  caption: '${aprovadas.length} cotações',
                  tone: AppKpiStatTone.positive,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),

          // --- Ativos e depreciação -------------------------------------
          rise(const _Grupo(titulo: 'Ativos e depreciação', rota: _ativos)),
          rise(
            AppChartCard(
              title: 'Patrimônio por categoria',
              compact: true,
              footnote: switch (emManutencao) {
                0 => 'Nenhum ativo em manutenção.',
                1 => '1 ativo em manutenção agora.',
                _ => '$emManutencao ativos em manutenção agora.',
              },
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
          const SizedBox(height: AppSpacing.space5),

          // --- Adoção e governança --------------------------------------
          rise(const _Grupo(titulo: 'Adoção e governança', rota: _uso)),
          rise(
            AppChartCard(
              title: 'Pessoas usando o app por fazenda',
              compact: true,
              footnote: 'Barra = usuários ativos agora; traço = cadastrados.',
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
          const SizedBox(height: AppSpacing.space5),
          rise(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionTitle(
                  action: AppButton(
                    variant: AppButtonVariant.soft,
                    size: AppButtonSize.sm,
                    rightIcon: const AppIcon(
                      AppIcons.arrowRight,
                      size: AppSize.iconXs,
                    ),
                    onPressed: () => context.push('/fazendas/atividades'),
                    child: const Text('Ver todas'),
                  ),
                  child: const Text('Atividades recentes'),
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
                              onTap: () => context.push(kindRoute[a.kind]!),
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

/// Agrupador de um painel na Visão geral: o nome do painel (o mesmo da aba
/// Painéis) e um "Ver painel" à direita que abre o painel completo.
class _Grupo extends StatelessWidget {
  const _Grupo({required this.titulo, required this.rota, this.acao});

  final String titulo;
  final String rota;
  final String? acao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: AppSectionTitle(
        action: AppButton(
          variant: AppButtonVariant.soft,
          size: AppButtonSize.sm,
          rightIcon: const AppIcon(AppIcons.arrowRight, size: AppSize.iconXs),
          onPressed: () => context.push(rota),
          child: Text(acao ?? 'Ver painel'),
        ),
        child: Text(titulo),
      ),
    );
  }
}
