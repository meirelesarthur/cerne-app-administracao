import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../mocks/bank_mocks.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../../../design/generated/app_layout.dart';

/// Bank › Limites — faixas de limite (crédito, Pix, saque) com ocupação por
/// `AppProgressBar`. Espelha `LimitesScreen.tsx`.
class LimitesScreen extends ConsumerWidget {
  const LimitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final balanceHidden = ref.watch(shellStoreProvider).balanceHidden;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(level: AppHeadingLevel.h3, child: Text('Limites')),
        const SizedBox(height: AppSpacing.space1),
        Text(
          'Acompanhe o uso de cada faixa de limite da sua conta.',
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        ),
        const SizedBox(height: AppSpacing.space5),
        const AppSectionTitle(child: Text('Faixas ativas')),
        const SizedBox(height: AppSpacing.space2),
        for (final f in faixasLimite) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      f.label,
                      style: TextStyle(
                        fontSize: AppTypography.md,
                        fontWeight: AppTypography.weightSemibold,
                        color: semantic.fgDefault,
                      ),
                    ),
                    Text(
                      '${balanceHidden ? '••••' : f.usado} / ${balanceHidden ? '••••' : f.total}',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        fontWeight: AppTypography.weightMedium,
                        color: semantic.fgMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                AppProgressBar(
                  value: f.usadoPct.toDouble(),
                  colorByOccupancy: true,
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  '${f.usadoPct}% utilizado neste ciclo',
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    color: semantic.fgSubtle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
        ],
        const AppBanner(
          icon: AppIcon(AppIcons.info, size: AppSize.iconXs),
          child: Text(
            'Ajustes de limite passam por análise de crédito e são solicitados na tela de Cartões.',
          ),
        ),
      ],
    );
  }
}
