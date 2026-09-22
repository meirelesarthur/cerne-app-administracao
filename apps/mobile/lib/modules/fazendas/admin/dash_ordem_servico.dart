import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../ordem_servico/models.dart';
import '../ordem_servico/state/ordem_servico_store.dart';
import '../ordem_servico/widgets.dart';
import 'dashboard_screen.dart';

/// Placeholder de identidade do sessão administrativa — não há RBAC/login
/// real no protótipo (CLAUDE.md, "Limites do protótipo"), só o rótulo que
/// aparece no histórico da OS quando o Administrativo avalia ou cancela.
const _autorAdm = 'Administrativo';

/// Consulta de Ordem de Serviço (Administrativo) — só leitura, com as duas
/// ações que o perfil pode tomar enquanto a OS ainda está em andamento:
/// avaliar (checkpoint de qualidade) ou cancelar. Nunca incide sobre OS já
/// entregue/refeita pelo Operacional (regra de negócio confirmada com o
/// usuário) — mesma fonte de dados de `operacional/minhas_os_screen.dart`
/// (Lei 2: uma única OS, dois perfis de leitura/ação).
class DashOrdemServico extends ConsumerStatefulWidget {
  const DashOrdemServico({super.key});

  @override
  ConsumerState<DashOrdemServico> createState() => _DashOrdemServicoState();
}

class _DashOrdemServicoState extends ConsumerState<DashOrdemServico> {
  int _tab = 0;

  static const _labels = ['Aguardando', 'Em execução', 'Finalizadas'];

  List<OrdemServico> _filtrar(List<OrdemServico> ordens) {
    return switch (_tab) {
      0 => ordens.where((o) => o.status == OrdemServicoStatus.aguardando).toList(),
      1 => ordens
          .where((o) =>
              o.status == OrdemServicoStatus.emExecucao || o.status == OrdemServicoStatus.pausada)
          .toList(),
      _ => ordens.where((o) => o.status.encerrada).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ordens = ref.watch(ordemServicoStoreProvider.select((s) => s.ordens));
    final filtradas = _filtrar(ordens);

    return DashboardScreen(
      title: 'Ordem de Serviço',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSegmentedTabs(
            labels: _labels,
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.space4),
          if (filtradas.isEmpty)
            const AppEmptyState(
              icon: AppIcons.fileText,
              title: 'Nenhuma OS nesta aba',
              description: 'Ordens de serviço registradas nesta sessão aparecem aqui.',
            )
          else
            for (final os in filtradas) ...[
              OsSummaryCard(os: os, onTap: () => _abrirDetalhe(context, os)),
              const SizedBox(height: AppSpacing.space3),
            ],
        ],
      ),
    );
  }

  void _abrirDetalhe(BuildContext context, OrdemServico os) {
    final notifier = ref.read(ordemServicoStoreProvider.notifier);

    showAppBottomSheet<void>(
      context,
      title: 'Detalhe da OS',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final atual = notifier.byId(os.id);
          final actions = <Widget>[];

          if (atual.status.emAndamento) {
            actions.add(
              AppButton(
                variant: AppButtonVariant.secondary,
                onPressed: () => _abrirAvaliar(context, atual.id),
                child: const Text('Avaliar'),
              ),
            );
            actions.add(
              AppButton(
                variant: AppButtonVariant.dangerOutline,
                onPressed: () => _abrirCancelar(context, atual.id),
                child: const Text('Cancelar OS'),
              ),
            );
          }

          return OsDetailBody(os: atual, actions: actions);
        },
      ),
    );
  }

  void _abrirAvaliar(BuildContext context, String osId) {
    final notifier = ref.read(ordemServicoStoreProvider.notifier);
    final comentarioController = TextEditingController();
    var nota = '5';

    showAppBottomSheet<void>(
      context,
      title: 'Avaliar OS',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormField(
                label: 'Nota',
                required: true,
                child: AppFormSelect(
                  options: const [
                    AppFormSelectOption(value: '1', label: '1 — Insatisfatório'),
                    AppFormSelectOption(value: '2', label: '2 — Abaixo do esperado'),
                    AppFormSelectOption(value: '3', label: '3 — Dentro do esperado'),
                    AppFormSelectOption(value: '4', label: '4 — Bom'),
                    AppFormSelectOption(value: '5', label: '5 — Excelente'),
                  ],
                  value: nota,
                  onChanged: (v) => setSheetState(() => nota = v ?? nota),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Comentário',
                required: true,
                child: AppTextarea(
                  controller: comentarioController,
                  placeholder: 'Observações sobre o andamento do serviço...',
                ),
              ),
              const SizedBox(height: AppSpacing.space5),
              AppButton(
                fullWidth: true,
                onPressed: () {
                  final comentario = comentarioController.text.trim();
                  if (comentario.isEmpty) return;
                  notifier.avaliar(
                    osId,
                    avaliador: _autorAdm,
                    nota: int.parse(nota),
                    comentario: comentario,
                  );
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
                child: const Text('Registrar avaliação'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _abrirCancelar(BuildContext context, String osId) {
    final notifier = ref.read(ordemServicoStoreProvider.notifier);
    final controller = TextEditingController();

    showAppBottomSheet<void>(
      context,
      title: 'Cancelar OS',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'Motivo do cancelamento',
            required: true,
            child: AppTextarea(controller: controller, placeholder: 'Explique por que a OS está sendo cancelada...'),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.danger,
            onPressed: () {
              final motivo = controller.text.trim();
              if (motivo.isEmpty) return;
              notifier.cancelar(osId, autor: _autorAdm, motivo: motivo);
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            child: const Text('Confirmar cancelamento'),
          ),
        ],
      ),
    );
  }
}
