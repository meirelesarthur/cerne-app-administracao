import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../credito_status.dart';
import '../mocks/credito_mocks.dart';
import '../../../design/generated/app_layout.dart';

enum _StepState { done, current, pending, rejected }

class _TimelineStep {
  const _TimelineStep({required this.label, this.date, required this.state});

  final String label;
  final String? date;
  final _StepState state;
}

/// Monta a timeline de etapas da proposta a partir do status e histórico de
/// datas — espelha `buildTimeline` de `PropostaDetalheScreen.tsx`.
List<_TimelineStep> _buildTimeline(Proposta proposta) {
  final historico = proposta.historico;
  if (proposta.status == PropostaStatus.recusada) {
    return [
      _TimelineStep(
        label: 'Proposta enviada',
        date: historico.enviada,
        state: _StepState.done,
      ),
      _TimelineStep(
        label: 'Em análise',
        date: historico.analise,
        state: _StepState.done,
      ),
      _TimelineStep(
        label: 'Recusada',
        date: historico.decisao,
        state: _StepState.rejected,
      ),
    ];
  }

  return [
    _TimelineStep(
      label: 'Proposta enviada',
      date: historico.enviada,
      state: _StepState.done,
    ),
    _TimelineStep(
      label: 'Em análise',
      date: historico.analise,
      state: proposta.status == PropostaStatus.analise
          ? _StepState.current
          : _StepState.done,
    ),
    _TimelineStep(
      label: 'Aprovada',
      date: historico.decisao,
      state: proposta.status == PropostaStatus.analise
          ? _StepState.pending
          : proposta.status == PropostaStatus.aprovada
          ? _StepState.current
          : _StepState.done,
    ),
    _TimelineStep(
      label: 'Contratada',
      date: historico.contratada,
      state: proposta.status == PropostaStatus.contratada
          ? _StepState.current
          : _StepState.pending,
    ),
  ];
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.steps});

  final List<_TimelineStep> steps;

  ({Color border, Color bg, Color fg}) _markerColors(
    _StepState state,
    AppSemanticColors s,
  ) => switch (state) {
    _StepState.done => (
      border: s.accentDefault,
      bg: s.accentDefault,
      fg: AppColors.neutral0,
    ),
    _StepState.current => (
      border: s.accentDefault,
      bg: s.bgSurface,
      fg: s.accentDefault,
    ),
    _StepState.pending => (
      border: s.borderDefault,
      bg: s.bgSubtle,
      fg: s.fgSubtle,
    ),
    _StepState.rejected => (
      border: AppColors.red500,
      bg: AppColors.red500,
      fg: AppColors.neutral0,
    ),
  };

  Color _labelColor(_StepState state, AppSemanticColors s) => switch (state) {
    _StepState.done => s.fgDefault,
    _StepState.current => s.fgDefault,
    _StepState.pending => s.fgSubtle,
    _StepState.rejected => AppColors.red600,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps.length; i++)
          Builder(
            builder: (context) {
              final step = steps[i];
              final isLast = i == steps.length - 1;
              final markerColors = _markerColors(step.state, semantic);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: AppSpacing.space7,
                        height: AppSpacing.space7,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: markerColors.bg,
                          border: Border.all(
                            color: markerColors.border,
                            width: 2,
                          ),
                        ),
                        child: step.state == _StepState.done
                            ? AppIcon(
                                AppIcons.check,
                                size: AppSize.iconXs,
                                color: markerColors.fg,
                              )
                            : step.state == _StepState.rejected
                            ? AppIcon(
                                AppIcons.x,
                                size: AppSize.iconXs,
                                color: markerColors.fg,
                              )
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: AppSpacing.half,
                          ),
                          width: 1,
                          height: AppSpacing.space9,
                          color: step.state == _StepState.pending
                              ? semantic.borderDefault
                              : semantic.accentDefault,
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? AppSpacing.space0 : AppSpacing.space5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            step.label,
                            style: TextStyle(
                              fontSize: AppTypography.sm,
                              fontWeight: AppTypography.weightSemibold,
                              color: _labelColor(step.state, semantic),
                            ),
                          ),
                          if (step.date != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.half,
                              ),
                              child: Text(
                                step.date!,
                                style: TextStyle(
                                  fontSize: AppTypography.sm,
                                  color: semantic.fgMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Banner + CTA contextual conforme o status atual da proposta — sem
/// prometer ações inexistentes. Espelha `StatusCta` de `PropostaDetalheScreen.tsx`.
class _StatusCta extends StatelessWidget {
  const _StatusCta({required this.proposta});

  final Proposta proposta;

  @override
  Widget build(BuildContext context) {
    late final AppBannerTone tone;
    late final String text;
    Widget? action;

    switch (proposta.status) {
      case PropostaStatus.analise:
        tone = AppBannerTone.info;
        text =
            'Sua proposta está em análise. O retorno costuma levar de 2 a 5 dias úteis.';
      case PropostaStatus.aprovada:
        tone = AppBannerTone.success;
        text =
            'Proposta aprovada! Nossa equipe vai formalizar o contrato em breve.';
      case PropostaStatus.recusada:
        tone = AppBannerTone.error;
        text =
            'Proposta recusada. Você pode simular novamente com outros valores ou prazo.';
        action = AppButton(
          size: AppButtonSize.sm,
          variant: AppButtonVariant.secondary,
          onPressed: () => context.go('/credito/simular'),
          child: const Text('Simular novamente'),
        );
      case PropostaStatus.contratada:
        tone = AppBannerTone.success;
        text = 'Contrato ativo. Acompanhe as parcelas na tela de contratos.';
        action = AppButton(
          size: AppButtonSize.sm,
          variant: AppButtonVariant.secondary,
          onPressed: () => context.go('/credito/contratos'),
          child: const Text('Ver contratos'),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppBanner(tone: tone, action: action, child: Text(text)),
        if (proposta.status == PropostaStatus.analise) ...[
          const SizedBox(height: AppSpacing.space2),
          const AppButton(fullWidth: true, child: Text('Aguardando análise')),
        ],
      ],
    );
  }
}

/// Detalhe de uma proposta de crédito: status, timeline de etapas, dados e
/// documentos. Espelha `PropostaDetalheScreen.tsx`; recebe o `id` via rota
/// (`/credito/proposta/:id`).
class PropostaDetalheScreen extends StatelessWidget {
  const PropostaDetalheScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    Proposta? proposta;
    for (final p in propostas) {
      if (p.id == id) {
        proposta = p;
        break;
      }
    }

    if (proposta == null) {
      return AppPageBody(
        title: 'Proposta',
        onBack: () => context.go('/credito/propostas'),
        sheetColor: semantic.bgSheet,
        child: Center(
          child: AppEmptyState(
            icon: AppIcons.frown,
            title: 'Proposta não encontrada',
            description:
                'Essa proposta pode ter sido removida ou o link está incorreto.',
            action: AppButton(
              onPressed: () => context.go('/credito/propostas'),
              child: const Text('Ver todas as propostas'),
            ),
          ),
        ),
      );
    }

    final steps = _buildTimeline(proposta);

    // Folha cinza (`bgSheet`): a tela é uma listagem de cartões de status —
    // andamento, dados, documentos —, não um formulário. O mesmo critério de
    // `sheetColor` que separa cadastro (folha branca) de consulta em
    // `AppPageScaffold`.
    return AppPageBody(
      title: proposta.linha,
      onBack: () => context.go('/credito/propostas'),
      sheetColor: semantic.bgSheet,
      scrollable: false,
      bodyPadding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Valor solicitado',
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: semantic.fgMuted,
                    ),
                  ),
                  Text(
                    proposta.valor,
                    style: TextStyle(
                      fontSize: AppTypography.xl2,
                      fontWeight: AppTypography.weightBold,
                      color: semantic.fgDefault,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              AppChip(
                tone: propostaStatusTone(proposta.status),
                child: Text(propostaStatusLabel(proposta.status)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          _StatusCta(proposta: proposta),
          const SizedBox(height: AppSpacing.space5),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppSectionTitle(child: Text('Andamento')),
                const SizedBox(height: AppSpacing.space3),
                _Timeline(steps: steps),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppSectionTitle(child: Text('Dados da proposta')),
                const SizedBox(height: AppSpacing.space3),
                _dadoRow(context, 'Linha', proposta.linha),
                const SizedBox(height: AppSpacing.space2),
                _dadoRow(context, 'Valor', proposta.valor),
                const SizedBox(height: AppSpacing.space2),
                _dadoRow(context, 'Prazo', '${proposta.prazo} meses'),
                const SizedBox(height: AppSpacing.space2),
                _dadoRow(context, 'Taxa', proposta.taxa),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppSectionTitle(child: Text('Documentos')),
                const SizedBox(height: AppSpacing.space3),
                for (final doc in proposta.documentos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                    child: Row(
                      children: [
                        Container(
                          width: AppSpacing.space9,
                          height: AppSpacing.space9,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: semantic.bgSubtle,
                          ),
                          child: AppIcon(
                            AppIcons.fileText,
                            size: AppSize.iconSmPlus,
                            color: semantic.fgMuted,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Text(
                            doc.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppTypography.sm,
                              fontWeight: AppTypography.weightMedium,
                              color: semantic.fgDefault,
                            ),
                          ),
                        ),
                        AppChip(
                          tone: doc.enviado
                              ? AppChipTone.brand
                              : AppChipTone.amber,
                          child: Text(doc.enviado ? 'Enviado' : 'Pendente'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dadoRow(BuildContext context, String label, String value) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppTypography.sm,
            fontWeight: AppTypography.weightSemibold,
            color: semantic.fgDefault,
          ),
        ),
      ],
    );
  }
}
