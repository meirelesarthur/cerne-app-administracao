import 'package:flutter/material.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';

/// Conteúdo de um módulo antes de a F4 existir — cada módulo (Fazendas, Bank,
/// Crédito, Marketplace, Armazém) ganha sua tela real nessa fase seguinte.
/// Prova que o roteamento por módulo/aba (F3 DoD) funciona de ponta a ponta.
class ModulePlaceholderScreen extends StatelessWidget {
  const ModulePlaceholderScreen({
    super.key,
    required this.moduleLabel,
    required this.tabLabel,
  });

  final String moduleLabel;
  final String tabLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              moduleLabel,
              style: TextStyle(
                fontSize: AppTypography.xl2,
                fontWeight: AppTypography.weightBold,
                color: semantic.fgDefault,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              '$tabLabel — módulo chega na F4',
              style: TextStyle(
                fontSize: AppTypography.md,
                color: semantic.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
