import 'package:flutter/material.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import '../mocks/estoque_mocks.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Aba "Relatórios": relatórios mockados de operação do armazém (spec D2.5).
/// Espelha `RelatoriosScreen.tsx`.
class RelatoriosScreen extends StatelessWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        const AppHeading(child: Text('Relatórios')),
        const SizedBox(height: AppSpacing.space3),
        if (relatorios.isEmpty)
          const AppEmptyState(
            icon: AppIcons.fileBarChart,
            title: 'Nenhum relatório',
            description: 'Ainda não há relatórios gerados para o armazém.',
          )
        else
          for (final rel in relatorios)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rel.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: AppTypography.weightSemibold,
                              color: semantic.fgDefault,
                            ),
                          ),
                        ),
                        AppChip(
                          tone: rel.disponivel
                              ? AppChipTone.brand
                              : AppChipTone.neutral,
                          child: Text(
                            rel.disponivel ? 'Disponível' : 'Indisponível',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.half),
                    Text(
                      rel.periodo,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
