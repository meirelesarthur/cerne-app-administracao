import 'package:flutter/material.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import 'models.dart';

/// Peças visuais compartilhadas por `MinhasOsScreen` (Operacional) e
/// `DashOrdemServico` (Administrativo) — Lei 2 do CLAUDE.md: as duas telas
/// mostram a mesma OS com a mesma fidelidade, só a lista de ações muda por
/// perfil.

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

String _fmtDataHora(DateTime d) =>
    '${_fmtData(d)} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Card resumido da OS para as listas (Operacional/Administrativo).
class OsSummaryCard extends StatelessWidget {
  const OsSummaryCard({super.key, required this.os, required this.onTap});

  final OrdemServico os;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      interactive: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${os.codigo} · ${os.titulo}',
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              AppChip(tone: osStatusTone(os.status), child: Text(os.status.label)),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '${os.tipo.label} · ${os.fazenda} · ${os.areaOuTalhao}',
            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
          ),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              AppChip(
                tone: osPrioridadeTone(os.prioridade),
                child: Text('Prioridade ${os.prioridade.label}'),
              ),
              AppChip(child: Text('Prazo ${_fmtData(os.prazo)}')),
              if (os.avaliacao != null)
                AppChip(
                  tone: AppChipTone.brand,
                  icon: const AppIcon(AppIcons.check, size: AppSize.iconXs),
                  child: Text('Avaliada — nota ${os.avaliacao!.nota}'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Corpo completo da OS (aberto num bottom sheet) — todos os campos vindos da
/// solicitação/autorização, alocação de recursos, execução e histórico.
/// `actions` é a lista de botões específica de cada perfil.
class OsDetailBody extends StatelessWidget {
  const OsDetailBody({super.key, required this.os, this.actions = const []});

  final OrdemServico os;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.xs,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          child,
        ],
      ),
    );

    Widget kv(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
            ),
          ),
        ],
      ),
    );

    Widget bulletList(List<String> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space1),
            child: Text(
              '· $item',
              style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${os.codigo} · ${os.titulo}',
                style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
            ),
            AppChip(tone: osStatusTone(os.status), child: Text(os.status.label)),
          ],
        ),
        const SizedBox(height: AppSpacing.space1),
        Text(
          os.descricao,
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        ),
        section(
          'Solicitação e autorização',
          Container(
            padding: const EdgeInsets.all(AppSpacing.space3),
            decoration: BoxDecoration(
              color: semantic.bgSubtle,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kv('Tipo de serviço', os.tipo.label),
                kv('Fazenda', os.fazenda),
                kv('Área / talhão', os.areaOuTalhao),
                kv('Solicitante', os.solicitante),
                kv('Data da solicitação', _fmtDataHora(os.dataSolicitacao)),
                kv('Autorizador', os.autorizador),
                kv('Data da autorização', _fmtDataHora(os.dataAutorizacao)),
                kv('Prioridade', os.prioridade.label),
                kv('Prazo', _fmtData(os.prazo)),
                kv('Responsável', os.responsavelExecucao),
              ],
            ),
          ),
        ),
        section('Instruções de segurança', Text(
          os.instrucoesSeguranca,
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
        )),
        section('Mão de obra alocada', bulletList(os.maoDeObra)),
        section('Máquinas alocadas', bulletList(os.maquinas)),
        section('Insumos alocados', bulletList(os.insumos)),
        section('EPIs obrigatórios', bulletList(os.epis)),
        if (os.evidencias.isNotEmpty)
          section(
            'Evidências da execução',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final ev in os.evidencias)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcon(AppIcons.camera, size: AppSize.iconXs, color: semantic.fgMuted),
                        const SizedBox(width: AppSpacing.space2),
                        Expanded(
                          child: Text(
                            '${ev.legenda} — ${_fmtDataHora(ev.dataHora)}',
                            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (os.motivoPausa != null)
          section('Motivo da pausa', Text(
            os.motivoPausa!,
            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
          )),
        if (os.justificativaRefazer != null)
          section('Justificativa do retrabalho', Text(
            os.justificativaRefazer!,
            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
          )),
        if (os.motivoCancelamento != null)
          section('Motivo do cancelamento', Text(
            os.motivoCancelamento!,
            style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
          )),
        if (os.avaliacao != null)
          section(
            'Avaliação do administrativo',
            Container(
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nota ${os.avaliacao!.nota}/5 · ${os.avaliacao!.avaliador}',
                    style: TextStyle(
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    os.avaliacao!.comentario,
                    style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    _fmtDataHora(os.avaliacao!.dataHora),
                    style: TextStyle(fontSize: AppTypography.xs, color: semantic.fgMuted),
                  ),
                ],
              ),
            ),
          ),
        section(
          'Histórico',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final evento in os.historico)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${evento.acao} — ${evento.autor}',
                        style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgDefault),
                      ),
                      Text(
                        _fmtDataHora(evento.dataHora),
                        style: TextStyle(fontSize: AppTypography.xs, color: semantic.fgMuted),
                      ),
                      if (evento.observacao != null)
                        Text(
                          evento.observacao!,
                          style: TextStyle(fontSize: AppTypography.xs, color: semantic.fgMuted),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space5),
          Wrap(spacing: AppSpacing.space2, runSpacing: AppSpacing.space2, children: actions),
        ],
      ],
    );
  }
}
