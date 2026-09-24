import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design/generated/app_spacing.dart';
import '../../../../ui/ui.dart';
import '../../state/fazendas_store.dart';
import '../models.dart';
import '../state/ordem_servico_store.dart';
import '../widgets.dart';
import 'os_detail_page.dart';

/// Painel de Ordens de Serviço (Administrativo): lista as OS da fazenda
/// ativa, filtráveis por status e por data de prazo. Criar abre em tela cheia
/// pelo "+ Nova O.S" que a moldura (`DashOrdemServico`) fixa no rodapé;
/// avaliar e cancelar ficam no detalhe em tela cheia ([OsDetailPage]).
/// Mesma OS e mesmo desenho que o app Operação lê em campo (Lei 2: uma única
/// OS, dois perfis de leitura/ação).
///
/// Conteúdo puro (sem scaffold/scroll próprio): a moldura de navegação é do
/// `DashboardScreen` que o envolve.
class OrdemServicoPainel extends ConsumerStatefulWidget {
  const OrdemServicoPainel({super.key});

  @override
  ConsumerState<OrdemServicoPainel> createState() => _OrdemServicoPainelState();
}

enum _FiltroStatus { todas, emAndamento, encerradas }

extension on _FiltroStatus {
  String get label => switch (this) {
    _FiltroStatus.todas => 'Todas',
    _FiltroStatus.emAndamento => 'Em andamento',
    _FiltroStatus.encerradas => 'Encerradas',
  };

  // Aguardando/Em execução/Pausada eram três abas para uma distinção que só
  // interessa dentro do detalhe — aqui, o gestor só precisa saber se a OS
  // ainda pede acompanhamento ou já fechou.
  bool aplica(OrdemServico os) => switch (this) {
    _FiltroStatus.todas => true,
    _FiltroStatus.emAndamento => os.status.emAndamento,
    _FiltroStatus.encerradas => os.status.encerrada,
  };
}

class _OrdemServicoPainelState extends ConsumerState<OrdemServicoPainel> {
  static const _filtros = _FiltroStatus.values;

  int _filtroIndex = 0;
  final _dataController = TextEditingController();
  DateTime? _dataFiltro;

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _definirData(DateTime data) {
    String two(int n) => n.toString().padLeft(2, '0');
    setState(() {
      _dataFiltro = data;
      _dataController.text = '${two(data.day)}/${two(data.month)}/${data.year}';
    });
  }

  void _limparData() {
    setState(() {
      _dataFiltro = null;
      _dataController.clear();
    });
  }

  List<OrdemServico> _filtrar(List<OrdemServico> ordens, String fazenda) {
    final filtro = _filtros[_filtroIndex];
    final data = _dataFiltro;
    final filtradas =
        ordens
            .where((o) => o.fazenda == fazenda)
            .where(filtro.aplica)
            .where((o) => data == null || _mesmoDia(o.prazo, data))
            .toList()
          ..sort((a, b) => a.prazo.compareTo(b.prazo));
    return filtradas;
  }

  @override
  Widget build(BuildContext context) {
    final ordens = ref.watch(ordemServicoStoreProvider.select((s) => s.ordens));
    final agora = ref.watch(osRelogioProvider)();
    final fazenda = ref.watch(
      fazendasStoreProvider.select((s) => s.activeFarm.name),
    );
    final filtradas = _filtrar(ordens, fazenda);
    final temFiltroData = _dataFiltro != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
          label: 'Data do prazo',
          // "Hoje" ao lado do campo, não numa linha própria abaixo: é o
          // atalho mais usado do filtro, e ficar colado à seleção de data
          // deixa claro o que ele preenche.
          child: Row(
            children: [
              Expanded(
                child: AppDateInput(
                  controller: _dataController,
                  // Data incompleta ou impossível (31/02) não filtra: antes o
                  // 31/02 virava março em silêncio.
                  onChanged: (formatted) =>
                      setState(() => _dataFiltro = osLerData(formatted)),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              AppButton(
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.sm,
                onPressed: () => _definirData(DateTime.now()),
                child: const Text('Hoje'),
              ),
            ],
          ),
        ),
        if (temFiltroData) ...[
          const SizedBox(height: AppSpacing.space2),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              variant: AppButtonVariant.link,
              size: AppButtonSize.sm,
              onPressed: _limparData,
              child: const Text('Todas as datas'),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space4),
        // Mesmo padrão da lista "Minhas OS" do Operacional: contagem à
        // esquerda, filtro discreto à direita — o status escolhido abre
        // numa folha, sem um trilho de abas ocupando uma faixa inteira.
        Row(
          children: [
            Expanded(
              child: Text(
                filtradas.length == 1
                    ? '1 ordem de serviço'
                    : '${filtradas.length} ordens de serviço',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            AppInlineSelect(
              sheetTitle: 'Status da OS',
              semanticLabel: 'Status da OS',
              value: _filtros[_filtroIndex].name,
              options: [
                for (final f in _filtros)
                  AppFormSelectOption(value: f.name, label: f.label),
              ],
              onChanged: (v) => setState(
                () => _filtroIndex = _filtros.indexWhere((f) => f.name == v),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        if (filtradas.isEmpty)
          AppEmptyState(
            icon: AppIcons.fileText,
            badgeIcon: AppIcons.filter,
            tone: AppEmptyStateTone.brand,
            title: 'Nenhuma OS encontrada',
            description: temFiltroData
                ? 'Nenhuma OS da $fazenda com prazo em ${_dataController.text} '
                      'nesse status. Toque em "Todas as datas" para ampliar.'
                : 'Nenhuma OS da $fazenda nesse status. Troque o filtro acima '
                      'ou a fazenda no topo da tela.',
          )
        else
          for (final os in filtradas) ...[
            OsSummaryCard(
              os: os,
              agora: agora,
              onTap: () => abrirDetalheOs(context, os.id),
            ),
            const SizedBox(height: AppSpacing.space3),
          ],
      ],
    );
  }
}
