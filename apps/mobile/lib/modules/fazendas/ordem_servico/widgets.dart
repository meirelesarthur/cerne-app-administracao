import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import 'models.dart';

/// Peças visuais da OS compartilhadas pelo painel de OS (aba "OS" e
/// `DashOrdemServico`) e pelo detalhe em tela cheia — Lei 2 do CLAUDE.md:
/// todas mostram a mesma OS com a mesma fidelidade. O desenho acompanha o do
/// app Operação (`cerne-app-operacao`), que lê a mesma OS em campo; aqui
/// entram só as leituras e ações do perfil Administração (avaliação e
/// cancelamento).

AppChipTone osStatusTone(OrdemServicoStatus status) => switch (status) {
  OrdemServicoStatus.aguardando => AppChipTone.neutral,
  OrdemServicoStatus.emExecucao => AppChipTone.blue,
  OrdemServicoStatus.pausada => AppChipTone.amber,
  OrdemServicoStatus.entregue => AppChipTone.brand,
  OrdemServicoStatus.refeita => AppChipTone.red,
  OrdemServicoStatus.cancelada => AppChipTone.red,
};

AppChipTone osPrioridadeTone(PrioridadeOs prioridade) => switch (prioridade) {
  PrioridadeOs.baixa => AppChipTone.neutral,
  PrioridadeOs.media => AppChipTone.blue,
  PrioridadeOs.alta => AppChipTone.amber,
  PrioridadeOs.urgente => AppChipTone.red,
};

String _fmtData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _fmtDataCurta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String _fmtDataHora(DateTime d) =>
    '${_fmtData(d)} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Duração legível para a linha de situação: "40 min", "2h15", "3 dias".
String osDuracao(Duration d) {
  if (d.isNegative) return '0 min';
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  if (d.inHours < 24) {
    final min = d.inMinutes % 60;
    return min == 0
        ? '${d.inHours}h'
        : '${d.inHours}h${min.toString().padLeft(2, '0')}';
  }
  final dias = d.inDays;
  return dias == 1 ? '1 dia' : '$dias dias';
}

String _dias(int n) => n == 1 ? '1 dia' : '$n dias';

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

/// A situação mais importante da OS *agora*, para a linha de rodapé do card.
/// Uma só, por precedência (ver docs do mapeamento de situações):
///
/// 1. Cancelada · motivo — decisão da Administração, encerra a OS.
/// 2. Refeita · justificativa.
/// 3. Entregue em dd/mm — no prazo ou com N dias de atraso.
/// 4. Atrasada há N dias — em andamento com o prazo vencido.
/// 5. Pausada há X · motivo.
/// 6. Vence hoje / Vence amanhã.
/// 7. Em execução há X.
/// 8. Liberada há X — aguardando início desde a autorização.
AppStatusCardSituation osSituacao(OrdemServico os, DateTime agora) {
  final hoje = _dia(agora);
  final prazo = _dia(os.prazo);
  final diasParaPrazo = prazo.difference(hoje).inDays;

  switch (os.status) {
    case OrdemServicoStatus.cancelada:
      return AppStatusCardSituation(
        icon: AppIcons.alertCircle,
        label: os.motivoCancelamento == null
            ? 'Cancelada'
            : 'Cancelada · ${os.motivoCancelamento}',
        tone: AppStatusCardTone.danger,
      );
    case OrdemServicoStatus.refeita:
      return AppStatusCardSituation(
        icon: AppIcons.alertCircle,
        label: os.justificativaRefazer == null
            ? 'Precisa ser refeita'
            : 'Refeita · ${os.justificativaRefazer}',
        tone: AppStatusCardTone.danger,
      );
    case OrdemServicoStatus.entregue:
      final entrega = os.dataEntrega;
      if (entrega == null) {
        return const AppStatusCardSituation(
          icon: AppIcons.checkCircle2,
          label: 'Entregue',
          tone: AppStatusCardTone.success,
        );
      }
      final atraso = _dia(entrega).difference(prazo).inDays;
      return atraso > 0
          ? AppStatusCardSituation(
              icon: AppIcons.alertTriangle,
              label:
                  'Entregue em ${_fmtData(entrega)} · ${_dias(atraso)} de atraso',
              tone: AppStatusCardTone.danger,
            )
          : AppStatusCardSituation(
              icon: AppIcons.checkCircle2,
              label: 'Entregue em ${_fmtData(entrega)} · no prazo',
              tone: AppStatusCardTone.success,
            );
    case OrdemServicoStatus.aguardando:
    case OrdemServicoStatus.emExecucao:
    case OrdemServicoStatus.pausada:
      break;
  }

  if (diasParaPrazo < 0) {
    return AppStatusCardSituation(
      icon: AppIcons.alertTriangle,
      label: 'Atrasada há ${_dias(-diasParaPrazo)}',
      tone: AppStatusCardTone.danger,
    );
  }
  if (os.status == OrdemServicoStatus.pausada) {
    final desde = os.dataPausa;
    final tempo = desde == null
        ? 'Pausada'
        : 'Pausada há ${osDuracao(agora.difference(desde))}';
    return AppStatusCardSituation(
      icon: AppIcons.pause,
      label: os.motivoPausa == null ? tempo : '$tempo · ${os.motivoPausa}',
      tone: AppStatusCardTone.warning,
    );
  }
  if (diasParaPrazo <= 1) {
    return AppStatusCardSituation(
      icon: AppIcons.calendar,
      label: diasParaPrazo == 0 ? 'Vence hoje' : 'Vence amanhã',
      tone: AppStatusCardTone.warning,
    );
  }
  if (os.status == OrdemServicoStatus.emExecucao) {
    final desde = os.dataInicio;
    return AppStatusCardSituation(
      icon: AppIcons.clock,
      label: desde == null
          ? 'Em execução'
          : 'Em execução há ${osDuracao(agora.difference(desde))}',
      tone: AppStatusCardTone.info,
    );
  }
  return AppStatusCardSituation(
    icon: AppIcons.clock,
    label: 'Liberada há ${osDuracao(agora.difference(os.dataAutorizacao))}',
  );
}

/// Card resumido da OS: o `AppStatusCard` do catálogo na variante
/// [AppStatusCardVariant.featured], a mesma da lista do app Operação — o nome
/// da tarefa é o que se lê primeiro (é o que diz o que fazer); local abaixo,
/// "responsável · OS #N" na linha de apoio para conferir o número, status,
/// prazo e prioridade com ícone à direita e a situação do momento
/// ([osSituacao]) em faixa tingida. Sem ação rápida: iniciar, pausar e
/// retomar são do Operacional; a Administração age no detalhe (avaliar,
/// cancelar).
class OsSummaryCard extends StatelessWidget {
  const OsSummaryCard({
    super.key,
    required this.os,
    required this.agora,
    required this.onTap,
  });

  final OrdemServico os;

  /// "Agora" de referência da situação — vem do `osRelogioProvider`.
  final DateTime agora;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final urgente =
        os.prioridade == PrioridadeOs.alta ||
        os.prioridade == PrioridadeOs.urgente;
    return AppStatusCard(
      variant: AppStatusCardVariant.featured,
      statusLabel: os.status.label,
      statusTone: osStatusTone(os.status),
      title: os.titulo,
      subtitle: os.areaOuTalhao,
      caption: '${os.responsavelExecucao} · ${os.codigo}',
      meta: [
        AppStatusCardMeta(
          label: 'Prazo',
          value: _fmtDataCurta(os.prazo),
          icon: AppIcons.calendar,
        ),
        AppStatusCardMeta(
          label: 'Prioridade',
          value: os.prioridade.label,
          highlight: urgente,
          icon: AppIcons.alertCircle,
        ),
      ],
      situation: osSituacao(os, agora),
      onTap: onTap,
    );
  }
}

/// Corpo completo da OS (detalhe em tela cheia) — todos os campos vindos da
/// solicitação/autorização, alocação de recursos, execução, avaliação e
/// histórico. `actions` é uma lista opcional de botões ao fim do conteúdo; o
/// detalhe em tela cheia usa o rodapé fixo do `AppPageScaffold`.
///
/// Hierarquia (a mesma do app Operação): número e título grande no topo,
/// status e prioridade em chips logo abaixo do título, e cada grupo de dados
/// numa [AppDetailSection] com ícone próprio e bloco cinza — o olho acha o grupo
/// pelo ícone antes de ler. Instruções de segurança vêm em tom de atenção
/// logo depois dos dados do serviço.
///
/// O histórico mora numa aba própria ("Histórico"), abaixo do cabeçalho: é
/// consulta eventual e, na mesma rolagem, empurrava os dados do serviço e
/// alongava demais a tela.
class OsDetailBody extends StatefulWidget {
  const OsDetailBody({super.key, required this.os, this.actions = const []});

  final OrdemServico os;
  final List<Widget> actions;

  @override
  State<OsDetailBody> createState() => _OsDetailBodyState();
}

class _OsDetailBodyState extends State<OsDetailBody> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final os = widget.os;
    final actions = widget.actions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          os.codigo,
          style: TextStyle(
            fontSize: AppTypography.md,
            fontWeight: AppTypography.weightSemibold,
            color: semantic.fgMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.half),
        Semantics(
          header: true,
          child: Text(
            os.titulo,
            style: TextStyle(
              fontSize: AppTypography.xlPlus2,
              fontWeight: AppTypography.weightSemibold,
              height: AppTypography.lineHeightTight,
              color: semantic.fgHeading,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            AppChip(
              tone: osStatusTone(os.status),
              child: Text(os.status.label),
            ),
            AppChip(
              tone: osPrioridadeTone(os.prioridade),
              child: Text('Prioridade ${os.prioridade.label.toLowerCase()}'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Text(
          os.descricao,
          style: TextStyle(
            fontSize: AppTypography.lg,
            height: AppTypography.lineHeightNormal,
            color: semantic.fgSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppSegmentedTabs(
          labels: ['Detalhes', 'Histórico (${os.historico.length})'],
          selectedIndex: _aba,
          onChanged: (i) => setState(() => _aba = i),
        ),
        if (_aba == 1 && os.historico.isEmpty) ...[
          const SizedBox(height: AppSpacing.space5),
          const AppEmptyState(
            size: AppEmptyStateSize.compact,
            icon: AppIcons.clock,
            title: 'Sem histórico ainda',
            description:
                'Início, pausas, retomadas e a entrega da OS ficam registrados '
                'aqui.',
          ),
        ] else if (_aba == 1) ...[
          const SizedBox(height: AppSpacing.space5),
          AppDetailSection(
            icon: AppIcons.clock,
            title: 'Histórico',
            count: os.historico.length,
            child: AppDetailFields(
              fields: [
                for (final evento in os.historico.reversed)
                  AppDetailField(
                    label: _fmtDataHora(evento.dataHora),
                    value: evento.acao,
                    caption: evento.observacao == null
                        ? evento.autor
                        : '${evento.autor} · ${evento.observacao}',
                  ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.space5),
          AppDetailSection(
            icon: AppIcons.ordemServico,
            title: 'Serviço',
            child: AppDetailFields(
              columns: 2,
              fields: [
                AppDetailField(label: 'Prazo', value: _fmtData(os.prazo)),
                AppDetailField(label: 'Prioridade', value: os.prioridade.label),
                AppDetailField(label: 'Fazenda', value: os.fazenda),
                AppDetailField(label: 'Área / talhão', value: os.areaOuTalhao),
                AppDetailField(label: 'Tipo de serviço', value: os.tipo.label),
              ],
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.shieldAlert,
            title: 'Instruções de segurança',
            tone: AppDetailSectionTone.warning,
            child: AppDetailText(os.instrucoesSeguranca),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.fileSignature,
            title: 'Solicitação e autorização',
            child: AppDetailFields(
              fields: [
                AppDetailField(
                  label: 'Solicitado por',
                  value: os.solicitante,
                  caption: _fmtDataHora(os.dataSolicitacao),
                ),
                AppDetailField(
                  label: 'Autorizado por',
                  value: os.autorizador,
                  caption: _fmtDataHora(os.dataAutorizacao),
                ),
                AppDetailField(
                  label: 'Responsável pela execução',
                  value: os.responsavelExecucao,
                ),
              ],
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.users,
            title: 'Mão de obra',
            count: os.maoDeObra.length,
            child: AppDetailList(items: os.maoDeObra),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.tractor,
            title: 'Máquinas',
            count: os.maquinas.length,
            child: AppDetailList(items: os.maquinas),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.flaskConical,
            title: 'Insumos',
            count: os.insumos.length,
            child: AppDetailList(items: os.insumos),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.shieldCheck,
            title: 'EPIs obrigatórios',
            count: os.epis.length,
            child: AppDetailList(items: os.epis),
          ),
          if (os.evidencias.isNotEmpty) ...[
            _gap,
            AppDetailSection(
              icon: AppIcons.camera,
              title: 'Evidências da execução',
              count: os.evidencias.length,
              child: AppDetailFields(
                fields: [
                  for (final ev in os.evidencias)
                    AppDetailField(
                      label: 'Foto',
                      value: ev.legenda,
                      caption: _fmtDataHora(ev.dataHora),
                    ),
                ],
              ),
            ),
          ],
          if (os.motivoPausa != null) ...[
            _gap,
            AppDetailSection(
              icon: AppIcons.pause,
              title: 'Motivo da pausa',
              tone: AppDetailSectionTone.warning,
              child: AppDetailText(os.motivoPausa!),
            ),
          ],
          if (os.justificativaRefazer != null) ...[
            _gap,
            AppDetailSection(
              icon: AppIcons.rotateCw,
              title: 'Justificativa do retrabalho',
              tone: AppDetailSectionTone.danger,
              child: AppDetailText(os.justificativaRefazer!),
            ),
          ],
          if (os.motivoCancelamento != null) ...[
            _gap,
            AppDetailSection(
              icon: AppIcons.alertCircle,
              title: 'Motivo do cancelamento',
              tone: AppDetailSectionTone.danger,
              child: AppDetailText(os.motivoCancelamento!),
            ),
          ],
          if (os.avaliacao case final avaliacao?) ...[
            _gap,
            AppDetailSection(
              icon: AppIcons.clipboardCheck,
              title: 'Avaliação do administrativo',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDetailFields(
                    fields: [
                      AppDetailField(
                        label: 'Nota',
                        value: '${avaliacao.nota}/5',
                        caption:
                            '${avaliacao.avaliador} · '
                            '${_fmtDataHora(avaliacao.dataHora)}',
                      ),
                    ],
                  ),
                  Divider(height: 1, color: semantic.borderDefault),
                  AppDetailText(avaliacao.comentario),
                ],
              ),
            ),
          ],
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space5),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: actions,
          ),
        ],
      ],
    );
  }
}

const _gap = SizedBox(height: AppSpacing.space6);
