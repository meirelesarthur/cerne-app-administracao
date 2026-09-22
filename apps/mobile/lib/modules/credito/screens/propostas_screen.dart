import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../credito_status.dart';
import '../mocks/credito_mocks.dart';
import '../../../design/generated/app_layout.dart';

/// Total solicitado somado das propostas — pré-computado (sem matemática
/// financeira em runtime).
const String _totalSolicitado = 'R\$ 526.500,00';

/// Soma das propostas com status aprovada/contratada.
const String _totalAprovado = 'R\$ 276.500,00';

/// Tela "Minhas propostas" do módulo Crédito: KPIs de acompanhamento e a
/// listagem completa das propostas em andamento ou concluídas. Espelha
/// `PropostasScreen.tsx`.
class PropostasScreen extends StatelessWidget {
  const PropostasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(child: Text('Minhas propostas')),
        const SizedBox(height: AppSpacing.space6),
        const Row(
          children: [
            Expanded(
              child: AppKpiStatCard(
                label: 'Total solicitado',
                value: _totalSolicitado,
              ),
            ),
            SizedBox(width: AppSpacing.space3),
            Expanded(
              child: AppKpiStatCard(
                label: 'Aprovado',
                value: _totalAprovado,
                tone: AppKpiStatTone.positive,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space6),
        for (final proposta in propostas)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: AppCard(
              interactive: true,
              onTap: () => context.go('/credito/proposta/${proposta.id}'),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          proposta.linha,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.sm,
                            fontWeight: AppTypography.weightMedium,
                            color: semantic.fgDefault,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.half),
                        Text(
                          proposta.data,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: semantic.fgMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        proposta.valor,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      AppChip(
                        tone: propostaStatusTone(proposta.status),
                        child: Text(propostaStatusLabel(proposta.status)),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  AppIcon(
                    AppIcons.arrowRight,
                    size: AppSize.iconSm,
                    color: semantic.fgSubtle,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
