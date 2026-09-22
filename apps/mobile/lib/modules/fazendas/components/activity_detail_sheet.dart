import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../types.dart';
import 'activity_list_item.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Nome legível do tipo de atividade (spec §6.7) — espelha `KIND_LABEL`.
const Map<ActivityKind, String> _kindLabel = {
  ActivityKind.pesagem: 'Pesagem',
  ActivityKind.evento: 'Evento de rebanho',
  ActivityKind.nfe: 'Entrada NF-e',
  ActivityKind.venda: 'Venda de animais',
  ActivityKind.insumo: 'Aplicação de insumo',
  ActivityKind.arracoamento: 'Arraçoamento',
};

/// Rótulos dos segmentos do `subtitle` ("A · B") por tipo — dá semântica de
/// ficha ao mock (fazenda, lote, quantidade, fornecedor…) sem inventar dado
/// novo. Espelha `KIND_DETAIL_LABELS`.
const Map<ActivityKind, List<String>> _kindDetailLabels = {
  ActivityKind.pesagem: ['Fazenda', 'Quantidade'],
  ActivityKind.evento: ['Referência', 'Detalhe'],
  ActivityKind.nfe: ['Categoria', 'Fornecedor'],
  ActivityKind.venda: ['Comprador', 'Quantidade'],
  ActivityKind.insumo: ['Local', 'Insumo'],
  ActivityKind.arracoamento: ['Dieta', 'Quantidade'],
};

/// Tipos capturados pelo app de campo — exibem a linha de origem/sincronização.
/// Espelha `FIELD_KINDS`.
const List<ActivityKind> _fieldKinds = [
  ActivityKind.pesagem,
  ActivityKind.arracoamento,
  ActivityKind.insumo,
  ActivityKind.evento,
];

/// Detalhe de Atividade (Plano de Navegabilidade, B1) — espelha
/// `ActivityDetailSheet.tsx`: `BottomSheet` acionado pelo `ActivityListItem`
/// em `FazendasHome`, `AtividadesScreen` e os dashboards administrativos.
/// Reaproveita os mesmos ícones e tons de status da lista (fonte única, Lei 2).
///
/// Espelha o padrão já usado por `showAppTransactionDetailSheet`: função que
/// abre a visualização em tela cheia ([showAppDetailPage]), chamada a partir
/// do `onTap` do `ActivityListItem`.
Future<void> showActivityDetailSheet(
  BuildContext context, {
  required Activity activity,
}) {
  return showAppDetailPage<void>(
    context,
    title: 'Detalhe da atividade',
    child: _ActivityDetailBody(activity: activity),
  );
}

class _ActivityDetailBody extends StatelessWidget {
  const _ActivityDetailBody({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final icon = kindIcon[activity.kind]!;
    final status = statusMeta[activity.status]!;
    final detailLabels = _kindDetailLabels[activity.kind]!;
    final segments = activity.subtitle.split(' · ');
    final syncedFromField =
        _fieldKinds.contains(activity.kind) &&
        activity.status == ActivityStatus.concluida;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Identidade da atividade
        Row(
          children: [
            Container(
              width: AppSpacing.space12,
              height: AppSpacing.space12,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: semantic.bgSubtle,
              ),
              child: AppIcon(
                icon,
                size: AppSize.iconMd,
                color: semantic.fgMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _kindLabel[activity.kind]!.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppTypography.xs,
                      fontWeight: AppTypography.weightBold,
                      color: semantic.fgSubtle,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.xlPlus,
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                ],
              ),
            ),
            AppChip(tone: status.tone, child: Text(status.label)),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),

        // Ficha da atividade — `AppReviewList`, fonte única dos campos de
        // leitura (Lei 2): cada linha é seu próprio cartão, não itens dentro
        // de uma moldura só.
        AppReviewList(
          items: [
            AppReviewItem(label: 'Quando', value: activity.time),
            for (var i = 0; i < segments.length; i++)
              AppReviewItem(
                label: i < detailLabels.length ? detailLabels[i] : 'Detalhe',
                value: segments[i],
              ),
          ],
        ),

        if (syncedFromField) ...[
          const SizedBox(height: AppSpacing.space3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                AppIcons.smartphone,
                size: AppSize.iconXs,
                color: semantic.fgMuted,
              ),
              const SizedBox(width: AppSpacing.space1),
              Text(
                'Registrado no campo',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: semantic.fgMuted,
                ),
              ),
              const SizedBox(width: AppSpacing.space1),
              Text('·', style: TextStyle(color: semantic.fgMuted)),
              const SizedBox(width: AppSpacing.space1),
              AppIcon(
                AppIcons.checkCircle2,
                size: AppSize.iconXs,
                color: semantic.accentDefault,
              ),
              const SizedBox(width: AppSpacing.space1),
              Text(
                'sincronizado',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.space3),
        Text(
          'Histórico completo, anexos e edição desta atividade ficam no sistema web GB CERNE.',
          style: TextStyle(
            fontSize: AppTypography.base,
            color: semantic.fgSubtle,
          ),
        ),
      ],
    );
  }
}
