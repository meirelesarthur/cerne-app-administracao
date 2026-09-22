import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

const Map<AtivoEstado, ({String label, AppChipTone tone, AppIconData icon})>
_estadoMeta = {
  AtivoEstado.ativo: (
    label: 'Ativo',
    tone: AppChipTone.brand,
    icon: AppIcons.checkCircle2,
  ),
  AtivoEstado.manutencao: (
    label: 'Em manutenção',
    tone: AppChipTone.amber,
    icon: AppIcons.wrench,
  ),
};

const _todosAtivos = '__todos_ativos__';

Map<String, double> _valorPorCategoria(Iterable<Ativo> itens) {
  final total = <String, double>{};
  for (final ativo in itens) {
    total[ativo.categoria] = (total[ativo.categoria] ?? 0) + ativo.aquisicaoMil;
  }
  final ordenado = total.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Map.fromEntries(ordenado);
}

/// Painel **Ativos & Manutenção** (spec §4.5).
///
/// Era uma lista de equipamentos com três KPIs no topo e nenhum gráfico. Ganhou
/// a leitura que sustenta a decisão: onde o patrimônio está concentrado
/// (categoria) e quais máquinas já consumiram a maior parte da própria vida
/// útil. Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2.
class DashAtivos extends StatefulWidget {
  const DashAtivos({super.key});

  @override
  State<DashAtivos> createState() => _DashAtivosState();
}

class _DashAtivosState extends State<DashAtivos> {
  String? _ativoId;

  @override
  Widget build(BuildContext context) {
    final selecionados = _ativoId == null
        ? ativos
        : ativos.where((a) => a.id == _ativoId).toList();
    final totalMil = selecionados.fold<double>(
      0,
      (sum, ativo) => sum + ativo.aquisicaoMil,
    );
    final depreciacaoMil = selecionados.fold<double>(
      0,
      (sum, ativo) => sum + ativo.depreciacaoMil,
    );
    final emManutencao = selecionados
        .where((a) => a.estado == AtivoEstado.manutencao)
        .length;
    final maisDepreciados = [...selecionados]
      ..sort((a, b) => b.depreciado.compareTo(a.depreciado));
    final porCategoria = _valorPorCategoria(selecionados);
    final todosSelecionados = _ativoId == null;

    return DashboardScreen(
      title: 'Ativos & Manutenção',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            label: 'Ativo',
            hint: todosSelecionados
                ? 'Visão consolidada de todo o patrimônio.'
                : 'Os indicadores e gráficos mostram apenas este ativo.',
            child: AppFormSelect(
              options: [
                const AppFormSelectOption(
                  value: _todosAtivos,
                  label: 'Todos os ativos',
                ),
                for (final ativo in ativos)
                  AppFormSelectOption(value: ativo.id, label: ativo.nome),
              ],
              value: _ativoId ?? _todosAtivos,
              onChanged: (value) => setState(
                () => _ativoId = value == _todosAtivos ? null : value,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppMetricGrid(
            children: [
              AppKpiStatCard(
                label: 'Aquisição',
                value: formatMilhares(totalMil),
              ),
              AppKpiStatCard(
                label: 'Depreciação',
                value: formatMilhares(depreciacaoMil),
                tone: AppKpiStatTone.negative,
              ),
              AppKpiStatCard(
                label: 'Líquido',
                value: formatMilhares(totalMil - depreciacaoMil),
                tone: AppKpiStatTone.positive,
              ),
              AppKpiStatCard(
                label: 'Em manutenção',
                value: '$emManutencao',
                tone: emManutencao > 0
                    ? AppKpiStatTone.warning
                    : AppKpiStatTone.neutral,
                caption: 'de ${selecionados.length} ativos',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Patrimônio por categoria',
            footnote:
                'Valor de aquisição; o líquido desconta a depreciação acumulada.',
            child: Center(
              child: AppDonutChart(
                centerValue: formatMilhares(totalMil),
                centerLabel: 'aquisição',
                data: [
                  for (final entry in porCategoria.entries)
                    AppDonutSlice(label: entry.key, value: entry.value),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Vida útil consumida',
            subtitle: 'Depreciação acumulada por ativo',
            child: AppBarChart(
              data: [
                for (final a in maisDepreciados)
                  AppBarDatum(label: a.nome, value: a.depreciado.toDouble()),
              ],
              formatValue: (v) => '${v.toStringAsFixed(0)}%',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppSectionTitle(
            child: Text(
              todosSelecionados ? 'Equipamentos' : 'Equipamento selecionado',
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Column(
            children: [
              for (final a in selecionados) ...[
                _AtivoCard(ativo: a),
                if (a != selecionados.last)
                  const SizedBox(height: AppSpacing.space2),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AtivoCard extends StatelessWidget {
  const _AtivoCard({required this.ativo});

  final Ativo ativo;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      interactive: true,
      padded: false,
      onTap: () => _showAtivoDetail(context, ativo),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ativo.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      AppTag(child: Text(ativo.categoria)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ativo.aquisicao,
                      style: TextStyle(
                        fontWeight: AppTypography.weightSemibold,
                        color: semantic.fgDefault,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppIcons.wrench,
                          size: AppSize.iconXs,
                          color: semantic.fgSubtle,
                        ),
                        const SizedBox(width: AppSpacing.space1),
                        Text(
                          ativo.proximaManutencao,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: semantic.fgSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                Expanded(
                  child: AppProgressBar(
                    value: ativo.depreciado.toDouble(),
                    tone: AppProgressBarTone.amber,
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  '${ativo.depreciado}%',
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightMedium,
                    color: semantic.fgMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showAtivoDetail(BuildContext context, Ativo ativo) {
  final estado = _estadoMeta[ativo.estado]!;

  showAppDetailPage<void>(
    context,
    title: 'Detalhe do ativo',
    child: Builder(
      builder: (context) {
        final semantic = Theme.of(context).extension<AppSemanticColors>()!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTag(child: Text(ativo.categoria)),
                      const SizedBox(height: AppSpacing.space1),
                      Text(
                        ativo.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.xl,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                    ],
                  ),
                ),
                AppChip(
                  tone: estado.tone,
                  icon: AppIcon(estado.icon, size: AppSize.iconXs),
                  child: Text(estado.label),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            AppReviewList(
              items: [
                AppReviewItem(label: 'Ano de aquisição', value: '${ativo.ano}'),
                AppReviewItem(
                  label: 'Valor de aquisição',
                  value: ativo.aquisicao,
                ),
                AppReviewItem(
                  label: 'Valor residual',
                  value: ativo.valorResidual,
                ),
                AppReviewItem(
                  label: 'Próxima manutenção',
                  value: ativo.proximaManutencao,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Depreciação acumulada',
                  style: TextStyle(color: semantic.fgMuted),
                ),
                Text(
                  '${ativo.depreciado}%',
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space1),
            AppProgressBar(
              value: ativo.depreciado.toDouble(),
              tone: AppProgressBarTone.amber,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Ficha completa do ativo, histórico de manutenções e anexos ficam no sistema web GB CERNE.',
              style: TextStyle(
                fontSize: AppTypography.base,
                color: semantic.fgSubtle,
              ),
            ),
          ],
        );
      },
    ),
  );
}
