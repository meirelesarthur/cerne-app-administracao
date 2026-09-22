import 'package:flutter/material.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/dashboards_mocks.dart';
import 'dashboard_screen.dart';

const _todosTipos = '__todos_tipos__';

const Map<CotacaoTipo, String> _tipoLabel = {
  CotacaoTipo.produto: 'Produto',
  CotacaoTipo.servico: 'Serviço',
  CotacaoTipo.frete: 'Frete',
  CotacaoTipo.manutencao: 'Manutenção',
};

const Map<CotacaoStatus, ({String label, AppChipTone tone})> _statusMeta = {
  CotacaoStatus.cotacao: (label: 'Em cotação', tone: AppChipTone.blue),
  CotacaoStatus.aprovada: (label: 'Aprovada', tone: AppChipTone.brand),
  CotacaoStatus.recusada: (label: 'Recusada', tone: AppChipTone.red),
};

/// Formata número cru do mock como preço em reais (aproximação manual — o
/// projeto não tem `intl` instalado — mesmo padrão de `precoAtual`).
String _formatPreco(double v) =>
    'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

/// Painel **Suprimentos** (spec §4.4) — status PARCIAL: UI completa com mock,
/// fonte a confirmar.
///
/// Era uma lista filtrável sem nenhum indicador: para saber quanto estava em
/// jogo, o administrador tinha de somar os cartões de cabeça. Ganhou o topo de
/// KPI e as duas leituras que sustentam a decisão de compra — onde o dinheiro
/// está e como o preço unitário se moveu contra a cotação anterior.
/// Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2.
class DashSuprimentos extends StatefulWidget {
  const DashSuprimentos({super.key});

  @override
  State<DashSuprimentos> createState() => _DashSuprimentosState();
}

class _DashSuprimentosState extends State<DashSuprimentos> {
  CotacaoTipo? _filtro;

  /// Valor cotado por tipo, do maior para o menor.
  Map<CotacaoTipo, double> _porTipo(Iterable<Cotacao> itens) {
    final total = <CotacaoTipo, double>{};
    for (final c in itens) {
      total[c.tipo] = (total[c.tipo] ?? 0) + c.totalValor;
    }
    final ordenado = total.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(ordenado);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final lista = cotacoes
        .where((c) => _filtro == null || c.tipo == _filtro)
        .toList();

    final emCotacao = lista.where((c) => c.status == CotacaoStatus.cotacao);
    final aprovadas = lista.where((c) => c.status == CotacaoStatus.aprovada);
    final totalAberto = emCotacao.fold<double>(0, (s, c) => s + c.totalValor);
    final totalAprovado = aprovadas.fold<double>(0, (s, c) => s + c.totalValor);
    final quedas = lista.where((c) => c.variacao < 0).length;
    final fornecedores = lista.map((c) => c.fornecedor).toSet().length;

    return DashboardScreen(
      title: 'Suprimentos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            label: 'Tipo de cotação',
            hint: _filtro == null
                ? 'Visão consolidada de todos os tipos.'
                : 'KPIs e gráficos filtrados por ${_tipoLabel[_filtro]}',
            child: AppFormSelect(
              options: [
                const AppFormSelectOption(
                  value: _todosTipos,
                  label: 'Todos os tipos',
                ),
                for (final tipo in CotacaoTipo.values)
                  AppFormSelectOption(
                    value: tipo.name,
                    label: _tipoLabel[tipo]!,
                  ),
              ],
              value: _filtro?.name ?? _todosTipos,
              onChanged: (value) => setState(
                () => _filtro = value == _todosTipos || value == null
                    ? null
                    : CotacaoTipo.values.byName(value),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppMetricGrid(
            children: [
              AppKpiStatCard(
                label: 'Aguardando decisão',
                value: formatMilhares(totalAberto / 1000),
                caption: '${emCotacao.length} aguardando decisão',
                tone: AppKpiStatTone.warning,
              ),
              AppKpiStatCard(
                label: 'Aprovado',
                value: formatMilhares(totalAprovado / 1000),
                caption: '${aprovadas.length} cotações',
                tone: AppKpiStatTone.positive,
              ),
              AppKpiStatCard(
                label: 'Preços em queda',
                value: '$quedas',
                caption: 'de ${lista.length} itens cotados',
              ),
              AppKpiStatCard(label: 'Fornecedores', value: '$fornecedores'),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Valor cotado por tipo',
            footnote: 'Inclui cotações abertas, aprovadas e recusadas.',
            child: Center(
              child: AppDonutChart(
                data: [
                  for (final entry in _porTipo(lista).entries)
                    AppDonutSlice(
                      label: _tipoLabel[entry.key]!,
                      value: entry.value,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'Preço unitário × cotação anterior',
            subtitle: 'Abaixo do traço é economia',
            child: AppBulletChart(
              targetLabel: 'anterior',
              formatValue: _formatPreco,
              data: [
                for (final c in lista)
                  AppBulletDatum(
                    label: c.produto,
                    value: c.historico.last,
                    target: c.historico[c.historico.length - 2],
                    // A cor não pode vir do padrão do componente: em preço,
                    // ficar ABAIXO da referência é o resultado bom.
                    color: c.variacao <= 0
                        ? semantic.chartPositive
                        : semantic.chartNegative,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Cotações')),
          const SizedBox(height: AppSpacing.space2),
          Column(
            children: [
              for (final c in lista) ...[
                _CotacaoCard(cotacao: c),
                if (c != lista.last) const SizedBox(height: AppSpacing.space2),
              ],
            ],
          ),
          if (lista.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space6),
              child: Center(
                child: Text(
                  'Nenhuma cotação encontrada',
                  style: TextStyle(color: semantic.fgSubtle),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CotacaoCard extends StatelessWidget {
  const _CotacaoCard({required this.cotacao});

  final Cotacao cotacao;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final status = _statusMeta[cotacao.status]!;

    return AppCard(
      interactive: true,
      padded: false,
      onTap: () => _showCotacaoDetail(context, cotacao),
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
                        cotacao.fornecedor,
                        style: TextStyle(
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      Text(
                        '${_tipoLabel[cotacao.tipo]} · ${cotacao.itens} itens',
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          color: semantic.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppChip(tone: status.tone, child: Text(status.label)),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cotacao.total,
                  style: TextStyle(
                    fontSize: AppTypography.xl,
                    fontWeight: AppTypography.weightBold,
                    color: semantic.fgDefault,
                  ),
                ),
                Text(
                  'Dados de exemplo',
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    fontStyle: FontStyle.italic,
                    color: semantic.fgSubtle,
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

void _showCotacaoDetail(BuildContext context, Cotacao c) {
  final status = _statusMeta[c.status]!;
  final alta = c.variacao >= 0;
  const historicoLabels = ['2 cotações atrás', 'Cotação anterior', 'Atual'];

  showAppDetailPage<void>(
    context,
    title: 'Detalhe da cotação',
    child: Builder(
      builder: (context) {
        final semantic = Theme.of(context).extension<AppSemanticColors>()!;
        final variacaoColor = alta ? semantic.accentDefault : AppColors.red600;

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
                      Text(
                        _tipoLabel[c.tipo]!.toUpperCase(),
                        style: TextStyle(
                          fontSize: AppTypography.xs,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgSubtle,
                        ),
                      ),
                      Text(
                        c.produto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.lg,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      Text(
                        c.fornecedor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          color: semantic.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppChip(tone: status.tone, child: Text(status.label)),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: Column(
                children: [
                  Text(
                    c.precoAtual,
                    style: TextStyle(
                      fontSize: AppTypography.xl3,
                      fontWeight: AppTypography.weightBold,
                      color: semantic.fgDefault,
                    ),
                  ),
                  Text(
                    'por ${c.unidade}',
                    style: TextStyle(
                      fontSize: AppTypography.xs,
                      color: semantic.fgSubtle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        alta ? AppIcons.trendingUp : AppIcons.trendingDown,
                        size: AppSize.iconXs,
                        color: variacaoColor,
                      ),
                      const SizedBox(width: AppSpacing.space1),
                      Text(
                        '${alta ? '+' : ''}${c.variacao.toStringAsFixed(1)}% frente à cotação anterior',
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: AppTypography.weightSemibold,
                          color: variacaoColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppReviewList(
              items: [
                AppReviewItem(label: 'Unidade', value: c.unidade),
                AppReviewItem(label: 'Validade da cotação', value: c.validade),
                AppReviewItem(label: 'Itens', value: '${c.itens}'),
                AppReviewItem(label: 'Total', value: c.total),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Histórico de preço',
              style: TextStyle(
                fontSize: AppTypography.base,
                color: semantic.fgMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            AppSparklineArea(
              data: c.historico,
              color: variacaoColor,
              width: 240,
              height: 40,
            ),
            const SizedBox(height: AppSpacing.space2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < c.historico.length; i++)
                  Column(
                    children: [
                      Text(
                        historicoLabels[i],
                        style: TextStyle(
                          fontSize: AppTypography.xs,
                          color: semantic.fgSubtle,
                        ),
                      ),
                      Text(
                        _formatPreco(c.historico[i]),
                        style: TextStyle(
                          fontSize: AppTypography.base,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Dados de exemplo — ficha completa da cotação, anexos e histórico de negociação ficam no sistema web GB CERNE.',
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
