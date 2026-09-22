import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_colors.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../ui/ui.dart';
import '../state/fazendas_store.dart';
import 'farm_picker.dart';
import '../../../design/generated/app_layout.dart';

/// Badge de contexto fixo na home operacional legada (spec §3.5):
/// "Lançando em: {fazenda}" — mantém o tenant sempre visível (mitigação de UX
/// p/ IDOR). Espelha `ContextBadge.tsx`. Os fluxos profundos não o renderizam:
/// neles, a fazenda já foi definida na entrada e o foco fica no cadastro.
///
/// A faixa é tocável: abre o seletor de fazendas e troca o tenant sem sair da
/// tela. Antes, trocar de fazenda exigia voltar até a aba "Fazendas" — o
/// contexto era visível mas não acionável, e o toque na faixa não fazia nada.
class ContextBadge extends ConsumerWidget {
  const ContextBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFarm = ref.watch(
      fazendasStoreProvider.select((s) => s.activeFarm),
    );

    return AppPressable(
      semanticLabel: 'Fazenda ativa: ${activeFarm.name}. Toque para trocar.',
      onPressed: () => openFarmPicker(context, ref),
      // A faixa é full-bleed e retangular: raio zero mantém o feedback de
      // toque alinhado à borda em vez de arredondar dentro da barra.
      borderRadius: BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        decoration: const BoxDecoration(
          color: AppColors.brand50,
          border: Border(bottom: BorderSide(color: AppColors.brand200)),
        ),
        child: Row(
          children: [
            const AppIcon(
              AppIcons.mapPin,
              size: AppSize.iconXs,
              color: AppColors.brand700,
            ),
            const SizedBox(width: AppSpacing.space1),
            Flexible(
              child: Text(
                'Lançando em: ${activeFarm.name}',
                style: const TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                  color: AppColors.brand700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.space1),
            // Affordance de "isto troca de contexto": sem a seta a faixa lê
            // como rótulo estático.
            const AppIcon(
              AppIcons.chevronDown,
              size: AppSize.iconXs,
              color: AppColors.brand700,
            ),
          ],
        ),
      ),
    );
  }
}
