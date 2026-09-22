import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/estoque_mocks.dart';
import 'unidade_card.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../../../design/generated/app_layout.dart';

/// Detalhe de Unidade de armazenagem, acionado pelo `UnidadeCard` na Home e na
/// aba Unidades — capacidade, ocupação, produtos armazenados, endereço mock e
/// CTA para o estoque já filtrado pela unidade. Espelha
/// `UnidadeDetailSheet.tsx`.
///
/// Abre em tela cheia ([showAppDetailPage]): das visualizações do Armazém é a
/// que mais sofria na folha inferior, porque a lista de produtos armazenados
/// cresce com a ocupação da unidade.
Future<void> showUnidadeDetailSheet(
  BuildContext context, {
  required Unidade unidade,
}) {
  return showAppDetailPage<void>(
    context,
    title: 'Detalhe da unidade',
    child: _SheetBody(unidade: unidade),
  );
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.unidade});

  final Unidade unidade;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final chip = statusChip[unidade.status]!;
    final itens = itensEstoque
        .where((it) => it.unidadeId == unidade.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              unidade.nome,
              style: TextStyle(
                fontSize: AppTypography.xl,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            AppChip(tone: chip.tone, child: Text(chip.label)),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),

        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: semantic.bgSubtle,
            border: Border.all(color: semantic.borderDefault),
            borderRadius: BorderRadius.circular(AppRadius.xl2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ocupação',
                    style: TextStyle(
                      fontSize: AppTypography.md,
                      color: semantic.fgMuted,
                    ),
                  ),
                  Text(
                    '${unidade.ocupacaoPct}% de ${unidade.capacidade}',
                    style: TextStyle(
                      fontSize: AppTypography.md,
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              AppProgressBar(
                value: unidade.ocupacaoPct.toDouble(),
                colorByOccupancy: true,
              ),
            ],
          ),
        ),

        if (itens.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space4),
          Text(
            'PRODUTOS ARMAZENADOS',
            style: TextStyle(
              fontSize: AppTypography.sm,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgSubtle,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          for (final it in itens)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.space2),
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                border: Border.all(color: semantic.borderDefault),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      it.produto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: AppTypography.weightMedium,
                        color: semantic.fgDefault,
                      ),
                    ),
                  ),
                  Text(
                    it.quantidadeLabel,
                    style: TextStyle(
                      fontSize: AppTypography.md,
                      color: semantic.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],

        const SizedBox(height: AppSpacing.space4),
        Row(
          children: [
            AppIcon(
              AppIcons.mapPin,
              size: AppSize.iconXs,
              color: semantic.fgMuted,
            ),
            const SizedBox(width: AppSpacing.oneHalf),
            Expanded(
              child: Text(
                unidade.endereco,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  color: semantic.fgMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),

        AppButton(
          fullWidth: true,
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/armazem/estoque?unidade=${unidade.id}');
          },
          child: const Text('Ver estoque da unidade'),
        ),
      ],
    );
  }
}
