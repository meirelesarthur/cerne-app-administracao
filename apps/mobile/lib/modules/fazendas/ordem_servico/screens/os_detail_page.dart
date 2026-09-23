import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design/generated/app_spacing.dart';
import '../../../../ui/ui.dart';
import '../models.dart';
import '../state/ordem_servico_store.dart';
import '../widgets.dart';

/// Placeholder de identidade da sessão administrativa — não há RBAC/login
/// real no protótipo (CLAUDE.md, "Limites do protótipo"), só o rótulo que
/// aparece no histórico da OS quando o Administrativo cria, avalia ou
/// cancela.
const autorAdministrativoOs = 'Administrativo';

/// Abre o detalhe da OS em **tela cheia** (mesmo padrão do app Operação: a
/// folha inferior fica só para escolhas e entradas curtas). Empilhado no
/// navigator raiz, cobre a navbar; o "Voltar" devolve à lista de origem.
void abrirDetalheOs(BuildContext context, String osId) {
  Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(builder: (_) => OsDetailPage(osId: osId)),
  );
}

/// Tela cheia do detalhe da OS (Administrativo). Observa o store: avaliar ou
/// cancelar atualiza o conteúdo e o rodapé no lugar, sem fechar a tela.
///
/// As ações ficam no rodapé fixo (`AppActionBar`) e só existem enquanto a OS
/// está em andamento — regra do modelo: a Administração nunca avalia nem
/// cancela uma OS já encerrada pelo Operacional.
class OsDetailPage extends ConsumerWidget {
  const OsDetailPage({super.key, required this.osId});

  final String osId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ordemServicoStoreProvider.select((s) => s.ordens));
    final os = ref.read(ordemServicoStoreProvider.notifier).byId(osId);

    return AppPageScaffold(
      title: 'Detalhe da OS',
      onBack: () => Navigator.of(context).maybePop(),
      actionBar: os.status.emAndamento
          ? AppActionBar(
              primaryLabel: 'Avaliar',
              onPrimary: () => abrirAvaliarOs(context, ref, os.id),
              secondaryLabel: 'Cancelar OS',
              onSecondary: () => abrirCancelarOs(context, ref, os.id),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space6),
        child: OsDetailBody(os: os),
      ),
    );
  }
}

const _registroHistorico =
    'Fica registrado no histórico da OS com data, hora e o seu nome.';

void abrirAvaliarOs(BuildContext context, WidgetRef ref, String osId) {
  final notifier = ref.read(ordemServicoStoreProvider.notifier);
  final comentarioController = TextEditingController();
  var nota = '5';

  showAppBottomSheet<void>(
    context,
    title: 'Avaliar a ${notifier.byId(osId).codigo}',
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
                  AppFormSelectOption(
                    value: '2',
                    label: '2 — Abaixo do esperado',
                  ),
                  AppFormSelectOption(
                    value: '3',
                    label: '3 — Dentro do esperado',
                  ),
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
              hint: _registroHistorico,
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
                  avaliador: autorAdministrativoOs,
                  nota: int.parse(nota),
                  comentario: comentario,
                );
                // Fecha só a folha: o detalhe em tela cheia continua aberto
                // e mostra a avaliação registrada.
                Navigator.of(context).pop();
              },
              child: const Text('Registrar avaliação'),
            ),
          ],
        );
      },
    ),
  );
}

void abrirCancelarOs(BuildContext context, WidgetRef ref, String osId) {
  final notifier = ref.read(ordemServicoStoreProvider.notifier);
  final controller = TextEditingController();

  showAppBottomSheet<void>(
    context,
    title: 'Cancelar a ${notifier.byId(osId).codigo}?',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          label: 'Motivo do cancelamento',
          required: true,
          hint:
              'Encerra a OS e não dá para desfazer pelo aplicativo. '
              '$_registroHistorico',
          child: AppTextarea(
            controller: controller,
            placeholder: 'Explique por que a OS está sendo cancelada...',
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          fullWidth: true,
          variant: AppButtonVariant.danger,
          onPressed: () {
            final motivo = controller.text.trim();
            if (motivo.isEmpty) return;
            notifier.cancelar(
              osId,
              autor: autorAdministrativoOs,
              motivo: motivo,
            );
            // Fecha só a folha: o detalhe mostra o novo status, sem rodapé.
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar cancelamento'),
        ),
      ],
    ),
  );
}
