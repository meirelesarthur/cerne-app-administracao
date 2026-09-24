import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import 'models.dart';

/// Peças visuais da OS usadas na consulta administrativa e no detalhe em tela
/// cheia. Os dados seguem o contrato compartilhado com o app Operação.

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

/// Lê a data digitada em `DD/MM/AAAA`, validando também dias impossíveis.
/// Compartilhada com o formulário administrativo simplificado.
DateTime? osLerData(String texto) {
  final match = RegExp(
    r'^([0-9]{2})/([0-9]{2})/([0-9]{4})$',
  ).firstMatch(texto.trim());
  if (match == null) return null;
  final dia = int.parse(match.group(1)!);
  final mes = int.parse(match.group(2)!);
  final ano = int.parse(match.group(3)!);
  final data = DateTime(ano, mes, dia);
  if (data.day != dia || data.month != mes || data.year != ano) return null;
  return data;
}

const _diasSemana = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

/// Prazo lido de relance: "Hoje", "Amanhã", "Ontem" ou "sex, 26/09" — o dia
/// da semana orienta mais que a data solta para quem planeja a semana.
String osPrazoRelativo(DateTime prazo, DateTime agora) {
  final dias = DateTime(
    prazo.year,
    prazo.month,
    prazo.day,
  ).difference(DateTime(agora.year, agora.month, agora.day)).inDays;
  return switch (dias) {
    0 => 'Hoje',
    1 => 'Amanhã',
    -1 => 'Ontem',
    _ => '${_diasSemana[prazo.weekday - 1]}, ${_fmtDataCurta(prazo)}',
  };
}

String _fmtDataHora(DateTime d) =>
    '${_fmtData(d)} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Quantidade sem ",00" quando inteira (12 un., 7,02 L).
String _qtd(num v) {
  if (v % 1 == 0) return v.toStringAsFixed(0);
  return v.toStringAsFixed(2).replaceAll('.', ',').replaceFirst(
    RegExp(r',?0+$'),
    '',
  );
}

/// Dock de leitura de um item da OS: os campos do registro (os mesmos do
/// WEB) e, quando houver, a observação inteira — na lista ela é cortada em
/// duas linhas.
Future<void> _abrirDetalhe(
  BuildContext context, {
  required String title,
  required List<AppDetailField> fields,
  int columns = 1,
  String? observacao,
}) {
  return showAppBottomSheet<void>(
    context,
    title: title,
    footer: AppButton(
      variant: AppButtonVariant.secondary,
      fullWidth: true,
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      child: const Text('Fechar'),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDetailFields(columns: columns, fields: fields),
        if (observacao != null) ...[
          const SizedBox(height: AppSpacing.space3),
          AppDetailSection(
            icon: AppIcons.messageCircle,
            title: 'Observação',
            child: AppDetailText(observacao),
          ),
        ],
      ],
    ),
  );
}

Future<void> _abrirEvento(BuildContext context, EventoOs evento) =>
    _abrirDetalhe(
      context,
      title: evento.acao,
      fields: [
        AppDetailField(
          label: 'Data e hora',
          value: _fmtDataHora(evento.dataHora),
        ),
        AppDetailField(label: 'Registrado por', value: evento.autor),
      ],
      observacao: evento.observacao,
    );

Future<void> _abrirMaoDeObra(BuildContext context, MaoDeObraOs item) =>
    _abrirDetalhe(
      context,
      title: item.executor,
      columns: 2,
      fields: [
        AppDetailField(label: 'Tipo', value: item.tipo.label),
        if (item.funcao case final funcao?)
          AppDetailField(label: 'Função no cadastro', value: funcao),
      ],
    );

Future<void> _abrirMaquina(BuildContext context, MaquinaOs item) =>
    _abrirDetalhe(
      context,
      title: item.equipamento,
      fields: const [
        AppDetailField(label: 'Tipo', value: 'Máq/Equipamento/Veículo'),
      ],
      observacao: item.observacao,
    );

Future<void> _abrirInsumo(
  BuildContext context,
  OrdemServico os,
  InsumoOs item,
) => _abrirDetalhe(
  context,
  title: item.produto,
  columns: 2,
  fields: [
    AppDetailField(label: 'Un. medida', value: item.unidadeMedida),
    AppDetailField(label: 'Estoque', value: _qtd(item.estoque)),
    AppDetailField(label: 'Qtd/ha', value: _qtd(item.quantidadePorHa)),
    AppDetailField(label: 'Qtd total', value: _qtd(item.quantidadeTotal)),
    AppDetailField(label: 'Armazém de insumos', value: os.armazemInsumos),
  ],
);

Future<void> _abrirProducao(
  BuildContext context,
  OrdemServico os,
  ProducaoOs item,
) => _abrirDetalhe(
  context,
  title: item.produto,
  columns: 2,
  fields: [
    AppDetailField(label: 'Un. medida', value: item.unidadeMedida),
    AppDetailField(label: 'Qtde', value: _qtd(item.quantidade)),
    AppDetailField(
      label: 'Armazém de produção',
      value: os.armazemProducao ?? '—',
    ),
  ],
  observacao: item.observacao,
);

Future<void> _abrirEpi(BuildContext context, EpiOs item) => _abrirDetalhe(
  context,
  title: item.produto,
  fields: const [AppDetailField(label: 'Tipo', value: 'Proteção (EPI)')],
  observacao: item.observacao,
);

Future<void> _abrirEvidencia(BuildContext context, EvidenciaOs ev) =>
    _abrirDetalhe(
      context,
      title: ev.legenda,
      fields: [
        const AppDetailField(label: 'Tipo', value: 'Foto'),
        AppDetailField(label: 'Data e hora', value: _fmtDataHora(ev.dataHora)),
        if (ev.autor != null)
          AppDetailField(label: 'Registrado por', value: ev.autor!),
      ],
      observacao: ev.observacao,
    );

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
/// 1. Cancelada · motivo — decisão do escritório, encerra a OS.
/// 2. Refeita · justificativa.
/// 3. Entregue em dd/mm — no prazo ou com N dias de atraso.
/// 4. Atrasada há N dias — em andamento com o prazo vencido.
/// 5. Pausada há X · motivo.
/// 6. Vence hoje / Vence amanhã.
/// 7. Em execução há X.
/// 8. Esperando início há X — aguardando início desde a autorização.
AppStatusCardSituation osSituacao(OrdemServico os, DateTime agora) {
  final hoje = _dia(agora);
  final prazo = _dia(os.prazo);
  final diasParaPrazo = prazo.difference(hoje).inDays;

  switch (os.status) {
    case OrdemServicoStatus.cancelada:
      return AppStatusCardSituation(
        icon: AppIcons.alertCircle,
        label: os.motivoCancelamento == null
            ? 'Cancelada pelo escritório'
            : 'Cancelada · ${os.motivoCancelamento}',
        tone: AppStatusCardTone.danger,
      );
    case OrdemServicoStatus.refeita:
      return AppStatusCardSituation(
        icon: AppIcons.alertCircle,
        label: os.justificativaRefazer == null
            ? 'Precisa refazer'
            : 'Precisa refazer · ${os.justificativaRefazer}',
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
    label:
        'Esperando início há ${osDuracao(agora.difference(os.dataAutorizacao))}',
  );
}

/// Ação rápida do card por status — o próximo passo reversível: iniciar,
/// pausar ou retomar. Entregar e refazer encerram a OS e ficam só no
/// detalhe; OS encerradas não têm botão.
({String label, AppIconData icon, bool primary})? osAcaoRapida(
  OrdemServicoStatus status,
) => switch (status) {
  OrdemServicoStatus.aguardando => (
    label: 'Iniciar',
    icon: AppIcons.play,
    primary: true,
  ),
  OrdemServicoStatus.emExecucao => (
    label: 'Pausar',
    icon: AppIcons.pause,
    primary: false,
  ),
  OrdemServicoStatus.pausada => (
    label: 'Retomar',
    icon: AppIcons.play,
    primary: true,
  ),
  _ => null,
};

/// Card resumido da OS: o `AppStatusCard` do catálogo.
///
/// - [AppStatusCardVariant.standard] (listas, "Minhas OS"): status no topo,
///   código em destaque, título e local abaixo, prazo e prioridade à direita
///   e no rodapé a situação do momento ([osSituacao]) com a ação rápida
///   ([osAcaoRapida]).
/// - [AppStatusCardVariant.featured] (destaque da Início): o título do
///   serviço é o que se lê primeiro; local, responsável e código abaixo;
///   status, prazo e prioridade com ícone à direita; situação em faixa
///   tingida ao lado da ação.
/// - [AppStatusCardVariant.compact] (o próximo da fila na Início): título,
///   local e status, sem ação — tocar abre o detalhe.
class OsSummaryCard extends StatelessWidget {
  const OsSummaryCard({
    super.key,
    required this.os,
    required this.agora,
    required this.onTap,
    this.onAcaoRapida,
    this.variant = AppStatusCardVariant.standard,
  });

  final OrdemServico os;

  /// "Agora" de referência da situação — vem do `osRelogioProvider`.
  final DateTime agora;
  final VoidCallback onTap;

  /// Disparada pelo botão do rodapé; sem ela, o card não mostra botão.
  final VoidCallback? onAcaoRapida;

  final AppStatusCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final acao = onAcaoRapida == null ? null : osAcaoRapida(os.status);
    final urgente =
        os.prioridade == PrioridadeOs.alta ||
        os.prioridade == PrioridadeOs.urgente;
    // O nome da tarefa é o que se lê primeiro em toda variante — é o que
    // diz o que fazer; o número da OS fica na linha de apoio, para conferir.
    return AppStatusCard(
      variant: variant,
      statusLabel: os.status.label,
      statusTone: osStatusTone(os.status),
      title: os.titulo,
      // Dois por linha, na ordem do que se procura: onde e até quando;
      // prioridade e quem executa; o número da OS para conferir.
      meta: [
        AppStatusCardMeta(
          label: 'Local',
          value: os.area,
          icon: AppIcons.mapPin,
        ),
        AppStatusCardMeta(
          label: 'Prazo',
          value: osPrazoRelativo(os.prazo, agora),
          icon: AppIcons.calendar,
        ),
        AppStatusCardMeta(
          label: 'Prioridade',
          value: os.prioridade.label,
          highlight: urgente,
          icon: AppIcons.alertCircle,
        ),
        AppStatusCardMeta(
          label: 'Responsável',
          value: os.responsavelExecucao,
          icon: AppIcons.user,
        ),
        AppStatusCardMeta(
          label: 'Código',
          value: os.codigo,
          icon: AppIcons.ordemServico,
        ),
      ],
      situation: osSituacao(os, agora),
      action: acao == null
          ? null
          : AppStatusCardAction(
              label: acao.label,
              icon: acao.icon,
              primary: acao.primary,
              onPressed: onAcaoRapida!,
            ),
      onTap: onTap,
    );
  }
}

/// Corpo completo da OS (detalhe em tela cheia) — todos os campos vindos da
/// solicitação/autorização, alocação de recursos, execução e histórico.
/// `actions` é a lista de botões específica de cada perfil.
///
/// Hierarquia pensada para quem lê no campo: número e título grande no topo,
/// status e prioridade em chips logo abaixo do título, e cada grupo de dados numa
/// [AppDetailSection] com ícone próprio e bloco cinza — o olho acha o grupo
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
              fontSize: AppTypography.xl2,
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
                    onTap: () => _abrirEvento(context, evento),
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
                AppDetailField(label: 'Uso', value: os.uso.label),
                AppDetailField(label: 'Operação', value: os.operacao),
                AppDetailField(label: 'Atividade', value: os.atividade),
                AppDetailField(label: 'Prioridade', value: os.prioridade.label),
                AppDetailField(
                  label: 'Dt. execução',
                  value: _fmtData(os.dataExecucao),
                ),
                AppDetailField(label: 'Prazo final', value: _fmtData(os.prazo)),
              ],
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.mapPin,
            title: 'Execução',
            child: AppDetailFields(
              columns: 2,
              fields: [
                AppDetailField(label: 'Fazenda', value: os.fazenda),
                AppDetailField(label: 'Área', value: os.area),
                if (os.uso.usaCultura && os.culturaVariedade != null)
                  AppDetailField(
                    label: 'Cultura/Variedade',
                    value: os.culturaVariedade!,
                  ),
                if (os.uso.usaLote && os.lote != null)
                  AppDetailField(label: 'Lote', value: os.lote!),
                if (os.uso.usaLote && os.categoria != null)
                  AppDetailField(label: 'Categoria', value: os.categoria!),
              ],
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.cloudSun,
            title: 'Condições e restrições',
            child: AppDetailFields(
              columns: 2,
              fields: [
                AppDetailField(
                  label: 'Temperatura',
                  value: os.condicoes.temperaturaMinima == 0 &&
                          os.condicoes.temperaturaMaxima == 0
                      ? 'Não informado'
                      : '${_qtd(os.condicoes.temperaturaMinima)} a '
                            '${_qtd(os.condicoes.temperaturaMaxima)} °C',
                ),
                AppDetailField(
                  label: 'Horário permitido',
                  value: (os.condicoes.horarioInicio.isEmpty ||
                          os.condicoes.horarioFim.isEmpty)
                      ? 'Não informado'
                      : '${os.condicoes.horarioInicio} às '
                            '${os.condicoes.horarioFim}',
                ),
                AppDetailField(
                  label: 'Requisitos climáticos',
                  value: os.condicoes.requisitosClimaticos,
                ),
              ],
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.listOrdered,
            title: 'Instruções detalhadas',
            child: AppDetailFields(
              fields: [
                AppDetailField(
                  label: 'Resultados esperados',
                  value: os.instrucoes.resultadosEsperados,
                ),
                AppDetailField(
                  label: 'Critérios de sucesso',
                  value: os.instrucoes.criteriosSucesso,
                ),
                AppDetailField(
                  label: 'Roteiro/Planejamento',
                  value: os.instrucoes.roteiro,
                ),
              ],
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.shieldAlert,
            title: 'Segurança e sustentabilidade',
            tone: AppDetailSectionTone.warning,
            child: AppDetailFields(
              fields: [
                AppDetailField(
                  label: 'Restrições ambientais',
                  value: os.seguranca.restricoesAmbientais,
                ),
                AppDetailField(
                  label: 'Conformidade legal',
                  value: os.seguranca.conformidadeLegal,
                ),
              ],
            ),
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
                  caption: 'Emitida em ${_fmtDataHora(os.dataEmissao)}',
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
            child: AppDetailList(
              items: [for (final m in os.maoDeObra) m.executor],
              captions: [
                for (final m in os.maoDeObra)
                  [m.tipo.label, ?m.funcao].join(' · '),
              ],
              onItemTap: (i) => _abrirMaoDeObra(context, os.maoDeObra[i]),
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.tractor,
            title: 'Máquinas e implementos',
            count: os.maquinas.length,
            child: AppDetailList(
              items: [for (final m in os.maquinas) m.equipamento],
              captions: [for (final m in os.maquinas) m.observacao],
              onItemTap: (i) => _abrirMaquina(context, os.maquinas[i]),
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.flaskConical,
            title: 'Insumos',
            count: os.insumos.length,
            child: AppDetailList(
              items: [for (final ins in os.insumos) ins.produto],
              captions: [
                for (final ins in os.insumos)
                  [
                    '${_qtd(ins.quantidadeTotal)} ${ins.unidadeMedida}',
                    if (ins.quantidadePorHa > 0)
                      '${_qtd(ins.quantidadePorHa)} ${ins.unidadeMedida}/ha',
                  ].join(' · '),
              ],
              onItemTap: (i) => _abrirInsumo(context, os, os.insumos[i]),
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.package,
            title: 'Produção',
            count: os.producao.isEmpty ? null : os.producao.length,
            child: AppDetailList(
              emptyLabel: 'Este serviço não gera produção.',
              items: [for (final p in os.producao) p.produto],
              captions: [
                for (final p in os.producao)
                  '${_qtd(p.quantidade)} ${p.unidadeMedida}',
              ],
              onItemTap: (i) => _abrirProducao(context, os, os.producao[i]),
            ),
          ),
          _gap,
          AppDetailSection(
            icon: AppIcons.shieldCheck,
            title: 'Equipamentos de proteção (EPI)',
            count: os.epis.length,
            child: AppDetailList(
              items: [for (final e in os.epis) e.produto],
              captions: [for (final e in os.epis) e.observacao],
              onItemTap: (i) => _abrirEpi(context, os.epis[i]),
            ),
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
                      onTap: () => _abrirEvidencia(context, ev),
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
              title: 'Por que precisa refazer',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space3,
                    ),
                    child: AppDetailText(avaliacao.comentario),
                  ),
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
