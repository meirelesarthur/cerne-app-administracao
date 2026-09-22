import 'package:flutter/material.dart';

import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../../design/generated/app_layout.dart';

/// Pílula de crédito pré-aprovado no header do Shell (Nova UI): cápsula de
/// superfície theme-aware com valor em destaque — espelha `CreditoPill.tsx`.
/// O deep link para o módulo Crédito é responsabilidade de quem chama ([onTap]).
class AppCreditoPill extends StatelessWidget {
  const AppCreditoPill({super.key, this.onTap});

  final VoidCallback? onTap;

  /// Valor mock do protótipo (idêntico ao React) — não é um token de design,
  /// só como `R$ 480.000,00` já era hardcoded em `CreditoPill.tsx`.
  static const _valor = 'R\$ 480.000,00';

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: semantic.shadowCard,
      ),
      child: Material(
        color: semantic.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: semantic.borderTint),
        ),
        child: AppPressable(
          semanticLabel: 'Abrir crédito pré-aprovado de $_valor',
          onPressed: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  AppIcons.creditCard,
                  size: AppSize.iconXs,
                  color: semantic.accentDefault,
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  _valor,
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    fontWeight: AppTypography.weightBold,
                    color: semantic.accentDefault,
                  ),
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  'crédito pré aprovado',
                  style: TextStyle(
                    fontSize: AppTypography.xs,
                    fontWeight: AppTypography.weightMedium,
                    color: semantic.fgMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
