import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/estoque_mocks.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Rótulo + tom de status — fonte única, reutilizado no `UnidadeDetailSheet`
/// (Lei 2).
const Map<UnidadeStatus, ({AppChipTone tone, String label})> statusChip = {
  UnidadeStatus.ok: (tone: AppChipTone.brand, label: 'Normal'),
  UnidadeStatus.atencao: (tone: AppChipTone.amber, label: 'Atenção'),
  UnidadeStatus.critico: (tone: AppChipTone.red, label: 'Crítico'),
};

/// Card de unidade de armazenagem — reutilizado na Home e na aba Unidades
/// (Lei 2). Espelha `UnidadeCard.tsx`.
class UnidadeCard extends StatelessWidget {
  const UnidadeCard({super.key, required this.unidade, this.onTap});

  final Unidade unidade;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final chip = statusChip[unidade.status]!;

    return AppCard(
      interactive: onTap != null,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unidade.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
              ),
              AppChip(tone: chip.tone, child: Text(chip.label)),
            ],
          ),
          const SizedBox(height: AppSpacing.half),
          Text(
            '${unidade.produto} · ${unidade.capacidade}',
            style: TextStyle(
              fontSize: AppTypography.sm,
              color: semantic.fgMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              Expanded(
                child: AppProgressBar(
                  value: unidade.ocupacaoPct.toDouble(),
                  colorByOccupancy: true,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Text(
                '${unidade.ocupacaoPct}%',
                style: TextStyle(
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
