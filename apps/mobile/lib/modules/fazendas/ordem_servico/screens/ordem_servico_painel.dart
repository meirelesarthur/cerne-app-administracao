import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design/generated/app_layout.dart';
import '../../../../design/generated/app_spacing.dart';
import '../../../../ui/ui.dart';
import '../../state/fazendas_store.dart';
import '../models.dart';
import '../state/ordem_servico_store.dart';
import '../widgets.dart';
import 'os_detail_page.dart';

/// Painel de Ordens de Serviço (Administrativo): lista as OS da fazenda
/// ativa, filtráveis por status e por data de prazo. Criar fica aqui; avaliar
/// e cancelar ficam no detalhe em tela cheia ([OsDetailPage]). Mesma OS e
/// mesmo desenho que o app Operação lê em campo (Lei 2: uma única OS, dois
/// perfis de leitura/ação).
///
/// Conteúdo puro (sem scaffold/scroll próprio) para caber tanto na aba "OS"
/// (`OrdemServicoTabScreen`, raiz de aba) quanto no dashboard acessível pela
/// busca global e pelo catálogo (`DashOrdemServico`, dentro de um
/// `DashboardScreen` com voltar) — Lei 2: uma única implementação da lista.
class OrdemServicoPainel extends ConsumerStatefulWidget {
  const OrdemServicoPainel({super.key});

  @override
  ConsumerState<OrdemServicoPainel> createState() => _OrdemServicoPainelState();
}

enum _FiltroStatus { todas, aguardando, emExecucao, pausada, encerradas }

extension on _FiltroStatus {
  String get label => switch (this) {
    _FiltroStatus.todas => 'Todas',
    _FiltroStatus.aguardando => 'Aguardando',
    _FiltroStatus.emExecucao => 'Em execução',
    _FiltroStatus.pausada => 'Pausada',
    _FiltroStatus.encerradas => 'Encerradas',
  };

  bool aplica(OrdemServico os) => switch (this) {
    _FiltroStatus.todas => true,
    _FiltroStatus.aguardando => os.status == OrdemServicoStatus.aguardando,
    _FiltroStatus.emExecucao => os.status == OrdemServicoStatus.emExecucao,
    _FiltroStatus.pausada => os.status == OrdemServicoStatus.pausada,
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

  List<OrdemServico> _filtrar(List<OrdemServico> ordens) {
    final filtro = _filtros[_filtroIndex];
    final data = _dataFiltro;
    final filtradas =
        ordens
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
    final filtradas = _filtrar(ordens);
    final temFiltroData = _dataFiltro != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          fullWidth: true,
          leftIcon: const AppIcon(AppIcons.plus, size: AppSize.iconXs),
          onPressed: () => _abrirCriar(context),
          child: const Text('Criar OS'),
        ),
        const SizedBox(height: AppSpacing.space4),
        AppFormField(
          label: 'Data do prazo',
          child: AppDateInput(
            controller: _dataController,
            onChanged: (formatted) {
              final match = RegExp(
                r'^(\d{2})/(\d{2})/(\d{4})$',
              ).firstMatch(formatted);
              if (match == null) return;
              final dia = int.parse(match.group(1)!);
              final mes = int.parse(match.group(2)!);
              final ano = int.parse(match.group(3)!);
              setState(() => _dataFiltro = DateTime(ano, mes, dia));
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Row(
          children: [
            AppButton(
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.sm,
              onPressed: () => _definirData(DateTime.now()),
              child: const Text('Hoje'),
            ),
            if (temFiltroData) ...[
              const SizedBox(width: AppSpacing.space2),
              AppButton(
                variant: AppButtonVariant.link,
                size: AppButtonSize.sm,
                onPressed: _limparData,
                child: const Text('Todas as datas'),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        AppSegmentedTabs(
          scrollable: true,
          labels: [for (final f in _filtros) f.label],
          selectedIndex: _filtroIndex,
          onChanged: (i) => setState(() => _filtroIndex = i),
        ),
        const SizedBox(height: AppSpacing.space4),
        if (filtradas.isEmpty)
          AppEmptyState(
            icon: AppIcons.fileText,
            title: 'Nenhuma OS encontrada',
            description: temFiltroData
                ? 'Nenhuma ordem de serviço com prazo em ${_dataController.text} nesse status.'
                : 'Ordens de serviço registradas nesta sessão aparecem aqui.',
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

  void _abrirCriar(BuildContext context) {
    final notifier = ref.read(ordemServicoStoreProvider.notifier);
    final fazenda = ref.read(fazendasStoreProvider).activeFarm.name;
    final tituloController = TextEditingController();
    final areaController = TextEditingController();
    final descricaoController = TextEditingController();
    final prazoController = TextEditingController();
    var tipo = TipoServicoOs.agricola.name;
    var prioridade = PrioridadeOs.media.name;
    DateTime? prazo;

    showAppBottomSheet<void>(
      context,
      title: 'Criar OS',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormField(
                label: 'Título',
                required: true,
                child: AppTextInput(
                  controller: tituloController,
                  placeholder: 'Ex.: Reparo de cerca do Talhão 04',
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Tipo de serviço',
                required: true,
                child: AppFormSelect(
                  options: [
                    for (final t in TipoServicoOs.values)
                      AppFormSelectOption(value: t.name, label: t.label),
                  ],
                  value: tipo,
                  onChanged: (v) => setSheetState(() => tipo = v ?? tipo),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Área / talhão',
                required: true,
                child: AppTextInput(
                  controller: areaController,
                  placeholder: 'Ex.: Talhão 04',
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Prioridade',
                required: true,
                child: AppFormSelect(
                  options: [
                    for (final p in PrioridadeOs.values)
                      AppFormSelectOption(value: p.name, label: p.label),
                  ],
                  value: prioridade,
                  onChanged: (v) =>
                      setSheetState(() => prioridade = v ?? prioridade),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Prazo',
                required: true,
                child: AppDateInput(
                  controller: prazoController,
                  onChanged: (formatted) {
                    final match = RegExp(
                      r'^(\d{2})/(\d{2})/(\d{4})$',
                    ).firstMatch(formatted);
                    if (match == null) return;
                    final dia = int.parse(match.group(1)!);
                    final mes = int.parse(match.group(2)!);
                    final ano = int.parse(match.group(3)!);
                    setSheetState(() => prazo = DateTime(ano, mes, dia));
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Descrição',
                required: true,
                child: AppTextarea(
                  controller: descricaoController,
                  placeholder: 'Detalhe o que precisa ser feito...',
                ),
              ),
              const SizedBox(height: AppSpacing.space5),
              AppButton(
                fullWidth: true,
                onPressed: () {
                  final titulo = tituloController.text.trim();
                  final area = areaController.text.trim();
                  final descricao = descricaoController.text.trim();
                  if (titulo.isEmpty ||
                      area.isEmpty ||
                      descricao.isEmpty ||
                      prazo == null) {
                    return;
                  }
                  notifier.criar(
                    titulo: titulo,
                    tipo: TipoServicoOs.values.byName(tipo),
                    fazenda: fazenda,
                    areaOuTalhao: area,
                    prioridade: PrioridadeOs.values.byName(prioridade),
                    prazo: prazo!,
                    descricao: descricao,
                    autor: autorAdministrativoOs,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Criar OS'),
              ),
            ],
          );
        },
      ),
    );
  }
}
