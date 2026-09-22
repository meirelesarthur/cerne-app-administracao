import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';
import 'dashboard_screen.dart';

const _todosCurrais = '__todos_currais__';

/// Painel **Rebanho & Confinamento** (spec de Confinamento — Cadastro +
/// Nutrição), lido pelo perfil ADM.
///
/// Absorveu o bloco produtivo que o painel de Pecuária de Corte declarava como
/// LACUNA: GMD observado × previsto, desempenho do lote e ocupação já existiam
/// em `IndicadoresLote`, calculados a partir do lote e do histórico de
/// pesagens. Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2.
///
/// Decisão de perfil confirmada com o time: o ADM só **visualiza** — todo
/// cadastro (Pátio/Setor/Curral, Dieta, Fases) é feito pelo app web, que
/// divide o mesmo banco. Por isso esta tela nunca cria/edita nada; é a versão
/// completa (4 seções) do que antes era só "Lotação de Currais".
class DashConfinamento extends ConsumerStatefulWidget {
  const DashConfinamento({super.key});

  @override
  ConsumerState<DashConfinamento> createState() => _DashConfinamentoState();
}

class _DashConfinamentoState extends ConsumerState<DashConfinamento> {
  int _tab = 0;
  String? _curralId;

  static const _labels = ['Visão geral', 'Mapa', 'Nutrição', 'Relatórios'];

  @override
  Widget build(BuildContext context) {
    final confinamento = ref.watch(confinamentoStoreProvider);
    final currais = _curralId == null
        ? confinamento.currais
        : confinamento.currais.where((c) => c.id == _curralId).toList();

    return DashboardScreen(
      title: 'Rebanho & Confinamento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_tab == 0) ...[
            AppFormField(
              label: 'Curral',
              hint: _curralId == null
                  ? 'Visão consolidada de todos os currais.'
                  : 'Indicadores e gráficos filtrados por este curral.',
              child: AppFormSelect(
                options: [
                  const AppFormSelectOption(
                    value: _todosCurrais,
                    label: 'Todos os currais',
                  ),
                  for (final curral in confinamento.currais)
                    AppFormSelectOption(value: curral.id, label: curral.nome),
                ],
                value: _curralId ?? _todosCurrais,
                onChanged: (value) => setState(
                  () => _curralId = value == _todosCurrais ? null : value,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          AppSegmentedTabs(
            labels: _labels,
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.space5),
          switch (_tab) {
            0 => _VisaoGeral(currais: currais),
            1 => _Mapa(currais: confinamento.currais),
            2 => const _Nutricao(),
            _ => _Relatorios(
              bateladas: confinamento.bateladas,
              tratos: confinamento.tratosDiarios,
              leituras: confinamento.leiturasCocho,
            ),
          },
        ],
      ),
    );
  }
}

/* ---------------------------- Visão geral ---------------------------- */

class _VisaoGeral extends StatelessWidget {
  const _VisaoGeral({required this.currais});

  final List<CurralInfo> currais;

  @override
  Widget build(BuildContext context) {
    final ocupados = currais.where((c) => c.ocupado).toList();
    final totalCap = currais.fold<int>(0, (s, c) => s + c.capacidade);
    final totalAtual = ocupados.fold<int>(0, (s, c) => s + c.ocupacaoAtual);
    final ocupacaoPct = totalCap == 0
        ? 0
        : ((totalAtual / totalCap) * 100).round();

    final custosPorKg = confinamento_mocks.dietas
        .map((d) => d.custoPorKg)
        .where((v) => v > 0)
        .toList();
    final custoMedioKg = custosPorKg.isEmpty
        ? 0.0
        : custosPorKg.reduce((a, b) => a + b) / custosPorKg.length;

    final indicadores = ocupados
        .map((c) => c.indicadores)
        .whereType<IndicadoresLote>()
        .toList();
    final gmdMedio = indicadores.isEmpty
        ? 0.0
        : indicadores.map((i) => i.gmdKg).reduce((a, b) => a + b) /
              indicadores.length;
    final gmdPrevistoMedio = indicadores.isEmpty
        ? 0.0
        : indicadores.map((i) => i.gmdPrevistoKg).reduce((a, b) => a + b) /
              indicadores.length;

    final ocorrenciasAbertas = confinamento_mocks.leituraCochoRecente.avaliacoes
        .expand((a) => a.ocorrencias)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppMetricGrid(
          children: [
            AppKpiStatCard(
              label: 'Cabeças confinadas',
              value: '$totalAtual',
              caption: 'de $totalCap de capacidade',
            ),
            AppKpiStatCard(
              label: 'Custo médio/kg',
              value: 'R\$ ${custoMedioKg.toStringAsFixed(2)}',
            ),
            AppKpiStatCard(
              label: 'GMD médio',
              value: '${gmdMedio.toStringAsFixed(2)} kg/dia',
              tone: gmdMedio >= gmdPrevistoMedio
                  ? AppKpiStatTone.positive
                  : AppKpiStatTone.warning,
              caption: 'previsto ${gmdPrevistoMedio.toStringAsFixed(2)}',
            ),
            AppKpiStatCard(
              label: 'Ocorrências abertas',
              value: '$ocorrenciasAbertas',
              tone: ocorrenciasAbertas > 0
                  ? AppKpiStatTone.negative
                  : AppKpiStatTone.neutral,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        // O painel de Pecuária de Corte exibia "Taxa de prenhez" e "Desmame"
        // como "—", desativados por falta de dado. O desempenho que o ADM de
        // fato acompanha — GMD observado contra o previsto — sempre existiu
        // aqui, em `IndicadoresLote`. Ver docs/ESTEIRA-DASHBOARDS-ADM.md, §2.
        AppChartCard(
          title: 'Ocupação e desempenho',
          footnote:
              'GMD observado × previsto do lote; o traço no medidor é a meta.',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppGauge(
                value: ocupacaoPct.toDouble(),
                label: 'ocupação dos currais',
              ),
              AppGauge(
                value: gmdMedio,
                max: gmdPrevistoMedio == 0 ? 1 : gmdPrevistoMedio * 1.2,
                target: gmdPrevistoMedio,
                valueLabel: gmdMedio.toStringAsFixed(2),
                label: 'GMD kg/dia',
                tone: gmdMedio >= gmdPrevistoMedio
                    ? AppGaugeTone.positive
                    : AppGaugeTone.warning,
              ),
            ],
          ),
        ),
        if (indicadores.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space4),
          AppChartCard(
            title: 'GMD por curral',
            subtitle: 'Observado contra o previsto de cada lote',
            child: AppBulletChart(
              targetLabel: 'previsto',
              formatValue: (v) =>
                  '${v.toStringAsFixed(2).replaceAll('.', ',')} kg',
              data: [
                for (final c in ocupados)
                  if (c.indicadores != null)
                    AppBulletDatum(
                      label: c.nome,
                      value: c.indicadores!.gmdKg,
                      target: c.indicadores!.gmdPrevistoKg,
                    ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space4),
        AppChartCard(
          title: 'Situação dos currais',
          child: Center(
            child: AppDonutChart(
              centerValue: '${currais.length}',
              centerLabel: 'currais',
              data: [
                for (final entry in _porSituacao(currais).entries)
                  AppDonutSlice(
                    label: entry.key.label,
                    value: entry.value.toDouble(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Quantidade de currais por situação, do mais frequente para o menos —
  /// fatias minúsculas no fim do donut em vez de espalhadas pelo anel.
  Map<CurralSituacao, int> _porSituacao(List<CurralInfo> currais) {
    final contagem = <CurralSituacao, int>{};
    for (final c in currais) {
      contagem[c.situacao] = (contagem[c.situacao] ?? 0) + 1;
    }
    final ordenado = contagem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(ordenado);
  }
}

/* -------------------------------- Mapa -------------------------------- */

class _Mapa extends StatelessWidget {
  const _Mapa({required this.currais});

  final List<CurralInfo> currais;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final patio in confinamento_mocks.patios) ...[
          AppSectionTitle(child: Text(patio.nome)),
          const SizedBox(height: AppSpacing.space2),
          for (final setor in confinamento_mocks.setores.where(
            (s) => s.patioId == patio.id,
          )) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Text(
                setor.nome,
                style: const TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.space3,
              crossAxisSpacing: AppSpacing.space3,
              childAspectRatio: 1.1,
              children: [
                for (final c in currais.where((c) => c.setorId == setor.id))
                  _CurralTile(curral: c),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
        ],
      ],
    );
  }
}

AppChipTone _situacaoTone(CurralSituacao s) => switch (s) {
  CurralSituacao.ocupado => AppChipTone.brand,
  CurralSituacao.vazio => AppChipTone.neutral,
  CurralSituacao.vazioSanitario || CurralSituacao.limpeza => AppChipTone.blue,
  CurralSituacao.manutencao || CurralSituacao.enfermaria => AppChipTone.amber,
  CurralSituacao.interditado => AppChipTone.red,
};

class _CurralTile extends StatelessWidget {
  const _CurralTile({required this.curral});

  final CurralInfo curral;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ind = curral.indicadores;

    return AppCard(
      interactive: true,
      padded: false,
      onTap: () => _showCurralDetail(context, curral),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    curral.nome,
                    style: TextStyle(
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                ),
                AppChip(
                  tone: _situacaoTone(curral.situacao),
                  child: Text(curral.situacao.label),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            if (ind != null) ...[
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    color: semantic.fgDefault,
                  ),
                  children: [
                    TextSpan(text: '${ind.totalAnimais}'),
                    TextSpan(
                      text: '/${curral.capacidade}',
                      style: TextStyle(color: semantic.fgSubtle),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              AppProgressBar(
                value: ind.totalAnimais.toDouble(),
                max: curral.capacidade.toDouble(),
                colorByOccupancy: true,
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'GMD ${ind.gmdKg.toStringAsFixed(2)} kg · desempenho ${ind.indicadorDesempenhoPct}%',
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  color: semantic.fgMuted,
                ),
              ),
            ] else
              Text(
                curral.liberacaoEm != null
                    ? 'Liberação prevista'
                    : 'Sem lote alocado',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: semantic.fgMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void _showCurralDetail(BuildContext context, CurralInfo curral) {
  final ind = curral.indicadores;

  showAppDetailPage<void>(
    context,
    title: curral.nome,
    child: AppReviewList(
      items: [
        AppReviewItem(label: 'Situação', value: curral.situacao.label),
        if (ind != null) ...[
          AppReviewItem(
            label: 'Cabeças',
            value: '${ind.totalAnimais}/${curral.capacidade}',
          ),
          AppReviewItem(
            label: 'Peso médio',
            value: '${ind.pesoMedioAtualKg.toStringAsFixed(0)} kg',
          ),
          AppReviewItem(
            label: 'Dias de confinamento',
            value: '${ind.diasConfinamento}',
          ),
          AppReviewItem(
            label: 'GMD',
            value: '${ind.gmdKg.toStringAsFixed(2)} kg/dia',
          ),
          AppReviewItem(
            label: 'Peso previsto pós-confinamento',
            value: '${ind.pesoPrevistoPosConfinamentoKg.toStringAsFixed(0)} kg',
          ),
          AppReviewItem(
            label: 'Desempenho',
            value: '${ind.indicadorDesempenhoPct}%',
          ),
        ] else if (curral.liberacaoEm != null)
          AppReviewItem(
            label: 'Liberação em',
            value:
                '${curral.liberacaoEm!.day}/${curral.liberacaoEm!.month}/${curral.liberacaoEm!.year}',
          ),
      ],
    ),
  );
}

/* ------------------------------ Nutrição ------------------------------ */

class _Nutricao extends StatelessWidget {
  const _Nutricao();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(child: Text('Dietas')),
        const SizedBox(height: AppSpacing.space2),
        for (final d in confinamento_mocks.dietas)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        d.produto,
                        style: TextStyle(
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      AppChip(child: Text(d.objetivo.label)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'Custo/kg R\$ ${d.custoPorKg.toStringAsFixed(2)} · '
                    'Média MS ${d.mediaMsPct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: semantic.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.space5),
        AppSectionTitle(
          child: Text('Plano de fases — ${confinamento_mocks.planoFases.nome}'),
        ),
        const SizedBox(height: AppSpacing.space2),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final etapa in confinamento_mocks.planoFases.etapas)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                  child: Row(
                    children: [
                      AppChip(child: Text('${etapa.ordem}ª etapa')),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(
                        child: Text(
                          '${confinamento_mocks.dietas.firstWhere((d) => d.id == etapa.dietaId).produto} · '
                          '${etapa.inicio.toInt()}–${etapa.fim.toInt()} '
                          '${etapa.regra == RegraTroca.porDias ? 'dias' : 'kg'}',
                          style: TextStyle(color: semantic.fgDefault),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ----------------------------- Relatórios ------------------------------ */

class _Relatorios extends StatelessWidget {
  const _Relatorios({
    required this.bateladas,
    required this.tratos,
    required this.leituras,
  });

  final List<Batelada> bateladas;
  final List<TratoDiario> tratos;
  final List<LeituraCocho> leituras;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ocorrencias = leituras
        .expand((l) => l.avaliacoes)
        .expand((a) => a.ocorrencias.map((o) => (avaliacao: a, ocorrencia: o)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(child: Text('Bateladas')),
        const SizedBox(height: AppSpacing.space2),
        for (final b in bateladas)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Batelada ${b.id.toUpperCase()}'),
                  AppChip(
                    tone: b.precisaoPct >= 95
                        ? AppChipTone.brand
                        : AppChipTone.amber,
                    child: Text('Precisão ${b.precisaoPct}%'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.space5),
        const AppSectionTitle(child: Text('Trato diário')),
        const SizedBox(height: AppSpacing.space2),
        for (final t in tratos)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${t.currentConcluidos}/${t.lancamentos.length} currais concluídos',
                  ),
                  Text(
                    '${t.totalFornecido.toStringAsFixed(0)} kg fornecidos',
                    style: TextStyle(color: semantic.fgMuted),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.space5),
        const AppSectionTitle(child: Text('Ocorrências abertas')),
        const SizedBox(height: AppSpacing.space2),
        if (ocorrencias.isEmpty)
          const AppEmptyState(title: 'Nenhuma ocorrência em aberto')
        else
          for (final item in ocorrencias)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppChip(
                      tone: switch (item.ocorrencia.prioridade) {
                        OcorrenciaPrioridade.alta => AppChipTone.red,
                        OcorrenciaPrioridade.media => AppChipTone.amber,
                        OcorrenciaPrioridade.baixa => AppChipTone.neutral,
                      },
                      child: Text(item.ocorrencia.prioridade.name),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        item.ocorrencia.descricao,
                        style: TextStyle(color: semantic.fgDefault),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
